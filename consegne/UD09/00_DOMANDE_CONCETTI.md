# UD09 — Risposte alle domande sui concetti

## 1.
Perché DevOps non può essere ridotto a un prodotto?
**Risposta:**
DevOps è un insieme di **principi e pratiche**, non un prodotto. Un tool (Azure DevOps, GitHub, Jenkins) può supportarle ma non sostituirle. La domanda corretta è prima "quale pratica devo implementare?" e poi "quale strumento uso?".

## 2.
Quali sono le tre dimensioni principali che abbiamo associato a DevOps?
**Risposta:**
- **Cultura**: collaborazione, responsabilità condivisa, feedback.
- **Processi**: planning, versioning, review, test, release, operation.
- **Tecnologia**: Git, pipeline, container, IaC, monitoring, security automation.

Se ne manca una, l'automazione diventa solo "una sequenza più veloce di errori".

## 3.
Perché il lifecycle DevOps è rappresentato come un ciclo?
**Risposta:**
Perché monitoraggio e feedback non sono la fine del progetto: producono informazioni (bug, incidenti, metriche, richieste utenti) che **tornano alla pianificazione** e generano nuovo lavoro. È la freccia `MONITOR/FEEDBACK → PLAN` che rende il lifecycle iterativo.

## 4.
Distingui Agile e DevOps.
**Risposta:**
- **Agile**: come il team pianifica e sviluppa valore in cicli brevi e adattivi (backlog, sprint, incrementi).
- **DevOps**: estende la continuità del lavoro a integrazione, test, delivery, deployment, operation e feedback operativo.

Sono complementari: Agile senza delivery automatizzata, o automazione senza cultura Agile, sono incompleti.

## 5.
Che cos'è un backlog?
**Risposta:**
Una **lista ordinata di lavoro da realizzare** (funzionalità, bug, debito tecnico, attività). Non è solo una lista di cose da fare: gli elementi vengono descritti, prioritizzati, stimati, raffinati e selezionati per le iterazioni successive.

## 6.
Che cos'è uno sprint?
**Risposta:**
Un **intervallo di tempo breve e definito** in cui il team realizza un insieme selezionato di elementi del backlog. La logica: scegliere lavoro gestibile → realizzarlo → verificarlo → ricevere feedback → adattare il ciclo successivo.

## 7.
Distingui Scrum e Kanban.
**Risposta:**
- **Scrum**: framework con ruoli (Product Owner, Scrum Master, Development Team), eventi e artefatti, organizzato in sprint timeboxed.
- **Kanban**: approccio che rende visibile il flusso (board con colonne, card) e limita il sovraccarico tramite i **WIP limit**.

Kanban fa emergere il collo di bottiglia; Scrum fissa cadenze e ruoli.

## 8.
Distingui Epic, Feature, User Story, Task e Bug.
**Risposta:**
- **Epic**: iniziativa molto ampia.
- **Feature**: capacità significativa del prodotto.
- **User Story**: necessità dal punto di vista dell'utente.
- **Task**: attività tecnica concreta per implementarla.
- **Bug**: difetto rilevato.

Gerarchia in Azure Boards (processo Agile): `Epic → Feature → User Story → Task/Bug`.

## 9.
A che cosa servono gli Acceptance Criteria?
**Risposta:**
A definire le **condizioni verificabili** che la funzionalità deve soddisfare, in stile Gherkin (dato / quando / allora), così da tradurre il requisito in test automatico. Sono diversi dalla **Definition of Done**, che è il criterio generale del team (review, test superati, pipeline verde, documentazione aggiornata).

## 10.
Perché il Version Control è importante anche per IaC e pipeline YAML?
**Risposta:**
Perché infrastruttura e pipeline **sono codice**: versionarle dà diff, review, tracciabilità, rollback e rilasci ripetibili. Si versionano anche Dockerfile, Bicep, Terraform, configurazioni e documentazione.

## 11.
Distingui build e artifact.
**Risposta:**
- **Build**: processo che trasforma il sorgente in qualcosa eseguibile (compilazione, bundle, `docker build`).
- **Artifact**: il *risultato* della build, destinato alla fase successiva (JAR, ZIP, package, container image).

Regola: `SOURCE → BUILD → ARTIFACT → DELIVERY`, con lo **stesso artifact validato** che attraversa gli ambienti.

## 12.
Distingui unit test, integration test e smoke test.
**Risposta:**
- **Unit test**: verifica una piccola unità di codice in isolamento.
- **Integration test**: verifica l'interazione tra componenti (API ↔ database).
- **Acceptance test**: verifica i criteri attesi da business/utente.
- **Smoke test**: controllo rapido post-deployment ("il servizio è raggiungibile?"); in UD14 sull'endpoint `/health`.

## 13.
Che cosa significa shift-left?
**Risposta:**
Spostare i controlli **il più presto possibile** nel ciclo: intercettare l'errore sul PC, nella PR, nella CI, in test, invece che in produzione. Un bug trovato prima è più semplice da localizzare, meno costoso e meno rischioso.

## 14.
Definisci Continuous Integration.
**Risposta:**
La pratica di **integrare frequentemente** le modifiche nella base condivisa e di sottoporle automaticamente a build e test: `commit/PR → repository → pipeline CI → build → test → artifact`. L'obiettivo è il feedback frequente, non "una build automatica al mese".

## 15.
Distingui Stage, Job e Step.
**Risposta:**
- **Stage**: fase logica (Test, Build, Deploy, Smoke).
- **Job**: insieme di step eseguito su un agent.
- **Step**: singola operazione (es. `python3 -m unittest`).

Gerarchia: `Pipeline → Stage → Job → Step`, e in esecuzione `Job → Agent → comando reale`.

## 16.
Distingui Continuous Delivery e Continuous Deployment.
**Risposta:**
- **Continuous Delivery**: il software è sempre rilasciabile e il percorso build/test/deploy è automatizzato, ma la produzione può richiedere approvazione esplicita.
- **Continuous Deployment**: ogni modifica che supera i gate arriva in produzione **automaticamente**, senza approvazione manuale.

## 17.
Distingui Dockerfile, image e container.
**Risposta:**
- **Dockerfile**: istruzioni per costruire l'immagine (file versionabile).
- **Image**: artifact immutabile risultante dalla build.
- **Container**: istanza in esecuzione dell'image.

## 18.
Che cos'è un registry?
**Risposta:**
Un servizio che **conserva e distribuisce container image**: `build → image locale → push → registry → pull → runtime`. Noi usiamo **ACR** (Azure Container Registry). Non va confuso con Azure Artifacts, che ospita package (NuGet, npm, Maven…).

## 19.
Che problema risolve un orchestrator?
**Risposta:**
Automatizza la gestione di molti container: scheduling, repliche, self-healing, service discovery, rolling update e scaling. L'esempio principale è **Kubernetes**; noi useremo **Azure Container Apps**, che permette di lavorare con container senza amministrare un cluster.

## 20.
Che cos'è Infrastructure as Code?
**Risposta:**
Descrivere infrastruttura e configurazioni in **file versionabili** (Bicep, Terraform) invece di ricordare i click nel portale: `file → review → versioning → pipeline → deployment ripetibile`. Introdotta operativamente nelle UD12–UD13.

## 21.
Che cosa aggiunge DevSecOps al lifecycle?
**Risposta:**
Integra la **sicurezza nel lifecycle** invece di trattarla come controllo finale: least privilege, secret management, dependency e image scanning, policy as code, branch protection, service connection limitate. Nel corso: niente PAT Full access, niente token nei repository.

## 22.
Che cos'è una DevOps toolchain?
**Risposta:**
L'**insieme coordinato di strumenti** usati nel lifecycle, non un singolo prodotto. La nostra: Boards (planning), GitHub (version control), Azure Pipelines (CI/CD), Agent (execution), Docker, ACR, Bicep/Terraform, Azure Container Apps, Azure Monitor. È *una possibile* toolchain, non "la" toolchain.

## 23.
Quali sono i cinque principali servizi Azure DevOps?
**Risposta:**
**Azure Boards** (planning/tracking), **Azure Repos** (Git, PR, branch policy), **Azure Pipelines** (build, test, packaging, deployment), **Azure Test Plans** (test manuali ed esplorativi), **Azure Artifacts** (package feed). Azure DevOps non "è DevOps": è una piattaforma che implementa strumenti per pratiche DevOps.

## 24.
A che cosa serve Azure Boards?
**Risposta:**
Al **planning e tracking** del lavoro: Work Items, Backlogs, Boards, Sprints, Queries, Dashboard. Supporta i processi Basic, Agile, Scrum, CMMI; nel progetto della UD09 scegliamo **Agile**, che determina tipi di work item e workflow. Scegliere Agile non significa "la classe fa Scrum".

## 25.
Perché nel corso usiamo GitHub invece di Azure Repos?
**Risposta:**
Perché **GitHub è il repository sorgente autorevole** e le pipeline future operano sul suo codice. Duplicare lo stesso codice in Azure Repos introdurrebbe confusione, sincronizzazione inutile e rischio di divergenza. Azure Repos resta da conoscere, ma non lo usiamo.

## 26.
Distingui Azure Test Plans e test automatici in pipeline.
**Risposta:**
- **Azure Test Plans**: *test management* di casi di test manuali ed esplorativi (test plan, suite, esecuzioni, risultati).
- **Test automatici in pipeline**: eseguiti da Azure Pipelines a ogni build/deploy come step, con esito pass/fail che blocca o prosegue il flusso.

## 27.
Distingui Azure Artifacts e Azure Container Registry.
**Risposta:**
- **Azure Artifacts**: package management (feed NuGet, npm, Maven, Python, Universal Packages).
- **ACR**: container image registry (conserva e distribuisce immagini).

## 28.
Distingui Organization e Project.
**Risposta:**
- **Organization**: contenitore amministrativo superiore; contiene più Project e ospita utenti, billing, parallel jobs, pool condivisi, sicurezza.
- **Project**: spazio di lavoro interno che contiene o collega Boards, Repos, Pipelines, Test Plans, Artifacts, Service Connections.

Noi creiamo il Project `az900-az104-devops`, visibility **Private**.

## 29.
Distingui Agent, Agent Pool e Parallel Job.
**Risposta:**
- **Agent**: esegue materialmente il job (1 job alla volta).
- **Agent Pool**: insieme di agent (es. `pool-ud09-wsl`); unità organizzativa e confine di autorizzazione.
- **Parallel Job**: quanti job possono girare contemporaneamente (limite di capacità/billing).

3 agent Online + 1 parallel job = 1 job alla volta.

## 30.
Distingui Microsoft-hosted e self-hosted Agent.
**Risposta:**
- **Microsoft-hosted**: ambiente temporaneo gestito da Microsoft, tool preinstallati, `vmImage: ubuntu-latest`; viene **ricreato a ogni job**.
- **Self-hosted**: gira su macchina gestita da noi, con controllo sui tool e ambiente persistente, ma patch/sicurezza/disponibilità a nostro carico.

Noi: self-hosted su Ubuntu/WSL2 (UD09) e Microsoft-hosted verificato/abilitato.

## 31.
Che cos'è una Service Connection?
**Risposta:**
Un **collegamento autenticato** tra Azure DevOps e un sistema esterno (GitHub, Azure Resource Manager, ACR). Va distinta la sua esistenza dall'uso effettivo: per questo evitiamo "Grant access permission to all pipelines" e autorizziamo solo le pipeline necessarie.

## 32.
Perché il PAT di registrazione può essere revocato dopo che l'agent è Online?
**Risposta:**
Il PAT serve **solo alla registrazione** (`./config.sh`); dopo, l'agent autentica con credenziali proprie e continua a ricevere job. Sequenza: PAT breve (scope minimo `Agent Pools Read & manage`) → registra → verifica Online → **revoca** → verifica che resti Online. Se la policy vieta i PAT: Device Code Flow (AAD), non Full access.

## 33.
Perché DevOps non coincide con Azure DevOps?
**Risposta:**
Le pratiche DevOps non appartengono a un produttore: version control, CI, testing, pipeline, artifact, CD, IaC, container e monitoring si implementano con strumenti diversi. Azure DevOps è **una possibile piattaforma** tra le altre.

## 34.
Qual è la differenza tra Azure Pipelines e Azure Pipelines Agent?
**Risposta:**
Livelli diversi:
- **Azure Pipelines**: la piattaforma che **orchestra** il lavoro (quando, dove, in che ordine).
- **Azure Pipelines Agent**: l'esecutore che **esegue** materialmente i comandi degli step sul proprio OS.

L'agent non decide quando distribuire o quali test siano validi: lo fanno la pipeline e la progettazione del processo.

## 35.
Qual è la relazione concettuale tra Azure Pipelines Agent, Jenkins Agent, GitHub Runner e GitLab Runner?
**Risposta:**
Sono **tutti e quattro lo stesso livello**: l'esecutore sotto la rispettiva piattaforma.

```text
piattaforma/controller → Job → worker/agent/runner → esecuzione
```

| Piattaforma | Esecutore |
|---|---|
| Azure Pipelines | Azure Pipelines Agent |
| Jenkins | Jenkins Agent |
| GitHub Actions | Runner (hosted o self-hosted) |
| GitLab CI/CD | GitLab Runner (gestiti o self-managed) |

Il confronto corretto è piattaforma vs piattaforma, ed esecutore vs esecutore: confrontare un agent con una piattaforma è un errore di livello.

## 36.
Quali attività svolgerà concretamente l'Agent nelle UD13–UD14?
**Risposta:**
- **UD13**: validazioni IaC (`bicep build`, `terraform init`/`validate`), i primi Job di pipeline, preparazione dei test CI.
- **UD14**: test Python, `docker build`, `docker push` su ACR, deployment (`az deployment group create`) e smoke test della pipeline integrata (`curl` su `/health`).

## 37.
Perché un Job Microsoft-hosted non dovrebbe dipendere da file lasciati dal Job precedente?
**Risposta:**
Perché l'ambiente hosted è **temporaneo e ricreato a ogni job**: non c'è persistenza. Lo stato va quindi **esternalizzato** (artifact pubblicati o immagini in ACR) e recuperato dal job successivo, non lasciato su disco.

## 38.
Perché il WSL2 personale del corso non rappresenta la topologia self-hosted tipica di un team?
**Risposta:**
Perché nel laboratorio l'agent gira nel **WSL2 del partecipante**: è un self-hosted reale ma una **simulazione didattica** di un build host aziendale. In realtà gli sviluppatori fanno solo `commit → push` e l'infrastruttura agent è gestita dall'organizzazione (VM Linux/Windows in Azure, on-premises, altro cloud). Decisivo non è *dove* è la macchina, ma **chi la gestisce**.

## 39.
Come può essere organizzato un Agent Pool aziendale?
**Risposta:**
Raggruppando agent per finalità: pool per team, per tecnologia (Linux/Windows), per ambiente (build, test, deploy) o per criticità, con agent dotati di capability adatte (Agent.OS, git, Docker, Terraform). Il pool è anche **confine di autorizzazione**: si possono limitare le pipeline autorizzate e separare agent di produzione da quelli di sviluppo. In Azure DevOps Services i pool sono risorse organizzative condivisibili tra progetti.

## 40.
Perché più Agent non implicano automaticamente più Job eseguibili in parallelo?
**Risposta:**
Perché **Agent** (chi esegue) e **Parallel Job** (quanti job contemporaneamente) sono grandezze diverse: il parallel job dipende dalla capacità/billing dell'Organization. Ogni job in esecuzione consuma un slot: 3 agent + 1 parallel job = 1 job alla volta; per la concorrenza servono **più agent + sufficiente capacità di Parallel Jobs**.
