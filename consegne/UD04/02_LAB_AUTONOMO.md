# Consegna UD04 — Laboratorio autonomo

## Scelta del servizio e della ridondanza

**Requisito:** conservare documenti consultati frequentemente per 30 giorni e file temporanei eliminabili dopo un giorno; utenti applicativi in sola lettura senza account key; nessun accesso pubblico anonimo.

**Servizio scelto: Blob.** Blob organizza dati come oggetti in container, accessibili via REST/SDK, con tier di accesso (Hot/Cool/Cold/Archive) e lifecycle management: è il modello giusto per documenti applicativi e per l'eliminazione automatica dei temporanei dopo un giorno.

- **Azure Files** sarebbe adatto solo se servisse una file share SMB/NFS montata come filesystem da VM o utenti; non è il caso (accesso applicativo via API e nessun mount richiesto).
- **Queue** serve al disaccoppiamento di messaggi asincroni, non alla conservazione di documenti.
- **Table** è un archivio NoSQL chiave/attributi per dati schemaless, non per file.

**Ridondanza:** in produzione, con requisito di resilienza a un guasto zonale, userei **ZRS** (replica sincrona in tre zone nella stessa region). Il laboratorio usa **LRS** perché è la scelta economica e sufficiente per dati ricostruibili e temporanei di un esercizio.

## Operazioni e verifica

- **Container:** `archive`, creato da CLI con `--auth-mode login`; privato di default (nessun accesso pubblico anonimo). Esito: `"created": true`.
- **Blob:** copia di `01_DOCUMENTO_LAB.txt` caricata come `current/documento.txt` con `--auth-mode login` (prefisso `current/` = cartella virtuale, Azure Blob non ha directory reali). Verifica:

| Blob | Tier | Dimensione |
|---|---|---|
| `current/documento.txt` | Hot | 98 byte |

- **SAS limitata:** user delegation SAS (`--auth-mode login --as-user`), permesso `r` (sola lettura), scope al **singolo blob** `archive/current/documento.txt`, scadenza **15 minuti**. Esito: download via `curl` riuscito e `cmp` originale/scaricato con **codice 0** (contenuto identico). La variabile è stata rimossa con `unset` e il file temporaneo eliminato: nessun token o URL riportato.

## Diagnosi

| Sintomo | Piano interessato | Causa | Controllo | Correzione |
|---|---|---|---|---|
| `AuthorizationPermissionMismatch` | Data plane (richiesta ai dati) | Il principal è autenticato ma non ha un ruolo dati che copra l'operazione sullo scope | Verificare ruolo (es. Storage Blob Data Reader/Contributor), scope e principal | Assegnare il ruolo dati corretto sullo scope minimo; Contributor sul management plane non basta |
| `ResourceNotFound: The specified container does not exist` | Data plane | Nome container o account errato, oppure container non ancora creato | `az storage container list` e controllo nome/account | Correggere nome/account o creare il container; attenzione alla distinzione maiuscole/minuscole |
| `curl: (22) ... error: 403` | Data plane (accesso via URL) | URL/SAS non valido, scaduto o con permessi insufficienti (o accesso anonimo negato) | Verificare permessi, scope, scadenza della SAS e che il container resti privato | Rigenerare la SAS con permessi/scope/durata corretti; non abilitare l'accesso anonimo |

## Lifecycle, costi e cleanup

**Prefisso e lifecycle:** la rule `delete-temporary` filtra `documents/temporary/` (container `documents` + percorso `temporary/`). Il blob `archive/current/documento.txt` vive in un **container diverso** (`archive`) e con un percorso diverso (`current/`): non rientra nel filtro, quindi la regola non lo elimina. La lifecycle applica solo ai blob che corrispondono al prefisso specificato.

**Driver di costo:** ridondanza (LRS/ZRS/GRS), tier di accesso (Hot/Cool/Cold/Archive), capacità conservata fatturata, numero e tipo di operazioni, recupero (reidratazione da Archive) e trasferimento dati in uscita.

**Cleanup (non ancora eseguito — da fare a fine laboratorio):** rimozione dei blob e del container `archive`; eventuale rimozione della role assignment dati temporanea; eliminazione del resource group `rg-cea-storage-7c11d822`; pulizia dei file temporanei locali; rotazione della chiave esposta accidentalmente in fase di appunti.

## Risultato finale

- nessun segreto pubblicato: sì — nessuna account key, SAS o URL firmata è riportata in questo documento; il token SAS è stato rimosso subito dopo la verifica
- hash abbreviato e messaggio del commit: da compilare dopo il commit della consegna
