# UD12 — Consegna LAB guidato

## Preparazione

- materiali UD12: /home/giulio/Corsi/Corso-Azure/resources/azure-devops-k8s-01/UD12/partecipanti
- repository personale: /home/giulio/Corsi/Corso-Azure/azure-devops-lab
- directory `infra/bicep`: /home/giulio/Corsi/Corso-Azure/azure-devops-lab/infra/bicep
- directory `infra/terraform`: /home/giulio/Corsi/Corso-Azure/azure-devops-lab/infra/terraform
- directory consegne: /home/giulio/Corsi/Corso-Azure/azure-devops-lab/consegne/UD12

## Azure

- subscription verificata: Azure subscription 1 (giulio.cornelli05@gmail.com)
- identità verificata: giulio.cornelli05@gmail.com

## Bicep

- Bicep version: Bicep CLI version 0.48.1 (cec7951cf6)
- lint: az bicep lint eseguito su infra/bicep/main.bicep (nessun errore)
- Resource Group: rg-ud12-bicep (northeurope)
- Storage Account: st3182802
- What-If change type: Create (Microsoft.Storage/storageAccounts)
- deployment: ud12-bicep-deploy - Succeeded (2026-10-28T10:20:29.238624+00:00)
- output `storageAccountName`: st3182802
- output `blobEndpoint`: https://st3182802.blob.core.windows.net/
- verifica CLI: az storage account list -g rg-ud12-bicep mostra st3182802 (StorageV2, northeurope, TLS1_2, AllowBlobPublicAccess=False, Succeeded)
- Resource Group Bicep eliminato: no (mantenuto per verifica)
- `az group exists`: true

## Terraform

- Terraform version: Terraform v1.17.0
- provider AzureRM: hashicorp/azurerm ~> 5.4
- `terraform init`: Success! (creati .terraform/ e .terraform.lock.hcl)
- `terraform fmt -check`: nessuna differenza
- `terraform validate`: Success! The configuration is valid.
- plan add: 2 to add (azurerm_resource_group.lab, azurerm_storage_account.lab)
- plan change: 0
- plan destroy: 0 (piano applicato)
- apply: Apply complete! Resources: 2 added, 0 changed (azurerm_resource_group.lab creato, azurerm_storage_account.lab creato)
- output Resource Group: rg-ud12-tf
- output Storage: stt3183440
- verifica CLI: rg-ud12-tf (northeurope), stt3183440 (Standard_LRS, northeurope, TLS1_2) - corrispondenti a Terraform
- `terraform state list`: azurerm_resource_group.lab, azurerm_storage_account.lab

## Fine LAB guidato

- risorse Terraform mantenute per LAB autonomo: sì
