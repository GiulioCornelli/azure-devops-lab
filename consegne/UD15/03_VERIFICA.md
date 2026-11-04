# UD15 — Risposte e prova individuale

Partecipante, data/ora/fuso: GiulioCornelli, 2026-11-04 16:52 CET (UTC+1)

1. **Tre repliche richieste, una osservata.** Il controller del ReplicaSet, dentro `kube-controller-manager`, confronta le repliche desiderate con quelle esistenti e crea i Pod mancanti. Lo Scheduler sceglie il nodo e scrive il binding; non crea il container. Il kubelet del nodo avvia poi i container tramite il runtime. Evidenza: passaggio da `1/1` a `3/3` dopo `scale`.
2. **API Server, kubelet, runtime.** L'API Server valida e salva il manifest in etcd e notifica i controller, ma non esegue Nginx. Lo Scheduler assegna il Pod a un nodo; il kubelet di quel nodo monta i volumi, scarica l'immagine e avvia i container; il runtime (containerd) esegue il processo Nginx.
3. **Deployment, ReplicaSet, Pod.** Il Deployment descrive lo stato desiderato, gestisce rollout e revisioni; il ReplicaSet garantisce il numero di Pod con un certo template; il Pod è l'unità che esegue i container. Nel laboratorio modifichiamo il Deployment (`scale`, `set image`, `apply` del file), non i singoli Pod.
4. **Service senza backend.** Confronto il `selector` del Service con le label dei Pod (`app=web-intro`) nello stesso namespace, poi verifico che i Pod siano `Ready` e che gli EndpointSlice contengano i loro IP. Il nome uguale a quello del Deployment non conta; contano anche `port`/`targetPort`.
5. **Context e namespace.** Il context è il riferimento del kubeconfig che indica cluster, utente e namespace predefinito; il namespace è una partizione logica dentro il cluster. Li rendiamo espliciti con `--context=minikube -n ft152-ud15` per non agire sul namespace `default` o su un altro cluster.
6. **`containerPort: 80` e accesso locale.** `containerPort` dichiara la porta del container e serve al targeting, ma non pubblica nulla su Windows. L'accesso locale è stato fatto con `kubectl port-forward --address=127.0.0.1 service/web-intro 8081:80`, poi `curl` o browser su `localhost:8081`.
7. **Scaling e aggiornamento immagine.** Lo scaling è passato da 1 a 3 repliche mantenendo lo stesso ReplicaSet e la stessa revisione, perché `spec.template` non è cambiato. L'aggiornamento dell'immagine ha cambiato il template, creato un nuovo ReplicaSet (`web-intro-54449bc466`) e una nuova revisione; il rollback ha ripristinato il template precedente con un'ulteriore revisione.
8. **Sì, il servizio può rispondere ancora.** Il Deployment manteneva tre Pod vecchi `Running` con `nginx:1.28.0-alpine`, mentre il nuovo Pod era in `ErrImagePull`/`ImagePullBackOff` per il tag inesistente. Il Deployment risultava `3/3` disponibili ma con `1` updated e rollout non completato; il Service continuava a usare i Pod pronti.
9. **`logs --previous`.** Si usa per leggere i log dell'istanza precedente dello stesso container dopo un riavvio o un crash. Su `ImagePullBackOff` il container non è mai stato creato, quindi non esistono né log attuali né precedenti: si leggono `describe pod` e gli eventi.
10. **Rollback e dati.** Il rollback ripristina il modello del Deployment, quindi l'immagine, ma non i dati su un volume e non il file manifest nel repository. I dati del volume seguono il ciclo di vita del volume; il file locale resta quello che è e va eventualmente riallineato con `apply`.
11. **Tre Pod su un solo nodo.** Non proteggono dalla perdita del nodo: stanno tutti sullo stesso Minikube/Docker host, quindi un guasto del nodo o di Docker li perde insieme. Aiutano contro guasti di singoli Pod e durante i rollout; per l'alta disponibilità servono più nodi o zone.
12. **Catalogo completo.** No, abbiamo eseguito solo la micro-demo Nginx. Servono ancora, per esempio, il backend del Catalogo con il suo database e la configurazione di rete/ingress (oltre a volumi persistenti, secret e immagini applicative).

## Lettura del cluster

Pod scelto, owner, immagine, nodo e condizione: da completare con la variante `web-autonomo`, non ancora creata.  
Relazione con il Service ed EndpointSlice: da completare dopo il laboratorio autonomo.  
Cronologia letta e limite di ciò che prova: la cronologia del guidato mostra le revisioni e i ReplicaSet, ma non dimostra da sola che l'applicazione risponda; servono anche probe e test HTTP.

## Consegne

File completi, percorsi manifest e commit: inventario e guidato completi; manifest in `k8s/ud15/namespace.yaml`, `deployment.yaml`, `service.yaml`; autonomo e verifica ancora da completare, commit non ancora eseguito.  
Prove operative mancanti da recuperare: laboratorio autonomo (`web-autonomo` a due repliche) e lettura del relativo Pod/Service.  
Punteggio ricevuto e motivazione del recupero, se necessario: non ancora assegnato.
