# UD15 — 12 domande fondamentali sui concetti e sul funzionamento di Kubernetes

Da svolgere dopo il laboratorio guidato e la lettura di `02A_POST_LAB_DAL_MANIFEST_AL_CICLO_DI_VITA_K8S.md`.

La selezione si concentra sui concetti necessari per comprendere il percorso dal manifest all’applicazione e il collegamento fra gli oggetti. Le risposte possono essere brevi, purché motivate. Non è richiesta l’esecuzione di modifiche sul cluster.

I casi si riferiscono al laboratorio `web-intro` nel namespace `ft152-ud15`. Le risposte sono nel file separato `02C_RISPOSTE_CONCETTI_E_FUNZIONAMENTO_K8S.md`, con la stessa numerazione.

## A. Manifest, API e dati del cluster

### Q01

Che differenza c’è fra il file deployment.yaml sul PC, l’oggetto Deployment nel cluster e il processo Nginx in esecuzione?

### Q02

Quale ruolo svolge l’API Server quando viene applicato un manifest? Perché la risposta created non dimostra che l’applicazione risponda già via HTTP?

### Q03

Quale problema risolve etcd? Fra specifica del Deployment, immagini complete, stato API del Pod, memoria di Nginx e file applicativi di un volume, che cosa vi viene conservato?

## B. Oggetti e componenti di controllo

### Q04

Che cos’è un Pod? Quale vantaggio offre rispetto alla descrizione di un semplice processo? Può contenere più container?

### Q05

Quali problemi risolvono Deployment e ReplicaSet? Perché nel laboratorio compaiono entrambi?

### Q06

Qual è la differenza fra un oggetto Deployment e il controller del Deployment? Che cosa significa riconciliazione?

### Q07

Quali ruoli hanno scheduler, kubelet e runtime nell’avvio di un Pod? Quale di questi sceglie il nodo?

## C. Service e destinatari di rete

### Q08

Quale problema risolve un Service se i Pod possiedono già un indirizzo IP? Perché collegare un client direttamente all’IP di un Pod può diventare fragile?

### Q09

Si consideri un Deployment chiamato sito-nginx, i cui Pod hanno label app: web-intro, e un Service chiamato accesso-web con selector app: web-intro. Se sono nello stesso namespace, la differenza dei nomi impedisce il collegamento? Perché?

### Q10

Che differenza c’è fra un endpoint e un EndpointSlice? A che cosa servono nel collegamento fra Service e Pod?

## D. Ciclo di vita e aggiornamenti

### Q11

Qual è la differenza fra riavvio di un container e sostituzione di un Pod? Come si può riconoscere la differenza?

### Q12

Qual è la differenza fra aumentare spec.replicas e cambiare l’immagine in spec.template? Perché il secondo intervento può far comparire un altro ReplicaSet?
