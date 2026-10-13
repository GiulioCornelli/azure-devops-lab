# Consegna UD02 — Laboratorio guidato

## Contesto verificato

- Azure Portal accessibile: sì — usato per creare resource group (§5), rete virtuale (§6) e storage account (§7).
- Azure CLI autenticata: sì — `az login --use-device-code` completato; `az account show --output table` restituisce la sessione attiva e `az version` conferma azure-cli 2.74.0.
- sottoscrizione corretta verificata senza pubblicarne l'ID: sì — unica sottoscrizione visibile ("Azure subscription 1"), stato `Enabled` e `IsDefault = True`; ID e tenant ID non riportati.
- località scelta e motivo: `italynorth` — presente in `az account list-locations` ed è la region più vicina con residenza dei dati in Italia, adeguata a un laboratorio temporaneo.

## Ambiente creato

| Elemento | Nome tecnico | Tipo | Località | Scopo |
|---|---|---|---|---|
| Resource group | `rg-cea-ud02-70e3b231` | `Microsoft.Resources/resourceGroups` | Italy North (`italynorth`) | contenitore del ciclo di vita dell'unità: confine di fatturazione e di cleanup. |
| Rete virtuale | `vnet-cea-ud02` | `Microsoft.Network/virtualNetworks` | Italy North (`italynorth`) | rete logica `10.20.0.0/16` con subnet `snet-app` `10.20.1.0/24`, base per le risorse di rete future. |
| Storage account | `stcea70e3b231` | `Microsoft.Storage/storageAccounts` (`StorageV2`, `Standard_LRS`) | Italy North (`italynorth`) | account vuoto per osservarne le proprietà di sicurezza (HTTPS obbligatorio, TLS ≥ 1.2, blob pubblico disabilitato); nessun dato caricato. |

## Decisioni e verifiche

Le tre risorse condividono lo stesso resource group perché fanno parte dello stesso ciclo di vita: nascono, vengono usate e devono essere eliminate insieme. Il gruppo è quindi il confine amministrativo e di fatturazione che rende il cleanup una sola operazione (`az group delete`) invece di tre, e impedisce che resti una risorsa orfana a generare costo.

Al cliente restano le responsabilità sulle configurazioni e sui dati: identità e autorizzazioni (RBAC), regole di rete, scelte di ridondanza e durabilità, tag di governance, custodia delle chiavi e dei dati caricati. Azure mantiene l'infrastruttura fisica, la disponibilità del servizio e il patching della piattaforma; non è compito del cliente gestire gli host.

Nomi e tag sono stati applicati per rendere l'ambiente riconoscibile e ripetibile senza usare dati personali: il prefisso distingue il tipo di risorsa (`rg-`, `vnet-`, `snet-`, `stc`), l'acronimo e l'unità (`cea-ud02`) legano la risorsa al percorso, e il suffisso `70e3b231` riduce le collisioni di nome. I tag (`course`, `unit`, `environment`, `deleteAfter`) aggiungono tracciabilità e attribuzione: permittono di filtrare le risorse per corso e unità e segnalano quando l'ambiente avrebbe dovuto essere eliminato. `deleteAfter` è un promemoria, non elimina nulla automaticamente.

La differenza osservata tra portale e CLI: nella pagina **JSON View** del portale ho visto l'oggetto completo, con l'ID gerarchico che contiene il segmento della sottoscrizione e tutte le proprietà annidate; con la CLI, invece, la stessa risorsa è stata letta selezionando esattamente i campi utili (`az group show --query "{...}"`) e ho potuto anonimizzare l'ID con `sed` sostituendo il segmento `/subscriptions/<ID>` con `<omitted>`. In pratica il portale è più efficace per esplorare proprietà ancora sconosciute, la CLI per ripetere controlli identici e produrre output selezionati e ripuliti.

## Cleanup

- operazione di eliminazione:
- controllo utilizzato:
- risultato finale:
- eventuale anomalia e soluzione:

## Rilevanza professionale

Inventario, tag e verifica del cleanup trasformano un insieme di risorse create a mano in una procedura ripetibile e controllabile. L'inventario (`az resource list`) è un'istantanea dichiarativa di ciò che esiste: prima del cleanup permette di confrontare le risorse previste con quelle reali e di accorgersi di oggetti estranei o preesistenti. I tag aggiungono l'attribuzione — corso, unità, ambiente e scadenza — così un ambiente può essere filtrato, addebitato a chi lo possiede e riconosciuto come temporaneo anche da chi non lo ha creato. La verifica finale (`az group exists` che restituisce `false`) chiude il ciclo di vita con una prova booleana invece che con un'ipotesi: senza questa conferma non si può escludere che una risorsa resti attiva e continui a generare costo. Nell'attività lavorativa questi tre elementi rendono il lavoro tracciabile, ripetibile da un collega e verificabile in audit.


## Registro cronologico delle evidenze

Compila durante il lavoro. Per ogni fase riporta data/ora e contesto (WSL, Cloud Shell Bash, Cloud Shell PowerShell o Portal), comando/pagina, breve risultato anonimizzato e interpretazione. Non inserire output di esempio come prova reale. Registra anche controlli negati, attese e azioni non eseguite.

| Data/ora | Fase e contesto | Comando o pagina | Risultato reale ripulito | Interpretazione / passo successivo |
|---|---|---|---|---|
| 2026-10-13 10:20 | §1 Preparazione repo (WSL Bash) | `mkdir -p consegne/UD02`; copia dei quattro modelli; `git commit -m "Inizializzazione ambiente UD02"` | quattro modelli presenti; commit `4e3307d` | consegne pronte e tracciate, si lavora nel repository personale. |
| 2026-10-13 11:43 | §2 Controllo Azure CLI (WSL Bash) | `az version` | `azure-cli 2.74.0` | CLI già installata: nessuna reinstallazione. |
| 2026-10-13 11:44 | §2 Sessione e sottoscrizione (WSL Bash) | `az account show --output table` | `Azure subscription 1 — Enabled — True` | sessione valida e sottoscrizione corretta (ID omesso). |
| 2026-10-13 11:48 | §3 Località (WSL Bash) | `az account list-locations --query "[?name=='italynorth']..."` | `italynorth / Italy North` presente | località candidata confermata per il provisioning. |
| 2026-10-13 11:50 | §3 Provider (WSL Bash) | `az provider show --namespace Microsoft.Network` e `Microsoft.Storage` | entrambi `Registered` | provider pronti, nessuna registrazione necessaria. |
| 2026-10-13 11:54 | §4 Nomi e tag (WSL Bash) | generazione suffisso; scrittura e validazione di `01_VARIABILI_LAB.sh` | `LAB_SUFFIX=70e3b231`; nome storage formalmente valido | variabili pronte, nessun dato personale. |
| 2026-10-13 12:02 | §5 RG da portale + verifica CLI (Portal, WSL Bash) | Create resource group con i 4 tag; `az group show` | ⟦incolla output ripulito⟧ (atteso `Succeeded`, località e 4 tag) | resource group creato e confermato dalla CLI. |
| 2026-10-13 12:17 | §6 VNet da portale + verifica CLI (Portal, WSL Bash) | Create Virtual network `10.20.0.0/16` + subnet `snet-app` `10.20.1.0/24`; `az network vnet show` | ⟦incolla output ripulito⟧ (atteso `/16` e subnet `/24`) | VNet e subnet appartenenti allo spazio della rete. |
| 2026-10-13 12:20 | §7 Disponibilità nome storage (WSL Bash) | `az storage account check-name` | ⟦incolla output ripulito⟧ (atteso `nameAvailable: true`) | nome globalmente disponibile: si procede. |
| 2026-10-13 12:37 | §7 Storage da portale + verifica CLI (Portal, WSL Bash) | Create storage account `StorageV2`/`Standard_LRS`, HTTPS only, TLS 1.2, blob anonimo off; `az storage account show` | ⟦incolla output ripulito⟧ (atteso `HttpsOnly: true`, `MinimumTls: TLS1_2`, `PublicBlobAccess: false`, `Succeeded`) | proprietà e sicurezza confermate; nessuna chiave letta, nessun dato caricato. |
| 2026-10-13 12:38–12:50 | §8 Inventario e anonimizzazione (WSL Bash) | `az resource list -o table` / `-o jsonc`; `az resource list --query "[].id" -o tsv \| sed -E 's#/subscriptions/[^/]+#/subscriptions/<omitted>#'` | inventario con VNet e storage; ID anonimizzati | inventario ricostruito e ripulito da dati riservati. |

Riporta le proprietà e l'inventario prima dell'eliminazione, poi richiesta, attesa e assenza finale. Per il guidato includi il confronto CLI/Azure PowerShell; per l'autonomo motivazioni e requisiti. Nella conferma finale cita un commit già pubblicato, non l'hash del documento che stai ancora modificando.
