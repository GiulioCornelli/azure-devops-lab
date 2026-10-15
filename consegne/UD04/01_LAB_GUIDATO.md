# Consegna UD04 — Laboratorio guidato

## Contesto anonimizzato

- resource group: `rg-cea-storage-7c11d822` (tag: course=cloud-engineer-academy, unit=UD04, environment=lab, deleteAfter=2026-10-16)
- storage account: `stcea7c11d822`
- region: italynorth
- tipo e ridondanza: StorageV2 (general purpose v2), Standard_LRS

## Servizi e configurazione

| Elemento | Configurazione | Motivazione |
|---|---|---|
| Blob container | `documents`, livello Private (no anonymous access) | Il container organizza i Blob e può costituire scope di autorizzazione; l'accesso anonimo non serve al laboratorio |
| access tier | Hot per entrambi i blob (`01_DOCUMENTO_LAB.txt`, `temporary/temporaneo.txt`) | File piccoli e frequentemente usati durante il lab: Hot minimizza il costo di conservazione per accessi ricorrenti |
| accesso pubblico | `allowBlobPublicAccess=false` | Nessun accesso pubblico anonimo sull'intero account: controllo di sicurezza di base |
| trasferimento/TLS | HTTPS-only (`enableHttpsTrafficOnly=true`), TLS 1.2 minimo | Trasferimento sicuro obbligatorio e cifrature non obsolete |

Endpoint (anonimizzato): `https://stcea7c11d822.blob.core.windows.net/`

## Autorizzazione e lifecycle

**Ruolo dati e scope**

| Principal anonimizzato | Ruolo | Scope | Diretta/ereditata |
|---|---|---|---|
| account corrente (User) | Storage Blob Data Contributor | storage account `stcea7c11d822` | Diretta |
| account corrente (User) | Owner | sottoscrizione `<omitted>` | Ereditata |

Il ruolo dati è stato assegnato sul solo storage account (scope minimo): autorizza il data plane (lettura/scrittura Blob) senza estendere i permessi all'intera sottoscrizione.

**Entra ID vs Shared Key vs SAS**

- **Entra ID** (`--auth-mode login`): autentica l'identità dell'operatore con ruolo RBAC data plane; ogni accesso è tracciabile individualmente. Usato per list/upload/download delle verifiche di sezione 5–6.
- **Shared Key** (`--auth-mode key`): usata per una sola lettura di confronto e rimossa subito con `unset` dalla memoria. La chiave concede accesso ampio a tutto l'account e non identifica chi la usa: ecco perché Entra ID è preferibile.
- **User delegation SAS**: generata con `--auth-mode login --as-user --permissions r`, scope al singolo blob `01_DOCUMENTO_LAB.txt`, scadenza 30 minuti. Solo lettura, nessun URL firmato registrato nelle evidenze. Token scomparso con `unset` (e scadenza naturale).

**Lifecycle rule**

| Campo | Valore |
|---|---|
| Nome | `delete-temporary` |
| Stato | Enabled |
| Prefisso | `documents/temporary/` (container + percorso) |
| Azione | eliminazione block blob dopo 1 giorno dall'ultima modifica |

La policy non è un job immediato: l'elaborazione può iniziare dopo ore. Il laboratorio ne verifica solo la configurazione; il filtro sul prefisso `temporary/` evita di coinvolgere il resto del container.

## Verifiche, costi e cleanup

- Upload dal portale: `01_DOCUMENTO_LAB.txt` (98 byte, Hot) nel container `documents`.
- Upload da CLI: `temporary/temporaneo.txt` (30 byte) con `--auth-mode login`.
- Download da CLI: `cmp` tra originale e file scaricato → nessun output, codice 0 → contenuto identico.
- Download via SAS: `cmp` → identico; esito confermato con permesso `r`, scope blob singolo, durata 30 minuti.
- Principal driver di costo: capacità (Hot), numero di operazioni, trasferimenti in uscita; il contenitore è vuoto di dati significativi e i file sono minimi.
- **Cleanup: non eseguito** (sezione 10 saltata su richiesta). La role assignment **Storage Blob Data Contributor** sullo storage account e il resource group `rg-cea-storage-7c11d822` sono ancora presenti e dovranno essere rimossi nel cleanup finale.

## Rilevanza professionale

- **Blob vs Files**: Blob organizza dati in oggetti in container accessibili via REST/SDK, ideale per log, immagini, documenti, backup e contenuti applicativi; espone tier (Hot/Cool/Cold/Archive) e lifecycle management. Files espone condivisioni SMB/NFS montabili da VM/utenti, senza tier di accesso blob.
- **Metodo di autorizzazione**: per lo scenario d'uso di Blob si sceglie Microsoft Entra ID con ruolo dati (es. Storage Blob Data Contributor) sullo scope minimo: least privilege, tracciabilità per operatore, nessun segreto condiviso. Shared Key e SAS restano opzioni di emergenza/delega, da limitare nella durata e nello scope.
