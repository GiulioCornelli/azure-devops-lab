# UD13 — Domande concetti

## 1.
**Domanda:** Quale collegamento conserva lo state fra la configurazione Terraform e le risorse Azure? Perché una copia locale diventa problematica nel lavoro condiviso?
**Risposta:** Lo state collega gli oggetti del codice (es. `azurerm_resource_group.lab`) alle risorse reali in Azure e serve a calcolare le modifiche. Una copia locale è problematica nel lavoro condiviso perché copie indipendenti possono divergere e una pipeline non può basarsi sull'unica copia aggiornata sul PC di un collega: serve un backend remoto condiviso.

## 2.
**Domanda:** A che cosa servono backend remoto e locking? Perché usare un backend remoto richiede anche di progettare accessi e protezione dei dati?
**Risposta:** Il backend remoto conserva lo state in una posizione condivisa (su Azure un blob di Storage) usata da tutte le esecuzioni autorizzate. Il locking usa un lease sul blob per evitare aggiornamenti contemporanei dello stesso state, senza eliminare i conflitti tra progetti con state diversi. Serve progettare accessi e protezione perché lo state può contenere valori sensibili e richiede autorizzazioni, recupero e versioning: è il bootstrap del backend.

## 3.
**Domanda:** Come riconosce Terraform una dipendenza implicita? Perché dividere il codice in più file `.tf` non crea automaticamente più moduli?
**Risposta:** Una dipendenza implicita nasce quando un attributo referenzia un'altra risorsa (es. `azurerm_resource_group.lab.name`): Terraform la inserisce nel grafo e ricava un ordine compatibile, eseguendo in parallelo ciò che è indipendente. Più file `.tf` nella stessa directory sono un'unica configurazione, quindi dividerli (es. `network.tf`) non crea moduli: serve un blocco `module` esplicito.

## 4.
**Domanda:** Distingui stage, job e step usando un esempio della pipeline IaC.
**Risposta:** Lo stage è una fase logica (`Validate`), il job è una sequenza di step assegnata a un agent (`IaC`), lo step è una singola operazione (`checkout: self`, `terraform validate`). Nell'esempio `Validate` contiene `IaC`, che gira su `pool-ud09-wsl` ed esegue checkout e script in sequenza; `displayName` rende leggibile lo step nei log. Stage e job possono avere dipendenze e condizioni proprie.

## 5.
**Domanda:** Perché UD13 usa inizialmente il self-hosted agent? Che cosa deve essere disponibile sulla postazione perché il job possa partire ed eseguire i comandi?
**Risposta:** UD13 usa il self-hosted delle UD09–UD12 (`pool-ud09-wsl`, agent su Ubuntu in WSL2) per rendere concreto il rapporto tra pipeline ed esecutore. Per partire servono macchina accesa, WSL disponibile e agent online. Per i comandi servono gli strumenti (`terraform`, Azure CLI) nel processo dell'agent: contano utente, `PATH`, permessi e ambiente; le capability non installano i programmi mancanti.

## 6.
**Domanda:** In un team aziendale, che cosa rappresenta un agent pool? Perché tre agent non garantiscono da soli tre job contemporanei?
**Risposta:** L'agent pool è il gruppo in cui Azure DevOps cerca un agent disponibile; il nome identifica il gruppo, non un singolo computer. Tre agent non bastano per tre job contemporanei perché contano anche i Parallel Jobs disponibili e le dipendenze fra i job, e ogni agent esegue un job alla volta.

## 7.
**Domanda:** Che cosa cambia passando da `pool-ud09-wsl` a `vmImage: ubuntu-latest`, soprattutto per strumenti e persistenza dei file?
**Risposta:** Con `pool-ud09-wsl` usiamo il nostro self-hosted: strumenti mantenuti da noi e file che possono restare tra esecuzioni. Con `ubuntu-latest` Microsoft fornisce una VM nuova per il job: gli strumenti dipendono dall'immagine e dagli step di preparazione, e la VM viene eliminata, quindi i file non persistono e i dati vanno passati con artifact. Cambia la responsabilità sull'ambiente.

## 8.
**Domanda:** Che cosa significa `checkout: self`? Perché un file presente sul nostro PC potrebbe mancare nel checkout della pipeline?
**Risposta:** `checkout: self` recupera il repository associato alla pipeline nella versione scelta per l'esecuzione. Un file del nostro PC può mancare perché la pipeline usa una propria copia nell'area di lavoro dell'agent: se il file non è nel commit eseguito, non compare.

## 9.
**Domanda:** A che cosa servono `Agent.Name`, `Agent.OS` e `Build.SourcesDirectory`? Perché evitare percorsi personali come `~/workspace/azure-devops-lab` nel YAML?
**Risposta:** `$(Agent.Name)` indica l'agent, `$(Agent.OS)` il sistema operativo, `$(Build.SourcesDirectory)` la posizione del checkout; la sintassi `$(...)` è sostituita negli input dei task prima dell'esecuzione. I percorsi personali vanno evitati perché non funzionerebbero su altri agent: `$(Build.SourcesDirectory)/infra/terraform` rende il YAML indipendente dal percorso di chi ha preparato l'agent.

## 10.
**Domanda:** Qual è la differenza fra `workspace` con `clean: all` e il checkout con `clean: true`? Quali dipendenze esterne al workspace rimangono comunque sul self-hosted?
**Risposta:** `workspace: clean: all` pulisce tutto `Pipeline.Workspace` prima del job; `clean: true` pulisce e ripristina solo la copia Git prima del checkout. Operano su ambiti diversi e si possono usare insieme. Restano sul self-hosted le dipendenze esterne al workspace, come Terraform, Azure CLI e gli altri strumenti installati.

## 11.
**Domanda:** A che cosa serve la Azure Pipelines GitHub App? Perché il suo accesso al repository non autorizza anche il deployment Azure?
**Risposta:** La GitHub App autorizza Azure Pipelines a leggere il repository privato per il checkout, limitando l'accesso quando possibile e senza PAT manuale nel YAML. Non autorizza il deployment Azure perché riguarda solo il codice: per creare risorse serve una seconda fiducia, la service connection ARM con identità e ruoli.

## 12.
**Domanda:** A che cosa serve una service connection? Distingui l'autorizzazione della pipeline a usarla dai permessi Azure dell'identità associata.
**Risposta:** Una service connection ARM permette ai task di autenticarsi ad Azure con l'identità prevista per l'automazione, non con una sessione personale. Azure DevOps decide se la pipeline può usare la connessione; Azure decide cosa l'identità può fare tramite i ruoli. Quindi la connessione può essere non autorizzata per la pipeline oppure autorizzata ma con diritti Azure insufficienti.

## 13.
**Domanda:** Quale problema risolve Workload Identity Federation rispetto a un client secret statico? Perché l'autenticazione riuscita non garantisce che ogni operazione sia autorizzata?
**Risposta:** WIF usa un token temporaneo basato su una relazione di fiducia, evitando di conservare un client secret statico a lunga durata. L'autenticazione dice solo «chi sta operando» (verificata da Microsoft Entra); l'autorizzazione dice «cosa può fare» (ruoli e scope Azure). WIF non assegna privilegi da sola e non sostituisce la connessione GitHub.

## 14.
**Domanda:** Perché limitiamo le autorizzazioni al Resource Group di delivery? Perché creare risorse e assegnare ruoli richiedono permessi distinti?
**Risposta:** Limitare i ruoli a `rg-ud13-15-delivery` applica il minimo privilegio: lo scope determina l'ambito e un ruolo sul Resource Group non vale sull'intera subscription. Creare risorse e assegnare ruoli sono operazioni diverse: Contributor crea risorse ma non assegna RBAC da solo, e una pipeline autorizzata solo nel Resource Group non può creare altri Resource Group.

## 15.
**Domanda:** Che cosa fanno `fmt -check`, `init -backend=false` e `validate`? Perché il loro successo non equivale a un deployment Terraform riuscito?
**Risposta:** `fmt -check` verifica la formattazione senza riscrivere i file; `init -backend=false` prepara provider e moduli senza inizializzare il backend, così `validate` può controllare validità e coerenza interna. Non equivalgono a un deployment perché non verificano credenziali, quote, nomi, policy o stato reale: servirebbe `plan` (e `apply`), esclusi dalla pipeline Terraform di questa UD.

## 16.
**Domanda:** Qual è la differenza fra lint Bicep, What-If e deployment? Quale strumento crea l'ACR nella pipeline di questa UD?
**Risposta:** Il lint controlla il codice Bicep; What-If chiede ad Azure una previsione delle modifiche, utile ma non garanzia di successo; il deployment invia la richiesta e ne controlla l'esito. L'ACR è creato dal deployment Bicep; gli step Terraform attestano solo i controlli sulla configurazione.

## 17.
**Domanda:** Che cosa disabilita `trigger: none`? In che cosa differisce la successiva CI collegata a `main`?
**Risposta:** `trigger: none` disabilita il trigger CI sui push, così la pipeline si avvia manualmente; non esclude trigger di pull request o schedulazioni. La CI successiva collegata a `main` avvia invece automaticamente i controlli a ogni push sul branch previsto: il trigger decide quando, gli step cosa fare.

## 18.
**Domanda:** Perché l'ACR viene conservato per UD14? Distingui la creazione del registry, il push dell'immagine e il pull da parte dell'ambiente applicativo.
**Risposta:** L'ACR è conservato perché serve alla CI che pubblicherà l'immagine e alla UD14 che la recupererà con Terraform e Azure Container Apps. Creazione, push e pull sono operazioni distinte con identità potenzialmente diverse: chi crea non coincide necessariamente con chi esegue push o pull, e ognuna richiede le proprie autorizzazioni.

## 19.
**Domanda:** Perché impostiamo `LegacyRegistryPermissions`? Che cosa accadrebbe ai ruoli legacy se il registry fosse configurato nella modalità ABAC?
**Risposta:** `LegacyRegistryPermissions` seleziona il modello RBAC classico del laboratorio, in cui si usano ruoli come `AcrPush` e `AcrPull`; la proprietà non assegna i ruoli, sceglie solo il modello. In modalità ABAC i ruoli legacy `AcrPull`, `AcrPush` e `AcrDelete` non sono riconosciuti: senza adeguare le assegnazioni si interromperebbero push e pull.

## 20.
**Domanda:** Quali risorse vanno eliminate a fine UD13 e quali conservate? Perché il cleanup deve rispettare le dipendenze delle unità successive?
**Risposta:** Si eliminano le risorse Terraform temporanee dell'esercizio; si conservano `rg-ud13-15-delivery`, ACR, service connection, pipeline e agent per la continuità con UD14. Il cleanup deve rispettare le dipendenze perché rimuovere ACR o Resource Group romperebbe CI e deployment successivi; la conservazione comporta costi fino al cleanup conclusivo in UD14.

## 21.
**Domanda:** Quale ordine segui per diagnosticare una pipeline fallita? Come distingui un problema di agent, checkout, directory, autenticazione e autorizzazione Azure?
**Risposta:** Si parte dal primo errore significativo. Ordine: esecuzione assente → trigger/branch; job in attesa → pool, agent, demands, Parallel Jobs; checkout negato → accesso GitHub; cartella mancante → commit, branch, directory dello step; `command not found` → installazione e `PATH` dell'agent; solo poi Azure, distinguendo service connection non autorizzata in Azure DevOps da un'operazione negata da Azure (RBAC, policy, quota, nomi, parametri).
