# UD14 — Verifica finale

## 1.
**Domanda:** Qual è la causa più probabile dello scenario con `Deploy` riuscito e `Smoke` fallito?
**Risposta:** Il mismatch tra la `targetPort` dell'ingress di Container Apps (`9999`) e la porta su cui l'applicazione ascolta (`8000`). Terraform applica la configurazione, ma il traffico viene inoltrato alla porta sbagliata.

## 2.
**Domanda:** Quali componenti non modificheresti?
**Risposta:** Service connection, ruoli `AcrPush`/`AcrPull`, managed identity, Storage dello state, Agent e ACR. Il problema è solo nella configurazione della target port della Container App.

## 3.
**Domanda:** Se `terraform init` fallisce con 403 sul Blob Storage dello state, quale autorizzazione controlli?
**Risposta:** Il ruolo `Storage Blob Data Contributor` sul container `tfstate`, assegnato all'identità di `sc-azure-ud13-15`.

## 4.
**Domanda:** Perché non devi spostare lo state nel repository come soluzione?
**Risposta:** Perché lo state può contenere valori sensibili, non va versionato in Git e con `workspace: clean: all` ogni run partirebbe da un workspace pulito. Deve restare su backend remoto con locking.

## 5.
**Domanda:** Se `BuildPush` fallisce su `az acr login` o `docker push`, quale service connection e quale ruolo controlli?
**Risposta:** Controllo `sc-azure-ud13-15` e il ruolo `AcrPush` sull'ACR per l'identità associata.

## 6.
**Domanda:** Perché non abiliti l'admin user dell'ACR?
**Risposta:** Perché l'autenticazione avviene con Workload Identity Federation e RBAC, senza password statiche. Abilitare l'admin user ridurrebbe la sicurezza e non sarebbe necessario.

## 7.
**Domanda:** Se `apply` riesce ma `/health` restituisce una versione diversa dal Build ID atteso, quali elementi confronti?
**Risposta:** Build ID della run, tag dell'immagine in ACR, immagine referenziata dalla Container App, valore `APP_VERSION` nella configurazione e risposta `/health`.

## 8.
**Domanda:** Distingui Continuous Integration e Continuous Delivery.
**Risposta:** La CI verifica test, build e pubblicazione dell'immagine. La Continuous Delivery aggiunge infrastruttura, deploy e verifica dell'endpoint, portando l'artefatto in esecuzione.

## 9.
**Domanda:** Perché UD14 utilizza uno state remoto?
**Risposta:** Perché i job usano `workspace: clean: all` e run diverse devono condividere lo stesso stato. Il backend remoto garantisce coerenza e locking.

## 10.
**Domanda:** Perché lo Storage Account dello state viene preparato prima del laboratorio?
**Risposta:** Perché Terraform non può inizializzare un backend `azurerm` su una risorsa che non esiste ancora.

## 11.
**Domanda:** Come si autentica Terraform nella pipeline?
**Risposta:** Terraform gira dentro `AzureCLI@2` con `sc-azure-ud13-15` (Workload Identity Federation) e riutilizza la sessione Azure CLI attiva, senza credenziali nei file `.tf`.

## 12.
**Domanda:** Quali risorse sono data source e quali sono gestite da Terraform?
**Risposta:** Data source: Resource Group, ACR e user-assigned managed identity. Gestite: Container Apps Environment e Container App.

## 13.
**Domanda:** Perché il piano viene eseguito anche prima della build?
**Risposta:** Per validare la configurazione e rilevare errori presto, prima di costruire e pubblicare l'immagine.

## 14.
**Domanda:** Perché viene ricreato nello stage Deploy?
**Risposta:** Perché dopo `BuildPush` lo stato è cambiato; serve un piano aggiornato sullo state corrente prima dell'`apply`.

## 15.
**Domanda:** Perché la pipeline utilizza `AzureCLI@2` invece di `Docker@2`?
**Risposta:** Per usare una sola service connection ARM (`sc-azure-ud13-15`) al posto di una Docker Registry service connection separata, eseguendo `az acr login`, `docker build` e `docker push` nella stessa sessione.

## 16.
**Domanda:** Quale ruolo ha la pipeline sull'ACR?
**Risposta:** `AcrPush`.

## 17.
**Domanda:** Quale ruolo ha la managed identity della Container App?
**Risposta:** `AcrPull`.

## 18.
**Domanda:** Perché `workspace: clean: all` non deve cancellare lo state della delivery?
**Risposta:** Perché lo state è in Azure Blob Storage, fuori dal `Pipeline.Workspace` dell'agent.

## 19.
**Domanda:** Che cosa viene eliminato da `terraform destroy` alla fine?
**Risposta:** Solo Container Apps Environment e Container App, cioè le risorse gestite dallo state UD14.

## Cleanup finale

- pipeline Terraform destroy: eseguita (`azure-pipelines-cleanup.yml`)
- Container App rimossa: sì (`catalog-api-ud15`)
- Environment rimosso: sì (`acaenv-ud15`)
- Resource Group eliminato: sì (`rg-ud13-15-delivery`)
- service connection rimosse: sì (`sc-azure-ud13-15`, `sc-acr-ud14`)
- Agent deregistrato: sì (`pool-ud09-wsl` / `Legno`)
- repository conservato: sì

## Appendice — Verifica CI (04_VERIFICA_CI)

1. **Perché Test deve precedere BuildPush?** Perché se i test falliscono non ha senso costruire e pubblicare un'immagine non validata.
2. **Che cosa significa pipeline verde?** Che tutti i controlli previsti sono stati superati, non che il software sia privo di bug.
3. **Perché usiamo `Build.BuildId` come tag?** Per tracciare run, immagine, Container App e `/health`; `latest` non identifica la provenienza.
4. **Quale service connection usa `Docker@2`?** `sc-acr-ud14`, la Docker Registry service connection della CI; nella CD integrata si usa invece `AzureCLI@2` con `sc-azure-ud13-15`.
5. **Perché l'admin user dell'ACR può restare disabilitato?** Perché l'autenticazione usa Workload Identity Federation, senza password statiche.
6. **Se Test fallisce, ha senso controllare i permessi ACR?** No, lo stage Test non interagisce con ACR.
7. **Quale evento attiva la CI?** Un push su `main`, incluso il merge di una PR.
8. **Perché non eseguiamo cleanup al termine del blocco CI?** Perché l'immagine in ACR è l'input della Continuous Delivery.
9. **Perché Microsoft-hosted è il percorso principale?** Per usare VM temporanee fornite da Microsoft, modello standard della CI.
10. **Perché due Job Microsoft-hosted non devono condividere file locali?** Perché ogni Job gira su una VM diversa e temporanea.
11. **Quando si usa il fallback self-hosted?** Quando Microsoft-hosted non è disponibile per grant, billing, policy o disponibilità.
12. **Perché `workspace: clean: all` è importante sul self-hosted?** Perché l'agent è persistente e file di run precedenti potrebbero inquinare il workspace.
13. **Distingui Agent e Docker Registry service connection.** L'Agent fornisce l'ambiente di esecuzione e gli strumenti; la service connection fornisce l'autenticazione al registry.
14. **Perché controlliamo `python3 --version` e `docker --version`?** Per verificare la disponibilità degli strumenti e distinguere problemi d'ambiente da problemi applicativi o di autorizzazione.

### Gate verso il blocco CD
- UD14_AGENT_MODE: `MICROSOFT_HOSTED`
- pipeline CI riuscita: sì
- ACR: `acrud1315kws5mnriekyoq`
- repository `catalog-backend`: presente
- tag Build ID: `116`, `117`
- `sc-azure-ud13-15`: presente
- `sc-acr-ud14`: presente
