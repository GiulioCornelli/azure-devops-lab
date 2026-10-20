# UD07 — Consegna laboratorio autonomo

## 1. Script CLI idempotente

- logica:
  - script `laboratori/UD07/ud07-auto.sh`; `EXISTS=$(az group exists --name "$RG")`;
  - se `"false"` → `az group create` con `--tags ManagedBy=Autonomo UD=07`,
    altrimenti `else` → solo messaggio "esiste già: lo riutilizzo";
  - in entrambi i rami `az group update --set tags.ManagedBy=Autonomo tags.UD=07`
    (aggiornamento senza modificare lo stato) e `az group show` con JMESPath
    `{Name:name,Location:location,State:properties.provisioningState}`.
- prima esecuzione:
  ```
  Il Resource Group non esiste: lo creo.
  Location    Name
  ----------  ------------
  westeurope  rg-ud07-auto

  Aggiorno i tag...

  Stato finale:
  Name          Location    State
  ------------  ----------  ---------
  rg-ud07-auto  westeurope  Succeeded
  ```
- seconda esecuzione:
  ```
  Il Resource Group esiste già: lo riutilizzo.

  Aggiorno i tag...

  Stato finale:
  Name          Location    State
  ------------  ----------  ---------
  rg-ud07-auto  westeurope  Succeeded
  ```
  Nessuna seconda creazione: l'idempotenza è garantita dal fatto che la creazione
  è sotto `if`, mentre `update` e `show` sono ripetibili senza effetti collaterali.
- verifica:
  ```json
  {
    "Name": "rg-ud07-auto",
    "Tags": {
      "LastVerified": "2026-10-20T14:00:20Z",
      "ManagedBy": "Autonomo",
      "UD": "07"
    }
  }
  ```

## 2. PowerShell equivalente

- script `laboratori/UD07/ud07-auto.ps1` per `rg-ud07-auto-ps`:
- controllo esistenza:
  ```powershell
  $rg = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue
  if (-not $rg) { New-AzResourceGroup ... } else { "esiste già: lo riutilizzo" }
  ```
- modifica:
  ```powershell
  Set-AzResourceGroup -Name $rgName -Tag @{ ManagedBy = "PowerShell"; UD = "07" }
  ```
- output:
  ```
  Prima esecuzione:  "Il Resource Group non esiste: lo creo."
  Seconda esecuzione: "Il Resource Group esiste già: lo riutilizzo."

  Proprietà essenziali:
  ResourceGroupName Location   ProvisioningState
  ----------------- --------   -----------------
  rg-ud07-auto-ps   westeurope Succeeded
  ```
  Tag verificati: `ManagedBy=PowerShell`, `UD=07`.

## 3. Activity Log

- operazione: `Update resource group` (evento `EndRequest`, resource group `rg-ud07-auto`)
- status: `Succeeded` (subStatus `OK`, HTTP 200)
- timestamp:
  ```
  Time                          Operation             Status     Event        Sub
  ----------------------------  --------------------  ---------  -----------  ----
  2026-10-20T14:00:20Z          (modifica tag eseguita con az group update)
  2026-10-20T13:55:27.8878389Z  Update resource group  Succeeded  EndRequest   OK
  2026-10-20T13:55:26.09098Z    Update resource group  Started    BeginRequest
  2026-10-20T13:55:03.6105242Z  Update resource group  Succeeded  EndRequest   OK
  2026-10-20T13:55:01.7667319Z  Update resource group  Started    BeginRequest
  2026-10-20T13:54:59.8366531Z  Update resource group  Succeeded  EndRequest   Created
  2026-10-20T13:54:57.6022453Z  Update resource group  Started    BeginRequest
  ```
  - `caller` omesso (dato personale).

## 4. KQL

Query eseguita nel workspace `law-ud07-3522` (`az monitor log-analytics query`),
output:

```
AvgDuration    Requests    Status    TableName
-------------  ----------  --------  -------------
470            2           WARN      PrimaryResult
150            2           OK        PrimaryResult
```

1. Produce **2 righe aggregate** (una per `Status`: `WARN` e `OK`), derivate dalle 4 righe di input.
2. Lo stato con latenza media più alta è **`WARN`**, con `AvgDuration = 470 ms`
   (media di 430 e 510); `OK` è a 150 ms.
3. `summarize ... by Status` **raggruppa le righe per chiave e le sostituisce con una riga per gruppo**
   contenente gli aggregati (`count()`, `avg()`): la granularità passa da "una riga per evento"
   a "una riga per stato", quindi si perde il dettaglio individuale e si guadagna il confronto tra gruppi.

## 5. Metrics

- metrica: `UsedCapacity` sullo Storage Account `stud0792490543`
  (fra le 9 metric definitions disponibili: `Transactions`, `Ingress`, `Egress`,
  `SuccessServerLatency`, `SuccessE2ELatency`, `Availability`, `ReplicationLagSeconds`, `MigrationProgress`)
- unità: `Bytes`
- aggregazione: `Average` (grana ammessa `PT1H`; `PT5M` rifiutato con
  `BadRequest: Commonly allowed time grains: 01:00:00...`)
- dato presente: **no** — su 48 ore (2026-10-18 → 2026-10-20) i punti esistono come bucket orari ma senza valore (`average`/`maximum`/`minimum` assenti). Non ho cambiato metrica per tentativi.
  Osservazione collaterale: `Transactions` (`Count`, `Total`) aveva invece dati, es. `2026-10-20T13:05:00Z total=7`, `13:20:00Z total=3`, `13:00:00Z–14:00:00Z total=10`.
- interpretazione: lo Storage Account è stato creato alle 12:47 e non ha ancora subito
  operazioni di scrittura significative sul blob; `UsedCapacity` viene campionato con
  granularità oraria e finché la capacità non varia il punto resta vuoto.
  L'assenza di dati è un fatto da documentare, non un errore della query né del metric definition.

## 6. Alert

- scope: `/subscriptions/48c61ee0-.../resourceGroups/rg-ud07-monitor/providers/Microsoft.Storage/storageAccounts/stud0792490543`
  (singola risorsa, non il Resource Group)
- condition: metrica `Transactions`, aggregazione `Total`, criterio **`DynamicThresholdCriterion`**
  (soglia dinamica, `operator=GreaterOrLessThan`, `threshold=null` → nessuna soglia fissa),
  finestra `PT5M`
- severity: `3`
- evaluation frequency: `PT1M` (`autoMitigate: true`)
- Action Group: presente e collegato → `ag-ud07` (`enabled: true`, 1 ricevitore e-mail)
- Enabled vs Fired: `enabled=true` significa solo che la regola viene **valutata** ogni minuto
  sulla finestra di 5 minuti; passa a **Fired** soltanto se il criterio (soglia dinamica su
  `Transactions`) viene soddisfatto. Una regola correttamente configurata può restare
  per ore in stato Enabled senza mai sparare, quindi "regola configurata" ≠ "alert fired".

## 7. Guasto amministrativo

- sintomo: il comando non restituisce nulla e termina con codice di uscita `3`
- errore:
  ```
  ERROR: (ResourceGroupNotFound) Resource group 'rg-ud07-NON-ESISTE' could not be found.
  Code: ResourceGroupNotFound
  Message: Resource group 'rg-ud07-NON-ESISTE' could not be found.
  ```
- ipotesi: (a) nome scritto male / refuso; (b) subscription o tenant diversi da quelli attesi; (c) RG mai creato o già eliminato
- controllo: verificare contesto ed elenco reali, senza creare nulla:
  ```
  az account show --query "{Sub:name,Id:id}" -o table
  Azure subscription 1  48c61ee0-c3fb-494e-8692-0c74aa2bb390

  az group list --query "[].name" -o table
  NetworkWatcherRG
  rg-ud07-monitor
  rg-ud07-cli-test
  rg-ud07-ps-test
  rg-ud07-auto
  rg-ud07-auto-ps
  ```
  → subscription corretta, `rg-ud07-NON-ESISTE` semplicemente non esiste.
- correzione: **non** creare il RG inesistente; usare il nome corretto di quello già esistente
  (es. `az group show --name rg-ud07-monitor`) oppure, se il RG andava davvero creato, farlo
  esplicitamente con `az group create`
- verifica: `az group show --name rg-ud07-monitor --output table` restituisce la riga dello stato `Succeeded`

## 8. Runbook

### Sintomo

`az group show --name <nome>` fallisce con `ResourceGroupNotFound` / codice `3`,
oppure una risorsa non compare nel Portale.

### Contesto

Subscription, tenant e utente attivi al momento del comando; identità esatta della risorsa.

### Controlli

1. account/subscription
2. nome del Resource Group
3. resource ID / nome della risorsa
4. Activity Log

### Comandi

```bash
# 1. contesto
az account show --query "{Sub:name,Id:id,User:user.name}" -o table

# 2. RG realmente presenti
az group list --query "[].name" -o table

# 3. esistenza puntuale (senza errore rosso)
az group exists --name rg-ud07-monitor
# → true / false

# 4. ID esatto della risorsa
az resource list --resource-group rg-ud07-monitor \
  --query "[].{Name:name,Type:type,Id:id}" -o table

# 5. cosa è successo di recente
az monitor activity-log list --resource-group rg-ud07-monitor \
  --start-time "$(date -u -d '-2 hours' +%Y-%m-%dT%H:%M:%SZ)" \
  --query "[].{Time:eventTimestamp,Operation:operationName.localizedValue,Status:status.value}" \
  -o table
```

### Interpretazione

- `account show` diverso da quello atteso → errore di contesto (subscription/tenant sbagliati): bastano `az account set`.
- `exists = false` ma il nome "sembra" giusto → RG non creato, cancellato o refuso: si controlla l'Activity Log per un evento di eliminazione.
- `exists = true` ma la risorsa non appare → ID/nome errato o risorsa in un altro RG: si usa `az resource list` con l'ID completo.
- L'Activity Log distingue "non è mai esistito" da "è stato eliminato": la `write`/`delete` riuscita è la prova verificabile.

### Correzione minima

Modificare **una sola** variabile per volta (prima subscription, poi nome RG, poi nome risorsa)
e rieseguire il controllo; non creare risorse di "prova" mentre si diagnostica.

### Verifica

Rieseguire lo stesso comando che aveva fallito e ottenere l'output atteso
(`Succeeded` / riga della risorsa), poi confermare con `az group exists` → `true`.

### Cleanup

Eliminare soltanto le risorse create per la diagnosi/la prova, mai la risorsa di produzione:
quindi nessuna cancellazione qui; per la UD07 il cleanup è la sezione 9.

## 9. Cleanup

- rg-ud07-auto: verificati nome, tag (`ManagedBy=Autonomo`, `UD=07`) e contenuto → **vuoto**;
  eliminato con `az group delete --name rg-ud07-auto --yes` → `exists: false`
- rg-ud07-auto-ps: verificati nome, tag (`ManagedBy=PowerShell`, `UD=07`) e contenuto → **vuoto**;
  eliminato con `Remove-AzResourceGroup -Name "rg-ud07-auto-ps" -Force` → `exists: false`
- `rg-ud07-monitor` **non** eliminato (va rimosso solo al termine della verifica individuale,
  vedi `04_VERIFICA.md`).
