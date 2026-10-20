# UD07 — Consegna laboratorio guidato

## CLI

- prima esecuzione script:
```
Il Resource Group non esiste: lo creo.
Location    Name
----------  ----------------
westeurope  rg-ud07-cli-test

Aggiorno i tag...

Stato finale:
Name              Location    State
----------------  ----------  ---------
rg-ud07-cli-test  westeurope  Succeeded
```
Risultato raggiunto

- seconda esecuzione:
```
Il Resource Group esiste già: lo riutilizzo.

Aggiorno i tag...

Stato finale:
Name              Location    State
----------------  ----------  ---------
rg-ud07-cli-test  westeurope  Succeeded
```
Risultato raggiunto

- comportamento idempotente:
che al riesegure per la seconda volta lo stesso script, non riesegue comandi gia' utilzzati, cosi' da non compromettere, in questo cosao lo stato delle risorse.

- esempio JMESPath:
- quando usare `tsv`: bisogna utilizzare `tsv` nel momento in cui si vuole iterare su un valore e asseglarlo ad una variabile d'ambiente o ad uno script bash...

## PowerShell

- `Get-AzContext` verificato:
```
SubscriptionName      Account   Environment
----------------      -------   -----------
Azure subscription 1  MSI****   AzureCloud
```

- Resource Group test:
- prima esecuzione: 
ha creato il resource group 
```
ResourceGroupName Location   ProvisioningState Tags
----------------- --------   ----------------- ----
rg-ud07-ps-test   westeurope Succeeded         {[UD, 07], [State, Verified], [ManagedBy, PowerShell]}
```

- seconda esecuzione: non ne ha creato una ltro 
- perché il controllo `if` è utile: perche' ti permette di gestire le condizioni, nel moenmto in cui la variabile (in queto caso `$rg`) sia vera o falsa.

## Log Analytics

- workspace:
```
Name           Location     State
-------------  -----------  ---------
law-ud07-3522  northeurope  Succeeded
```
- regione: la region che mi ha funzionionato e' la `northeurope`

- query `print`:
```        
Course    Status    TableName      UD
--------  --------  -------------  ----
AZ-104    OK        PrimaryResult  7
```

- query `datatable`:
```
Count    Status    TableName
-------  --------  -------------
2        OK        PrimaryResult
1        WARN      PrimaryResult
```

- risultato sintetico:

## Activity Log

- evento osservato: `Update resource group`
- status: `Succeeded`

- timestamp:
```
Time                          Operation              Status
----------------------------  ---------------------  ---------
2026-10-20T12:16:26.974811Z   Update resource group  Succeeded
2026-10-20T12:16:25.4747305Z  Update resource group  Started
2026-10-20T10:56:25.4018349Z  Create Workspace       Succeeded
2026-10-20T10:56:04.3694322Z  Create Workspace       Accepted
2026-10-20T10:56:03.931907Z   Create Workspace       Started
2026-10-20T10:54:49.0103001Z  Create Workspace       Failed
2026-10-20T10:54:48.7915553Z  Create Workspace       Started
2026-10-20T10:53:53.0484221Z  Create Workspace       Failed
2026-10-20T10:53:53.0484221Z  'deny' Policy action.  Failed
2026-10-20T10:53:53.0171785Z  Create Workspace       Started
```
- dati personali omessi: sì

## Diagnostic Setting

- esito:
```
-----------------------------
Name                  Workspace
--------------------  ---------------------------------------------------------------------------------------------------------------------------------------------------
ud07-activity-to-law  /subscriptions/XXXXXXXX/resourceGroups/rg-ud07-monitor/providers/Microsoft.OperationalInsights/workspaces/law-ud07-3522
```
- destinazione:
```
/subscriptions/XXXXXXXX
```
- AzureActivity disponibile: sì | `AzureActivity non ancora popolata nel time range osservato.`

- fallback usato, se necessario:

## Metrics

- Storage Account:
```
AccessTier    AllowBlobPublicAccess    AllowCrossTenantReplication    CreationTime                      EnableHttpsTrafficOnly    Kind       Location     MinimumTlsVersion    Name            PrimaryLocation    ProvisioningState    ResourceGroup    StatusOfPrimary
------------  -----------------------  -----------------------------  --------------------------------  ------------------------  ---------  -----------  -------------------  --------------  -----------------  -------------------  ---------------  -----------------
Hot           False                    False                          2026-10-20T12:47:21.485267+00:00  True                      StorageV2  northeurope  TLS1_0               stud0792490543  northeurope        Succeeded            rg-ud07-monitor  available
```

- metrica:
```
Metric
---------------------
UsedCapacity
Transactions
Ingress
Egress
SuccessServerLatency
SuccessE2ELatency
Availability
ReplicationLagSeconds
MigrationProgress  
```

- unità:
```
Unit
------------
Bytes
Count
Bytes
Bytes
MilliSeconds
MilliSeconds
Percent
Seconds
Percent
```

- aggregazione:

- punto dati disponibile: sì

- interpretazione:
```
Timestamp             Name
--------------------  -------------
2026-10-20T11:53:00Z  Used capacity
```
## Alert

- nome: `ag-ud07`
- scope corretto: sì
- condition: 
```
Aggregation type: Total
Operator: Greater than
Threshold value: 0
```
- severity: `3`
- Action Group: presente
- perché non è necessario che sia Fired: Perché in questa UD l'obiettivo è verificare che la regola sia costruita correttamente, non che scatti. Lo scatto dipende dal superare la soglia nelle finestre di valutazione. Può non avvenire subito o per niente senza che la regola sia sbagliata.

## Correlazione

- modifica osservata:
- evento Activity Log:
```
Time                          Operation                      Status
----------------------------  -----------------------------  ---------
2026-10-20T12:47:42.613429Z   Create/Update Storage Account  Succeeded
2026-10-20T12:47:24.6708743Z  Create/Update Storage Account  Accepted
2026-10-20T12:47:21.1552529Z  Create/Update Storage Account  Started
```
- la correlazione prova causalità?:No
- motivazione:La correlazione mostra solo che gli eventi sono avvenuti in sequenza (modifica → alert). Provare la causalità servirebbe evidenza in più: cosa è stato modificato, nesso tecnico con la metrica, log coerenti, rollback che ripristina il comportamento, riproducibilità.
