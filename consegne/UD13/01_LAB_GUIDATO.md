# UD13 — Consegna LAB guidato

## Terraform
- network.tf: aggiunti `vnet-ud13` (10.13.0.0/16) e `snet-app` (10.13.1.0/24), con dipendenze implicite da Resource Group e VNet.
- plan: 4 to add, 0 to change, 0 to destroy (`rg-ud12-tf`, Storage Account `stud13793271778`, `vnet-ud13`, `snet-app`).
- apply: 4 added, 0 changed, 0 destroyed.
- VNet verificata: `vnet-ud13`, address space `10.13.0.0/16`.
- subnet verificata: `snet-app`, prefisso `10.13.1.0/24`.
- destroy: `terraform plan -destroy` mostrava solo le 4 risorse del laboratorio; `terraform destroy` ha eliminato 4 risorse.
- RG Terraform eliminato: sì (`az group exists --name rg-ud12-tf` → `false`).

## Delivery persistente
- Resource Group: `rg-ud13-15-delivery` (westeurope).
- service connection: `sc-azure-ud13-15` (Azure Resource Manager, Workload Identity Federation).
- WIF: sì; App Registration `sc-azure-ud13-15` con federated credential `azure-devops-ud13`, issuer Microsoft Entra `https://login.microsoftonline.com/c52fc17a-5292-4dc7-9c84-2b88ed8db462/v2.0`.
- scope: ruolo `Contributor` assegnato solo a `/subscriptions/48c61ee0-c3fb-494e-8692-0c74aa2bb390/resourceGroups/rg-ud13-15-delivery`.
- accesso globale a tutte le pipeline: NO (`isShared: false`).

## Pipeline
- YAML: `pipelines/azure-pipelines-iac.yml`, versionato e pushato su `main` (commit `66fde72`, "feat: add IaC validation pipeline baseline").
- agent pool: `pool-ud09-wsl` (agent `Legno`, Linux Debian, stato `online`).
- Validate: comandi eseguiti e superati localmente sulla stessa configurazione (`terraform fmt -check`, `terraform init -backend=false`, `terraform validate`, `az bicep lint`); la pipeline non è stata creata/avviata (vedi nota).
- Deploy: non eseguito dalla pipeline; ACR creato con deployment Bicep locale di fallback (`ud13-delivery-fallback`).
- What-If: eseguito localmente in `northeurope`; con `westeurope` Azure rifiutava la creazione dell'ACR ("selected region is currently not accepting new customers").
- deployment: `az deployment group create` → `Succeeded`, ACR `acrud1315kws5mnriekyoq`.
- ACR: `acrud1315kws5mnriekyoq` (login server `acrud1315kws5mnriekyoq.azurecr.io`).
- SKU: `Basic`.
- admin user: `false`.
- roleAssignmentMode: `LegacyRegistryPermissions`.

## Nota su pipeline e GitHub
- La creazione della pipeline da CLI richiede un service connection GitHub, che nel percorso va creato con la **Azure Pipelines GitHub App** tramite autorizzazione interattiva nel browser. Non esistendo ancora tale connessione, `az pipelines create` si interrompe chiedendo un PAT GitHub.
- Per non violare l'indicazione del laboratorio (niente PAT/OAuth manuale nel codice o come credenziale), la pipeline non è stata creata automaticamente.
- La service connection Azure (`sc-azure-ud13-15`) è invece pronta e utilizza WIF con issuer Microsoft Entra.
- L'ACR è stato creato con il fallback locale previsto dal laboratorio, così la continuità verso la preparazione CI e la UD14 è garantita. Questo non va considerato equivalente a una pipeline riuscita.

## Fine UD13
- risorse delivery conservate: sì (`rg-ud13-15-delivery`, ACR, service connection, agent; pipeline non creata).
