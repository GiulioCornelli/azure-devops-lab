# UD14 — Domande concetti

## 1. Qual è la differenza tra CI e Continuous Delivery?
**Risposta:** La CI (Continuous Integration) verifica che il codice superi i test, che l'immagine si costruisca e che possa essere pubblicata. La Continuous Delivery aggiunge la fase di distribuzione: controlla che l'artefatto sia deployabile, che l'infrastruttura sia coerente, che l'applicazione parta e che l'endpoint risponda con la versione attesa.

## 2. Quale service connection utilizza la pipeline UD14?
**Risposta:** Usa `sc-azure-ud13-15`, una Azure Resource Manager service connection basata su Workload Identity Federation. All'interno di `AzureCLI@2` permette di eseguire `az`, Terraform e Docker senza memorizzare password o client secret nel repository.

## 3. Perché la pipeline non utilizza `Docker@2`?
**Risposta:** `Docker@2` è un task valido, ma per accedere a un registry richiede una Docker Registry service connection separata. L'architettura UD14 vuole usare solo la service connection ARM già disponibile, quindi esegue `az acr login`, `docker build` e `docker push` dentro `AzureCLI@2`.

## 4. Quale ruolo deve avere l'identità della pipeline sull'ACR?
**Risposta:** L'identità di `sc-azure-ud13-15` deve avere il ruolo `AcrPush` sul registry, perché la pipeline deve pubblicare le immagini ma non ha bisogno di altri permessi.

## 5. Perché Terraform usa uno state remoto?
**Risposta:** Lo state locale sarebbe fragile: ogni job usa `workspace: clean: all` e una nuova run non deve dipendere dai file rimasti sul self-hosted Agent. Lo state remoto permette a job e run diverse di lavorare sulla stessa infrastruttura e offre anche il locking dello state.

## 6. Dove viene conservato lo state UD14?
**Risposta:** In Azure Storage, nel container `tfstate` e nel blob `ud15.tfstate`, tramite il backend `azurerm`. Lo storage viene preparato prima, perché Terraform non può usare come backend una risorsa che non esiste ancora.

## 7. Quale ruolo permette alla pipeline di utilizzare lo state Blob?
**Risposta:** `Storage Blob Data Contributor` sul container `tfstate`, assegnato alla stessa identità di `sc-azure-ud13-15`, così la pipeline può leggere e scrivere lo state.

## 8. Come si autentica Terraform durante la pipeline?
**Risposta:** I comandi Terraform girano dentro `AzureCLI@2`: la service connection autentica Azure con Workload Identity Federation e Terraform riutilizza la sessione Azure CLI già attiva. Non vengono inserite credenziali nei file `.tf`.

## 9. Quali risorse vengono lette come esistenti?
**Risposta:** Resource Group, Azure Container Registry e user-assigned managed identity. Sono già presenti dalle unità precedenti e Terraform le legge tramite data source, evitando di importarle nello state UD14.

## 10. Quali risorse vengono gestite da Terraform?
**Risposta:** Container Apps Environment e Container App, cioè le risorse introdotte dalla UD14. La Container App usa registry privato ACR, managed identity, ingress esterno e target port 8000.

## 11. Perché la Container App utilizza una managed identity?
**Risposta:** Per separare l'identità di delivery da quella di runtime e applicare il minimo privilegio: la pipeline pubblica le immagini, mentre l'applicazione deve solo leggerle dal registry.

## 12. Quale ruolo ha questa identità sull'ACR?
**Risposta:** La managed identity `id-ud15-acrpull` ha il ruolo `AcrPull`, sufficiente per scaricare l'immagine senza poter pubblicare.

## 13. Perché viene eseguito `terraform plan` nello stage iniziale?
**Risposta:** Per eseguire `init`, `fmt -check`, `validate` e `plan` prima della build, così errori di configurazione emergono presto. Il piano può già riferirsi al nuovo Build ID anche se l'immagine non è ancora pubblicata.

## 14. Perché viene ricreato il piano nello stage Deploy?
**Risposta:** Perché tra il primo plan e il deploy lo stato è cambiato (la build ha pubblicato la nuova immagine). Serve quindi un piano fresco sullo state aggiornato prima di applicare il risultato.

## 15. Che relazione esiste tra Build ID, tag e `APP_VERSION`?
**Risposta:** Lo stesso Build ID viene usato come tag dell'immagine e come valore di `APP_VERSION`, così si può tracciare la catena run Azure DevOps → Build ID → tag ACR → Container App → `/health`.

## 16. Perché uno smoke test può fallire dopo un apply riuscito?
**Risposta:** Un `terraform apply` riuscito significa solo che Azure ha accettato la configurazione prevista, non che l'applicazione funzioni. Lo smoke test verifica FQDN, `/health`, risposta HTTP e versione attesa, quindi può fallire per porta sbagliata o avvio non corretto.

## 17. Perché `workspace: clean: all` rende importante lo state remoto?
**Risposta:** Perché ogni job parte da un workspace pulito e non può contare su file locali lasciati dall'agent. Lo state deve quindi stare fuori dall'agent, in Blob Storage, per essere condiviso tra job e run.

## 18. Che cosa dimostra l'errore sulla target port?
**Risposta:** Dimostra la differenza tra infrastruttura applicata e servizio funzionante: modificando `targetPort` da `8000` a `9999`, Terraform applica correttamente la nuova configurazione e il deploy riesce, ma lo smoke test fallisce perché l'applicazione non risponde.

## 19. Che cosa elimina `terraform destroy` a fine UD14?
**Risposta:** Elimina solo le risorse gestite dallo state UD14, cioè Container Apps Environment e Container App. Viene eseguito da una pipeline dedicata prima di rimuovere le risorse condivise provenienti dalle unità precedenti.
