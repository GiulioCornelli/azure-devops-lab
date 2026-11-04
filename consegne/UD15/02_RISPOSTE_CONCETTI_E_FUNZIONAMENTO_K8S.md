# UD15 — Risposte ai concetti e al funzionamento di Kubernetes

Riferimento: laboratorio `web-intro`, namespace `ft152-ud15`.

## A. Manifest, API e dati del cluster

### Q01

**Domanda:** Che differenza c'è fra il file deployment.yaml sul PC, l'oggetto Deployment nel cluster e il processo Nginx in esecuzione?

**Risposta:** Il file YAML sul PC è solo testo con lo stato desiderato. Il Deployment nel cluster è il record salvato in etcd (`spec` + `status`), non esegue nulla. Il processo Nginx è l'esecuzione reale in un container di un Pod su un nodo. Catena: file → API Server/etcd → Deployment controller → ReplicaSet → Pod → kubelet → runtime → Nginx.

### Q02

**Domanda:** Quale ruolo svolge l'API Server quando viene applicato un manifest? Perché la risposta created non dimostra che l'applicazione risponda già via HTTP?

**Risposta:** L'API Server autentica, autorizza, valida, salva l'oggetto in etcd e notifica i controller; non avvia container. `created` significa solo che l'oggetto è stato accettato: scheduler, kubelet e runtime devono ancora agire, e il Pod può restare in `ImagePullBackOff` o non essere `Ready`. Serve una prova reale (`rollout status`, readiness, curl via Service/port-forward).

### Q03

**Domanda:** Quale problema risolve etcd? Fra specifica del Deployment, immagini complete, stato API del Pod, memoria di Nginx e file applicativi di un volume, che cosa vi viene conservato?

**Risposta:** etcd è il datastore distribuito e coerente del cluster: garantisce durabilità e concorrenza dello stato e permette watch/recupero del control plane. Conserva oggetti API: spec del Deployment, immagini complete, stato del Pod, Service ed EndpointSlice. Non conserva la memoria di Nginx né i file del volume: stanno sul nodo o sullo storage del volume.

## B. Oggetti e componenti di controllo

### Q04

**Domanda:** Che cos'è un Pod? Quale vantaggio offre rispetto alla descrizione di un semplice processo? Può contenere più container?

**Risposta:** Il Pod è la più piccola unità distribuibile: uno o più container con stesso IP, `localhost`, IPC e volumi, schedulati insieme. Rispetto a un processo semplice offre ciclo di vita gestito, probe, limiti, label, volumi e ricreazione. Sì, può contenere più container (sidecar; gli `init` girano prima).

### Q05

**Domanda:** Quali problemi risolvono Deployment e ReplicaSet? Perché nel laboratorio compaiono entrambi?

**Risposta:** Il Deployment gestisce applicazioni stateless in modo dichiarativo: scaling, rolling update, rollback e revisioni. Il ReplicaSet mantiene il numero desiderato di Pod identici. Nel laboratorio compaiono entrambi perché il Deployment crea un ReplicaSet, e il ReplicaSet crea i Pod; ogni revisione ha il suo ReplicaSet (`pod-template-hash`).

### Q06

**Domanda:** Qual è la differenza fra un oggetto Deployment e il controller del Deployment? Che cosa significa riconciliazione?

**Risposta:** L'oggetto Deployment è il record in API/etcd con `spec`, `status` e revisioni. Il controller è il processo in `kube-controller-manager` che lo osserva e crea/aggiorna i ReplicaSet. Riconciliazione è il ciclo continuo osserva → confronta col desiderato → agisci, finché lo stato reale converge.

### Q07

**Domanda:** Quali ruoli hanno scheduler, kubelet e runtime nell'avvio di un Pod? Quale di questi sceglie il nodo?

**Risposta:** Lo scheduler sceglie il nodo e scrive il binding. Il kubelet, agente del nodo, monta volumi, fa scaricare l'immagine, avvia i container, esegue le probe e riporta lo stato. Il runtime (containerd/CRI-O) esegue pull e avvio dei processi. Solo lo scheduler sceglie il nodo.

## C. Service e destinatari di rete

### Q08

**Domanda:** Quale problema risolve un Service se i Pod possiedono già un indirizzo IP? Perché collegare un client direttamente all'IP di un Pod può diventare fragile?

**Risposta:** Il Service dà un IP/DNS stabile e bilancia il traffico verso i Pod selezionati, includendo solo quelli pronti. L'IP di un Pod è effimero: cambia se il Pod viene ricreato e non è pensato per l'accesso diretto. Collegarsi all'IP di un Pod è fragile perché il Pod può sparire, lo scaling cambia l'insieme, mancano nome stabile e load balancing.

### Q09

**Domanda:** Si consideri un Deployment chiamato sito-nginx, i cui Pod hanno label app: web-intro, e un Service chiamato accesso-web con selector app: web-intro. Se sono nello stesso namespace, la differenza dei nomi impedisce il collegamento? Perché?

**Risposta:** No, i nomi diversi non impediscono il collegamento. Il Service seleziona per label (`app: web-intro`), non per nome. Servono solo stesso namespace e label corrispondenti: `accesso-web` raggiunge i Pod di `sito-nginx`.

### Q10

**Domanda:** Che differenza c'è fra un endpoint e un EndpointSlice? A che cosa servono nel collegamento fra Service e Pod?

**Risposta:** `Endpoints` è la lista unica degli `IP:porta` dei Pod pronti per un Service. `EndpointSlice` è la versione moderna e scalabile: più oggetti limitati per dimensione, con `addressType`, condizioni e `targetRef`. Sono il ponte fra selector del Service e Pod reali, usati dal dataplane per inoltrare solo a destinazioni valide.

## D. Ciclo di vita e aggiornamenti

### Q11

**Domanda:** Qual è la differenza fra riavvio di un container e sostituzione di un Pod? Come si può riconoscere la differenza?

**Risposta:** Riavviare il container lascia lo stesso Pod: stesso nome, UID, IP, nodo e volumi; aumenta `restartCount`. Sostituire il Pod elimina il vecchio e ne crea uno nuovo: cambiano nome, UID, spesso IP/nodo e l'età riparte. Si distingue con `RESTARTS`, `AGE`, UID, `Last State` ed eventi.

### Q12

**Domanda:** Qual è la differenza fra aumentare spec.replicas e cambiare l'immagine in spec.template? Perché il secondo intervento può far comparire un altro ReplicaSet?

**Risposta:** Aumentare `spec.replicas` crea altre copie dello stesso template: stesso ReplicaSet e stessa revisione. Cambiare l'immagine in `spec.template` cambia il template: nasce un nuovo ReplicaSet con nuovo hash e nuova revisione, mentre il vecchio viene ridotto a zero ma conservato per il rollback. Per questo compare un altro ReplicaSet.
