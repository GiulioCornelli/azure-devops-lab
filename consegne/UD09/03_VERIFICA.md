# UD09 — Verifica individuale

## Parte A — Scelta singola

### 1. DevOps è principalmente:
- A. un prodotto Microsoft
- B. un insieme di cultura, pratiche e tecnologie che collegano sviluppo, delivery e operation
- C. un sinonimo di Docker
- D. un linguaggio YAML

**Risposta:** B. DevOps è un modello di lavoro fatto di cultura, processi e tecnologia; i prodotti come Azure DevOps sono solo strumenti che lo supportano.

### 2. Agile e DevOps:
- A. sono esattamente la stessa cosa
- B. sono incompatibili
- C. Agile riguarda soprattutto lavoro iterativo/adattivo; DevOps estende il flusso a delivery e operation
- D. DevOps sostituisce il Version Control

**Risposta:** C. Agile organizza il lavoro in cicli brevi e adattivi; DevOps collega quegli stessi cicli a integrazione, delivery, deployment e operation.

### 3. Un backlog è:
- A. un elenco ordinato di lavoro da realizzare
- B. un file di log
- C. un container registry
- D. un Agent Pool

**Risposta:** A. Il backlog è una lista ordinata e prioritizzata di elementi (feature, bug, debito tecnico) da raffinare e selezionare per le iterazioni.

### 4. Continuous Integration significa principalmente:
- A. distribuire automaticamente ogni commit in produzione
- B. integrare frequentemente e verificare automaticamente build/test
- C. creare una VM
- D. fare code review senza test

**Risposta:** B. La CI integra spesso le modifiche nella base comune e le sottopone automaticamente a build e test, per ottenere feedback rapido.

### 5. Un artifact è:
- A. soltanto codice sorgente
- B. un risultato di build destinato a una fase successiva
- C. un utente Azure DevOps
- D. una permission

**Risposta:** B. L'artifact è l'output della build (JAR, package, immagine container) che viene usato nelle fasi successive di delivery.

### 6. Continuous Deployment si distingue dalla Continuous Delivery perché:
- A. non usa pipeline
- B. può portare automaticamente in produzione ogni modifica che supera i gate previsti
- C. non esegue test
- D. richiede sempre un deployment manuale

**Risposta:** B. Nella Continuous Delivery il rilascio in produzione può richiedere un'approvazione; nel Continuous Deployment avviene automaticamente se tutti i gate sono superati.

### 7. Un container registry conserva principalmente:
- A. User Story
- B. container image
- C. sprint
- D. log KQL

**Risposta:** B. Il registry è il servizio che conserva e distribuisce le immagini container (nel corso ACR).

### 8. Un orchestrator serve principalmente a:
- A. gestire scheduling, repliche, scaling e lifecycle di workload containerizzati
- B. creare commit Git
- C. scrivere User Story
- D. generare PAT

**Risposta:** A. L'orchestrator automatizza scheduling, repliche, self-healing, scaling e rolling update; Kubernetes ne è l'esempio principale.

### 9. Azure Boards supporta principalmente:
- A. planning e tracking del lavoro
- B. container image
- C. gestione NSG
- D. DNS

**Risposta:** A. Azure Boards gestisce work item, backlog, board e sprint, cioè il planning e il tracking del lavoro.

### 10. Nel nostro percorso il repository sorgente rimane:
- A. Azure Repos
- B. GitHub
- C. Azure Artifacts
- D. Log Analytics

**Risposta:** B. GitHub resta l'unica fonte di verità per codice e Pull Request; Azure Repos non viene usato per evitare duplicazioni.

### 11. Un agent è:
- A. la capacità/licenza di concorrenza
- B. il processo/macchina che esegue un job
- C. un backlog
- D. un Work Item

**Risposta:** B. L'agent è l'esecutore materiale dei Job della pipeline, cioè il processo che lancia i comandi su una macchina.

### 12. Un parallel job rappresenta:
- A. la capacità di eseguire job contemporaneamente
- B. la versione dell'agent
- C. una branch
- D. un container

**Risposta:** A. Il parallel job è la capacità di concorrenza: quanti Job possono girare nello stesso momento, indipendentemente dal numero di agent.

## Parte B — Risposte brevi

### 13. Distingui Scrum e Kanban.

**Risposta:** Scrum è un framework con ruoli (Product Owner, Scrum Master, Development Team), eventi e artefatti, organizzato in sprint timeboxed. Kanban è invece un approccio che rende visibile il flusso su una board (TO DO → IN PROGRESS → REVIEW → DONE) e limita il lavoro in corso tramite i WIP limit, senza iterazioni fisse. Scrum dà cadenze e ruoli, Kanban fa emergere collo di bottiglia e sovraccarico.

### 14. Distingui Epic, Feature, User Story e Task.

**Risposta:** L'Epic è un'iniziativa molto ampia (es. digitalizzare un processo); la Feature è una capacità significativa del prodotto; la User Story descrive una necessità dal punto di vista dell'utente; il Task è l'attività tecnica concreta necessaria per implementarla. In Azure Boards formano una gerarchia: Epic → Feature → User Story → Task.

### 15. Distingui build e artifact.

**Risposta:** La build è il processo che trasforma il sorgente in qualcosa di eseguibile o distribuibile (compilazione, bundle, immagine container). L'artifact è il risultato di quel processo, destinato a una fase successiva: l'idea è che lo stesso artifact validato attraversi gli ambienti, senza ricostruzioni diverse.

### 16. Distingui unit test, integration test e smoke test.

**Risposta:** Lo unit test verifica una piccola unità di codice in isolamento; l'integration test verifica l'interazione tra più componenti (es. API e database); lo smoke test è un controllo rapido dopo il deployment per verificare che il servizio sia raggiungibile e le funzioni essenziali rispondano.

### 17. Che cosa significa shift-left?

**Risposta:** Significa spostare i controlli il prima possibile nel ciclo: sul PC, nella Pull Request, nella CI, nell'ambiente di test, invece di scoprire gli errori solo in produzione. Un bug trovato prima è più semplice da localizzare, meno costoso e meno rischioso.

### 18. Distingui Stage, Job e Step.

**Risposta:** Lo Stage è una fase logica della pipeline (Test, Build, Deploy); il Job è un insieme di step eseguito su un agent; lo Step è la singola operazione (es. `python3 -m unittest`). La gerarchia è Pipeline → Stage → Job → Step.

### 19. Distingui Azure Repos, Azure Pipelines, Azure Test Plans e Azure Artifacts.

**Risposta:** Azure Repos ospita repository Git con branch e Pull Request; Azure Pipelines automatizza build, test e deployment; Azure Test Plans gestisce test manuali ed esplorativi; Azure Artifacts è un feed di package (NuGet, npm, Maven). Nel corso usiamo operativamente solo Azure Pipelines, mentre gli altri restano a livello concettuale.

### 20. Distingui Organization, Project, Agent Pool e Agent.

**Risposta:** L'Organization è il contenitore amministrativo superiore (utenti, billing, parallel jobs); il Project è lo spazio di lavoro interno che contiene Boards, Repos e Pipelines; l'Agent Pool è il gruppo di agent; l'Agent è il singolo esecutore dei Job.

### 21. Distingui Microsoft-hosted e self-hosted Agent.

**Risposta:** Il Microsoft-hosted è un ambiente temporaneo gestito da Microsoft, con tool preinstallati e ricreato a ogni Job; il self-hosted gira su una macchina gestita da noi, ha ambiente persistente e tool sotto controllo, ma richiede di gestire patch, sicurezza e disponibilità.

### 22. Perché `Grant access permission to all pipelines` non è la scelta predefinita consigliabile?

**Risposta:** Perché concede l'uso di una risorsa (service connection, pool) a tutte le pipeline senza controllo. È preferibile autorizzare esplicitamente solo le pipeline che ne hanno bisogno, applicando il principio del least privilege e riducendo la superficie di rischio.

### 23. Perché il PAT di registrazione dell'agent può essere revocato dopo la configurazione?

**Risposta:** Perché il PAT serve solo durante `config.sh` per registrare l'agent nel pool. Dopo la registrazione l'agent usa le proprie credenziali, quindi continua a risultare Online anche dopo la revoca: è la dimostrazione pratica del least privilege.

### 24. Azure Pipelines e Azure Pipelines Agent sono la stessa cosa? Spiega la differenza.

**Risposta:** No, sono livelli diversi. Azure Pipelines è la piattaforma che orchestra il lavoro e decide quando e dove eseguirlo; Azure Pipelines Agent è l'esecutore materiale che lancia i comandi degli step sul proprio sistema operativo. L'agent non decide autonomamente cosa testare o quando distribuire.

### 25. Associa correttamente:

```text
Azure Pipelines
Jenkins
GitHub Actions
GitLab CI/CD
```

con:

```text
Azure Pipelines Agent
Jenkins Agent
Runner
GitLab Runner
```

**Risposta:**

| Piattaforma | Esecutore |
|---|---|
| Azure Pipelines | Azure Pipelines Agent |
| Jenkins | Jenkins Agent |
| GitHub Actions | Runner |
| GitLab CI/CD | GitLab Runner |

In tutti e quattro i casi la piattaforma orchestra i Job e l'esecutore (agent/runner) li esegue materialmente.

### 26. Perché Jenkins viene citato nella UD09 anche se non lo utilizzeremo operativamente?

**Risposta:** Perché dimostra che pipeline, job, agent, build, test e deployment sono concetti DevOps generali, non caratteristiche esclusive di Azure DevOps. Lo stesso modello si ritrova in Jenkins, GitHub Actions e GitLab CI/CD, con nomi diversi per gli esecutori.

### 27. Quali compiti svolgerà concretamente un Agent nelle UD13–UD14?

**Risposta:** In UD13 l'Agent eseguirà le validazioni IaC (`bicep build`, `terraform init`/`validate`) e i primi Job di pipeline, preparando i test CI. In UD14 eseguirà i test Python, il `docker build`, il `docker push` su ACR, il deployment e lo smoke test finale sull'endpoint `/health`.

### 28. Perché prepariamo sia self-hosted sia Microsoft-hosted?

**Risposta:** Perché i due modelli hanno caratteristiche complementari: il self-hosted offre controllo sui tool e una baseline certa, il Microsoft-hosted offre ambienti puliti, ripetibili e senza manutenzione. Prepararli entrambi permette di scegliere il modello adatto e di confrontarne vantaggi e limiti nelle UD successive.

## Parte C — Scenario

> Il portale mostra `agent-wsl-01 Offline`. La registrazione era stata completata correttamente e il PAT è già stato revocato. In WSL2 nessun processo `run.sh` è attivo.

### 29. Qual è la prima causa da verificare e quale azione eseguiresti?

**Risposta:** La prima causa è che il processo dell'agent non è in esecuzione: senza `run.sh` l'agent risulta Offline anche se la registrazione è valida. L'azione è avviare `./run.sh` dalla directory dell'agent (`$AGENT_DIR`) e verificare nel portale che torni Online; solo se resta Offline passerei a controllare rete, URL dell'Organization e pool.

### 30. Perché non creeresti subito un nuovo PAT e non riconfigureresti l'agent?

**Risposta:** Perché fermare il processo non cancella configurazione né credenziali: la registrazione è ancora valida e serve solo riavviarla. Creare un nuovo PAT o rieseguire `config.sh` sarebbe inutile, aggiungerebbe una credenziale da gestire e aumenterebbe il rischio senza risolvere il problema.

## Parte D — Mappa finale

| Area | Strumento del percorso |
|---|---|
| Planning | Azure Boards (concettuale) |
| Version Control | GitHub |
| CI/CD | Azure Pipelines |
| Container | Docker |
| Registry | Azure Container Registry (ACR) |
| IaC | Bicep + Terraform |
| Runtime | Azure Container Apps |
| Monitoring | Azure Monitor |
