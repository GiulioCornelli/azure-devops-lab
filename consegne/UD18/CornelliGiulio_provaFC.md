# UD18 — Prova di consolidamento operativo · Piano B

**90 minuti — 5 verifiche al terminale e 2 quesiti brevi**

Obiettivo: ricostruire le fasi più significative del percorso attraverso il rintracciamento delle informazioni contenute nelle unità didattiche e nei laboratori svolti, verificando i risultati nell’ambiente disponibile.

Nome: Giulio Cornelli  Data: 2026-11-09

Puoi consultare materiali e attività già svolte: individua tu dove cercare. Rispondi in 2–3 righe per quesito, tenendo comandi e output separati. Descrivi operazioni e risultati senza dover citare il percorso formativo. Usa il contesto minikube, namespace ft152-catalogo, con ambiente UD16/UD17 già avviato. Non eseguire deploy, cancellazioni o modifiche. Registra eventuali errori; se l’ambiente impedisce un’operazione, indica il comando che useresti e segnala che il risultato non è stato verificato. Non consegnare credenziali o token.

> Nota di verifica: all’apertura della prova il profilo `minikube` risultava `Stopped`; è stato avviato con `minikube start -p minikube` (nessun deploy, cancellazione o modifica applicativa). Tutte le letture seguenti sono state eseguite il 2026-11-09 dopo il ritorno del nodo a `Ready`.

## Blocco 1 — Stato, configurazione e dati

Tempo indicativo per completare il blocco: **40 minuti**.

### P01 — Immagine e stato

Nel namespace ft152-catalogo individua l’immagine configurata per il backend e controlla lo stato dei suoi Pod. Riporta nome e tag dell’immagine, repliche pronte e un risultato che giustifichi la tua conclusione. Spiega perché la sola immagine configurata nel Deployment non dimostra che il servizio funzioni.

**Risposta:**

L’immagine configurata è `catalog-backend:ud16` e il Deployment riporta `1/1` repliche pronte, con il Pod `Running` e condizione `Ready=True`. La sola immagine nel manifest è uno stato desiderato: non dimostra che il Pod sia stato creato, che l’immagine sia stata scaricata né che il processo risponda, quindi servono stato del Pod e readiness reali.

**Comando o configurazione richiesta:**

```bash
kubectl -n ft152-catalogo get deployment backend -o jsonpath='{.spec.template.spec.containers[*].image}{"\n"}'
kubectl -n ft152-catalogo get pods -l app=backend -o wide
kubectl -n ft152-catalogo rollout status deployment/backend
```

**Risultato osservato (estratto utile):**

```text
catalog-backend:ud16
backend-5cfd7c8c-42t2p   1/1   Running   1   10.244.0.5   minikube
deployment "backend" successfully rolled out
Pod backend-5cfd7c8c-42t2p: Ready=True
```

**Materiale consultato (file e paragrafo):**

`k8s/ud16/backend.yaml` (container `backend`, campo `image`); `consegne/UD16/02_LAB_AUTONOMO.md`, paragrafo «4. Gateway e stato finale».

### P02 — Configurazione

Recupera LOW_STOCK_THRESHOLD dal ConfigMap catalog-config e verifica il valore presente nell’ambiente del container backend. Confronta i due risultati e spiega se modificare il ConfigMap aggiornerebbe automaticamente la variabile nel processo già avviato. Non modificare la configurazione.

**Risposta:**

ConfigMap, variabile del processo e file montato riportano tutti `5`. Modificare la ConfigMap non aggiorna il processo già avviato: `envFrom` viene letto all’avvio del container, quindi serve ricreare il Pod; il file montato può essere aggiornato dal kubelet, ma il programma deve rileggerlo esplicitamente.

**Comando o configurazione richiesta:**

```bash
kubectl -n ft152-catalogo get configmap catalog-config -o jsonpath='{.data.LOW_STOCK_THRESHOLD}{"\n"}'
kubectl -n ft152-catalogo exec deploy/backend -- printenv LOW_STOCK_THRESHOLD
kubectl -n ft152-catalogo exec deploy/backend -- cat /etc/catalog-config/LOW_STOCK_THRESHOLD
kubectl -n ft152-catalogo get deployment backend -o jsonpath='{.spec.template.spec.containers[0].envFrom}{"\n"}'
```

**Risultato osservato (estratto utile):**

```text
ConfigMap: 5
printenv:  5
file:      5
envFrom:   [{"configMapRef":{"name":"catalog-config"}}]
```

**Materiale consultato (file e paragrafo):**

`k8s/ud16/configmap.yaml` (voce `LOW_STOCK_THRESHOLD`); `k8s/ud16/backend.yaml` (`envFrom` e `volumeMounts`); `consegne/UD16/00_DOMANDE_CONCETTI.md`, domande 1–2; `consegne/UD16/02_LAB_AUTONOMO.md`, paragrafo «1. Configurazione: soglia 5 → 10 → 5».

### P03 — Dato persistente

Individua il PVC usato dal backend, verifica dove viene montato e leggi il file del contatore in /runtime. Spiega che cosa dimostrano questi controlli sulla persistenza e quale prova ulteriore servirebbe per verificarla dopo una ricreazione. Non eliminare Pod o volumi e non chiamare l’endpoint del contatore.

**Risposta:**

Il backend usa il PVC `catalog-runtime`, montato in `/runtime`; il file `counter.txt` contiene `2`. Questo dimostra che il volume è montato, scrivibile e leggibile, ma non che il dato sopravviva a una ricreazione: servirebbe ricreare il Pod e rileggere lo stesso file, prova non eseguita perché vietata dalla consegna.

**Comando o configurazione richiesta:**

```bash
kubectl -n ft152-catalogo get deployment backend -o jsonpath='{range .spec.template.spec.volumes[*]}{.name}{" -> "}{.persistentVolumeClaim.claimName}{"\n"}{end}'
kubectl -n ft152-catalogo get deployment backend -o jsonpath='{range .spec.template.spec.containers[0].volumeMounts[*]}{.name}{" -> "}{.mountPath}{"\n"}{end}'
kubectl -n ft152-catalogo get pvc catalog-runtime
kubectl -n ft152-catalogo exec deploy/backend -- cat /runtime/counter.txt
```

**Risultato osservato (estratto utile):**

```text
runtime -> catalog-runtime
runtime -> /runtime
catalog-runtime   Bound   pvc-bee721e4-e751-41a2-b41e-e9927ce505fe   1Gi   RWO   standard
2
```

**Materiale consultato (file e paragrafo):**

`k8s/ud16/backend.yaml` (`volumes` e `volumeMounts`); `k8s/ud16/pvc.yaml`; `consegne/UD16/02_LAB_AUTONOMO.md`, paragrafo «2. Persistenza».

## Blocco 2 — Rete e risposta applicativa

Tempo indicativo per completare il blocco: **30 minuti**.

### P04 — Comunicazione interna

Dal Pod frontend verifica la risoluzione del nome backend. Controlla poi il Service backend e i relativi EndpointSlice: associa almeno un indirizzo a un Pod e alla sua condizione di disponibilità. Spiega perché risolvere il nome non basta a dimostrare che l’applicazione risponda.

**Risposta:**

Dal Pod frontend il nome `backend` risolve a `10.111.116.130`, cioè la ClusterIP del Service. L’EndpointSlice `backend-f8c2x` associa `10.244.0.5` al Pod `backend-5cfd7c8c-42t2p` con `ready=true` e `serving=true`. Il DNS prova solo la risoluzione del nome, non che il processo ascolti sulla porta o restituisca una risposta valida.

**Comando o configurazione richiesta:**

```bash
kubectl -n ft152-catalogo exec deploy/frontend -- getent hosts backend
kubectl -n ft152-catalogo get svc backend -o wide
kubectl -n ft152-catalogo get endpointslice -l kubernetes.io/service-name=backend -o yaml
kubectl -n ft152-catalogo get pods -l app=backend -o wide
```

**Risultato osservato (estratto utile):**

```text
10.111.116.130  backend.ft152-catalogo.svc.cluster.local  backend
selector: app=backend
endpoint: 10.244.0.5  ready=true  serving=true  targetRef Pod/backend-5cfd7c8c-42t2p
Pod backend-5cfd7c8c-42t2p  IP 10.244.0.5  Running
```

**Materiale consultato (file e paragrafo):**

`k8s/ud16/backend-service.yaml` (`selector`); `consegne/UD16/00_DOMANDE_CONCETTI.md`, domanda 4.

### P05 — Accesso HTTP e riscontri

Usa curl per interrogare /health e /api/products/P001 passando dall’accesso locale sulla porta 18016 con Host catalogo.lab. Riporta stato HTTP e un dato utile della risposta; consulta poi gli ultimi log del backend. Se un controllo fallisce, conserva l’errore e indica il controllo successivo pertinente, senza modificare l’ambiente.

**Risposta:**

Entrambe le richieste passano dall’ingresso locale e restituiscono `200`. `/health` riporta `status: ok` e `version: 2.0`; `/api/products/P001` riporta `stock: 8` e `stock_status: OK`. I log del backend mostrano le stesse GET con esito `200`, quindi il percorso ingresso → Gateway → frontend → backend è coerente.

**Comando o configurazione richiesta:**

```bash
curl -sS -H 'Host: catalogo.lab' http://127.0.0.1:18016/health
curl -sS -H 'Host: catalogo.lab' http://127.0.0.1:18016/api/products/P001
kubectl -n ft152-catalogo logs deploy/backend --tail=15
```

**Risultato osservato (estratto utile):**

```text
/health: HTTP 200  {"status":"ok","service":"catalog-backend","version":"2.0"}
P001:    HTTP 200  {"id":"P001","stock":8,"stock_status":"OK"}
log: GET /health 200 - ; GET /api/products/P001 200 -
```

**Materiale consultato (file e paragrafo):**

`accesso/ud16/README.md`, paragrafi «Verifica e ripresa» e «Chiusura»; `accesso/ud16/.env` (`ENTRY_PORT=18016`, `GATEWAY_NODEPORT=30151`); `consegne/UD16/02_LAB_AUTONOMO.md`, paragrafi «3. Service» e «4. Gateway».

## Blocco 3 — Raccontare e motivare le operazioni

Tempo indicativo per completare il blocco: **20 minuti**.

### S01 — Dalla pipeline alla versione in esecuzione

Devi spiegare a un referente tecnico come distribuisci una nuova versione del backend. Ricostruisci il passaggio dal commit alla build, alla pubblicazione in ACR e alla distribuzione; indica quale controllo usi per confermare la versione in esecuzione. Recupera dalla pipeline una configurazione che colleghi questi passaggi.

**Risposta:**

Il commit su `main` avvia la pipeline, lo stage Test esegue gli unit test e BuildPush costruisce e pubblica `catalog-backend:$(Build.BuildId)` su ACR. La distribuzione aggiorna il riferimento immagine al tag appena pubblicato; per confermare la versione confronto il tag nel Deployment e il campo `version` di `/health`. Il collegamento è nella configurazione `imageRepository`, `imageTag: $(Build.BuildId)` e task `Docker@2 buildAndPush` con `sc-acr-ud14`.

**Comando o configurazione richiesta:**

```yaml
variables:
  imageRepository: 'catalog-backend'
  imageTag: '$(Build.BuildId)'
...
- task: Docker@2
  inputs:
    command: buildAndPush
    containerRegistry: '$(dockerRegistryServiceConnection)'
    repository: '$(imageRepository)'
    tags: |
      $(imageTag)
```

```bash
kubectl -n ft152-catalogo get deployment backend -o jsonpath='{.spec.template.spec.containers[*].image}{"\n"}'
curl -sS -H 'Host: catalogo.lab' http://127.0.0.1:18016/health
```

**Risultato osservato (estratto utile):**

```text
Pipeline: stages Test -> BuildPush; tag = $(Build.BuildId)
Esempio UD14: catalog-backend:118 pubblicata su ACR
Lab corrente: Deployment catalog-backend:ud16; /health version 2.0
```

**Materiale consultato (file e paragrafo):**

`pipelines/azure-pipelines-ci.yml` (sezione `variables` e stage `Test`/`BuildPush`); `consegne/UD14/01_LAB_GUIDATO.md`, paragrafi sulla pipeline e «Verifica ACR»; `consegne/UD14/00_DOMANDE_CONCETTI.md`, domanda sul collegamento Build ID → tag → `/health`.

### S02 — Prima di modificare l’infrastruttura

Hai una configurazione Bicep e una Terraform già predisposte. Recupera per ciascuna il comando che permette di esaminare le modifiche previste prima di applicarle. Spiega quale risultato controlleresti dopo l’applicazione e a che cosa serve lo state di Terraform. Non eseguire le modifiche.

**Risposta:**

Per Bicep il comando è `az deployment group what-if`; per Terraform è `terraform plan` (eventualmente con `-out`). Dopo l’applicazione controllerei le output e le risorse attese, per esempio ACR/Container App e la risposta `/health` con la versione. Lo state Terraform mappa il codice alle risorse reali, serve a calcolare il diff ed evitare duplicati o azioni non volute.

**Comando o configurazione richiesta:**

```bash
az deployment group what-if \
  --resource-group "<rg>" \
  --template-file infra/bicep/delivery.bicep \
  --parameters location="northeurope"

cd infra/terraform
terraform plan
```

**Risultato osservato (estratto utile):**

```text
La pipeline IaC esegue az deployment group what-if prima di az deployment group create.
UD12: terraform plan -> No changes; con modifica -> 0 to add, 1 to change, 0 to destroy.
Nessuna modifica applicata durante questa prova.
```

**Materiale consultato (file e paragrafo):**

`pipelines/azure-pipelines-iac.yml`, stage `Deploy` (task `Bicep What-If and deployment`); `infra/bicep/delivery.bicep`; `infra/terraform/main.tf`; `consegne/UD12/02_LAB_AUTONOMO.md`, paragrafi sul `terraform plan`; `consegne/UD13/03_VERIFICA.md`, domanda sullo state; `consegne/UD14/03_VERIFICA.md`, domande su state remoto e `terraform plan` aggiornato.
