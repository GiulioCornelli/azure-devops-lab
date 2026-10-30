# UD13 — Evidenze preparazione Continuous Integration

- Percorso repository usato: `/home/giulio/Corsi/Corso-Azure/azure-devops-lab` (branch `main`, remote `github.com:GiulioCornelli/azure-devops-lab.git`).
- Resource Group e nome ACR (senza credenziali): `rg-ud13-15-delivery`; ACR `acrud1315kws5mnriekyoq` (login server `acrud1315kws5mnriekyoq.azurecr.io`, SKU `Basic`, admin user `false`, `roleAssignmentMode=LegacyRegistryPermissions`, location `northeurope`).
- Esito dei 3 test locali: `python3 -m unittest discover -s app/catalog-backend-ci/tests -v` → 3 test eseguiti, `OK`.
- Build Docker locale ed esito `/health`: `docker build -t catalog-backend:ud13-local app/catalog-backend-ci` riuscita; container avviato su `127.0.0.1:18014`; `/health` → `{"status":"ok","service":"catalog-backend","version":"ci-v1"}`; container fermato con `docker stop`.
- Stato di `sc-acr-ud14` e WIF: creata come service connection `dockerregistry` verso l'ACR; autenticazione Workload Identity Federation con issuer Microsoft Entra (`https://login.microsoftonline.com/c52fc17a-5292-4dc7-9c84-2b88ed8db462/v2.0`), App Registration `sc-acr-ud14` e federated credential `azure-devops-ud14-acr`; ruolo `AcrPush` assegnato sullo scope dell'ACR; `isShared: false` (nessun accesso automatico a tutte le pipeline).
- Modalità agent scelta (`MICROSOFT_HOSTED` oppure `SELF_HOSTED_FALLBACK`): `MICROSOFT_HOSTED`, coerentemente con lo stato `MICROSOFT_HOSTED_READY` registrato in UD09/UD12.
- YAML CI utilizzato: `pipelines/azure-pipelines-ci.yml` (Microsoft-hosted, `vmImage: ubuntu-latest`). Il fallback `pipelines/azure-pipelines-ci-selfhosted.yml` è comunque versionato e disponibile.
- Nome della sola pipeline CI: `ud13-catalog-ci` (nome previsto; pipeline non creata, vedi blocco reale).
- Prima run (ID, esito osservato o blocco reale): non eseguita. Blocco reale: manca l'autorizzazione interattiva della **Azure Pipelines GitHub App** al repository; `az pipelines create` richiede un PAT GitHub e si interrompe con `NoTTYException` in ambiente non interattivo. Non è stato creato alcun PAT/OAuth manuale, come indicato dal laboratorio.
- Stage Test (esito): non eseguito dalla pipeline. I comandi equivalenti sono stati eseguiti localmente con esito positivo: `python3 --version` e i 3 test unittest (`OK`).
- Stage BuildPush (esito): non eseguito dalla pipeline. Build Docker locale riuscita; push in ACR non eseguito, quindi nessuna immagine è stata pubblicata dalla CI.
- Traccia dei log `Agent.Name` / `OS` / `MachineName`: non disponibile perché la pipeline non è stata creata/eseguita. L'agent self-hosted di fallback `Legno` (Linux Debian) risulta `online`; il percorso Microsoft-hosted non è stato osservato.
- Stato finale e azioni rinviate alla nuova UD14: ACR con `LegacyRegistryPermissions`, service connection `sc-acr-ud14` con WIF e ruolo `AcrPush`, YAML CI e app `catalog-backend-ci` versionati (commit `8d4f58f`, poi `5bd5f96` per escludere i bytecode Python). Restano da fare in UD14: creare/authorize la pipeline CI tramite Azure Pipelines GitHub App, eseguire la prima run, verificare il tag basato su `Build.BuildId` e l'immagine in ACR, quindi procedere con la Continuous Delivery Terraform.

## Nota
- Nessun cleanup eseguito: Resource Group, ACR, service connection, agent e YAML sono conservati per la UD14.
- L'ACR è in `northeurope` perché `westeurope` risultava chiusa ai nuovi clienti per la creazione del registry in questa subscription.
