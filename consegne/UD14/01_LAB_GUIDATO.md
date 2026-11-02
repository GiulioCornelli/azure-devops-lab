# UD14 — Consegna LAB guidato

## Controlli iniziali
- ACR: `acrud1315kws5mnriekyoq` (login server `acrud1315kws5mnriekyoq.azurecr.io`, northeurope, SKU Basic, admin user `false`)
- `LegacyRegistryPermissions`: sì (`roleAssignmentMode = LegacyRegistryPermissions`)
- `sc-azure-ud13-15`: presente, Azure Resource Manager con Workload Identity Federation, non condivisa con tutte le pipeline
- `AcrPush`: assegnato al Service Principal di `sc-azure-ud13-15` sull'ACR
- Storage state: `sttf1548c61ee0c3fb494e` (StorageV2, Standard_LRS, northeurope)
- container state: `tfstate`
- `Storage Blob Data Contributor`: assegnato sul container `tfstate` all'identità di `sc-azure-ud13-15`
- managed identity: `id-ud15-acrpull`
- `AcrPull`: assegnato a `id-ud15-acrpull` sull'ACR
- Agent: `pool-ud09-wsl`, agent `Legno` (Linux Debian), Online

## Terraform
- init: completato con provider `hashicorp/azurerm` 5.4.0 e backend `azurerm`
- validate: `Success! The configuration is valid.`
- plan iniziale: `2 to add, 0 to change, 0 to destroy` (`acaenv-ud15`, `catalog-api-ud15`)
- apply: `2 added, 0 changed, 0 destroyed`
- state remoto: `ud15.tfstate` nel container `tfstate` dello Storage Account `sttf1548c61ee0c3fb494e`, con locking tramite lease del blob

## Pipeline
- Build ID: `118`
- IaC: riuscito (`terraform init`, `fmt -check`, `validate`, `plan`)
- Test: riuscito (3 test unittest, `OK`)
- BuildPush: riuscito (`az acr login`, `docker build`, `docker push` di `catalog-backend:118`)
- Deploy: riuscito (`terraform plan` + `apply`, 2 risorse aggiunte)
- Smoke: riuscito (`/health` risponde con `version = 118`)

## Deployment
- image tag: `118`
- FQDN: `catalog-api-ud15.mangohill-7c4e5a91.northeurope.azurecontainerapps.io`
- APP_VERSION: `118`
- revision: `catalog-api-ud15--5f7c9b2d` (Active, Healthy, replicas 1)
- health: `{"status":"ok","service":"catalog-backend","version":"118"}`

## Verifica CI (02_LAB_GUIDATO)
- `UD14_AGENT_MODE`: `MICROSOFT_HOSTED`
- `Agent.Name`: `fv-az1284-73`
- `Agent.OS`: `Linux`
- step che esegue i test: `Stage Test` → `Job PythonTests` → `Run Python tests`
- step che costruisce l'immagine: `Stage BuildPush` → `Job DockerBuild` → `Build and push to ACR` (`Docker@2`)
- tag pubblicato: `116`

## Verifica ACR
- repository: `catalog-backend`
- tag presenti (time_desc): `118`, `116`
- immagine distribuita: `acrud1315kws5mnriekyoq.azurecr.io/catalog-backend:118`
