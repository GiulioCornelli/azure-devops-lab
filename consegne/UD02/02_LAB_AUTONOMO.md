# Consegna UD02 — Laboratorio autonomo

## Requisito e piano

- requisito interpretato: un gruppo di sviluppo ha bisogno di un ambiente temporaneo con una rete isolata e uno spazio di archiviazione vuoto, separato dagli altri laboratori e eliminabile come un'unica unità. L'ambiente usa la località già verificata (`italynorth`), un resource group dedicato e resource con tag di governance.
- risorse previste: 1 resource group, 1 Virtual Network con 1 subnet, 1 storage account vuoto (`StorageV2`, `Standard_LRS`) con accesso sicuro.
- nomi e tag scelti:
  - resource group `rg-cea-ud02-d5e472dd` in `italynorth`;
  - VNet `vnet-cea-ud02` con spazio `10.30.0.0/16` e subnet `snet-app-auto` con prefisso `10.30.1.0/24`;
  - storage account `stcead5e472dd`;
  - tag usati: `course=cloud-engineer-lab-autonomo`, `unit=UD02`, `enviromment=lab-autonomo`.
- verifiche preliminari: `az version` → CLI 2.74.0; `az account show` → sottoscrizione "Azure subscription 1", stato `Enabled`, `IsDefault=True`; gruppo guidato assente (`az group exists` → `false`); nome storage disponibile (`az storage account check-name` → `NameAvailable=True`).

Nota tecnica di pianificazione: il resource group è il confine del ciclo di vita perché raggruppa risorse che condividono scopo e responsabilità, e la sua eliminazione rimuove insieme rete e storage senza toccare altri laboratori. La località `italynorth` è quella già approvata per il corso. La VNet è uno spazio di rete logico (indirizzamento e subnet), mentre lo storage account è la risorsa che conserva dati persistenti: sono oggetti diversi anche se nello stesso gruppo. I tag servono a inventario, governance e analisi dei costi. Il cleanup sarà dimostrato verificando che il gruppo non esiste più (`az group exists` → `false`) dopo l'eliminazione.

## Svolgimento

Controllo del contesto prima di operare (WSL):

```text
az account show --query "{Name:name,State:state,IsDefault:isDefault}" --output table
Name                  State    IsDefault
--------------------  -------  -----------
Azure subscription 1  Enabled  True
```

Inventario delle risorse presenti nel resource group (CLI):

```text
az resource list -g rg-cea-ud02-d5e472dd \
  --query "[].{Name:name,Type:type,Location:location,Unit:tags.unit,Environment:tags.enviromment}" --output table
Name            Type                                     Location    Unit    Environment
--------------  ---------------------------------------  ----------  ------  ------------
vnet-cea-ud02   Microsoft.Network/virtualNetworks        italynorth  UD02    lab-autonomo
stcead5e472dd   Microsoft.Storage/storageAccounts        italynorth  UD02    lab-autonomo
```

Verifica della rete (VNet e subnet):

```text
az network vnet show -g rg-cea-ud02-d5e472dd -n vnet-cea-ud02 \
  --query "{Address:addressSpace.addressPrefixes,Subnets:subnets[].{Name:name,Prefix:addressPrefix}}" --output jsonc
{
  "Address": ["10.30.0.0/16"],
  "Subnets": [{ "Name": "snet-app-auto", "Prefix": "10.30.1.0/24" }]
}
```

Verifica delle proprietà di sicurezza dello storage account:

```text
az storage account show -g rg-cea-ud02-d5e472dd -n stcead5e472dd \
  --query "{Kind:kind,Sku:sku.name,Https:enableHttpsTrafficOnly,MinTls:minimumTlsVersion,PublicBlob:allowBlobPublicAccess}" --output jsonc
{
  "Https": true,
  "Kind": "StorageV2",
  "MinTls": "TLS1_2",
  "PublicBlob": false,
  "Sku": "Standard_LRS"
}
```

Confronto portale/CLI: `az resource list` restituisce 2 risorse (`virtualNetworks` + `storageAccounts`) nello stesso gruppo. La verifica indipendente nel portale (Gruppo di risorse → Panoramica) deve mostrare lo stesso insieme di due risorse.

Resource ID anonimizzati:

```text
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-cea-ud02-d5e472dd
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-cea-ud02-d5e472dd/providers/Microsoft.Network/virtualNetworks/vnet-cea-ud02
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-cea-ud02-d5e472dd/providers/Microsoft.Storage/storageAccounts/stcead5e472dd
```

## Diagnosi

- errore o anomalia analizzata: l'ambiente creato non coincide in ogni punto con lo scenario richiesto. Differenze rilevate rispetto ai requisiti:
  - il nome del resource group è `rg-cea-ud02-d5e472dd` invece di un nome con prefisso `rg-cea-ud02-auto-`;
  - la VNet si chiama `vnet-cea-ud02` invece di `vnet-cea-auto`;
  - la subnet è `snet-app-auto` con prefisso `10.30.1.0/24` invece di `snet-workload` con `10.30.10.0/24`;
  - i tag sono `course=cloud-engineer-lab-autonomo`, `unit=UD02`, `enviromment=lab-autonomo`: mancano `environment=dev`, `scenario=autonomous` e `deleteAfter`, e la chiave `enviromment` è scritta con una "m" in più rispetto a `environment`.
- ipotesi: i nomi e i tag sono stati ripresi dal laboratorio guidato anziché dallo scenario autonomo.
- controllo: `az resource list` mostra il nome del gruppo e delle risorse; `az network vnet show` mostra la subnet reale; `az group show` mostra i tag effettivi del gruppo (chiave `enviromment`).
- correzione: da valutare con il docente. Se lo scenario richiede i nomi `rg-cea-ud02-auto-*`, `vnet-cea-auto`, `snet-workload` (`10.30.10.0/24`) e i tag `environment`/`scenario`/`deleteAfter`, occorre ricreare la rete con i nomi corretti (la VNet vuota può essere ricreata; attenzione a non lasciare due reti). La chiave tag va scritta `environment`.
- verifica successiva: ripetere le stesse query di lettura e confrontare prefissi, nomi e tag con i requisiti.

## Cleanup e consegna

- risorse eliminate: da eseguire a cura dello studente (resource group `rg-cea-ud02-d5e472dd`).
- controllo finale: da completare (`az group delete` → `az group wait --deleted` → `az group exists` atteso `false`).
- hash abbreviato e messaggio del commit: da completare dopo il commit.

## Registro cronologico delle evidenze

| Data/ora | Fase e contesto | Comando o pagina | Risultato reale ripulito | Interpretazione / passo successivo |
|---|---|---|---|---|
| 2026-10-13 18:00 | Verifica contesto — WSL | `az version` / `az account show --query {Name,State,IsDefault}` | 2.74.0; Azure subscription 1, Enabled, True | Contesto corretto, si può operare |
| 2026-10-13 18:00 | Prerequisito guidato — WSL | `az group exists -n <gruppo guidato>` | `false` | Gruppo guidato assente, prerequisito soddisfatto |
| 2026-10-13 18:00 | Verifica nome storage — WSL | `az storage account check-name -n stcead5e472dd` | `NameAvailable: True` | Nome disponibile |
| 2026-10-13 18:04 | Inventario risorse — WSL | `az resource list -g rg-cea-ud02-d5e472dd --query [].{Name,Type,Location,Unit,Environment}` | 2 risorse: vnet-cea-ud02, stcead5e472dd | Entrambe nel gruppo e in italynorth |
| 2026-10-13 18:04 | Proprietà rete — WSL | `az network vnet show ... --query addressSpace/subnets` | `10.30.0.0/16`; subnet `snet-app-auto` `10.30.1.0/24` | Prefissi leggibili; subnet con nome/prefisso diversi dai requisiti |
| 2026-10-13 18:04 | Proprietà sicurezza storage — WSL | `az storage account show ... --query {Kind,Sku,Https,MinTls,PublicBlob}` | StorageV2, Standard_LRS, Https True, TLS1_2, PublicBlob false | Requisiti di sicurezza dello storage soddisfatti |
| 2026-10-13 18:04 | Tag — WSL | `az group show -n rg-cea-ud02-d5e472dd --query tags` | `unit=UD02`, `course=cloud-engineer-lab-autonomo`, `enviromment=lab-autonomo` | Tag parziali: chiave `enviromment` con refuso, mancano environment/scenario/deleteAfter |

Riporta le proprietà e l'inventario prima dell'eliminazione, poi richiesta, attesa e assenza finale. Per l'autonomo motivazioni e requisiti. Nella conferma finale cita un commit già pubblicato, non l'hash del documento che stai ancora modificando.
