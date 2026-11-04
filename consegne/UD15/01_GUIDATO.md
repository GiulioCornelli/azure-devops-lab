# UD15 — Consegna laboratorio guidato

Partecipante: GiulioCornelli  
Data e fuso orario: 2026-11-04 16:32 CET (UTC+1)  
Repository operativo: `/home/giulio/Corsi/Corso-Azure/azure-devops-lab`

## Spiegazioni personali

Le prove dei comandi saranno aggiunte automaticamente dal guidato, nella parte successiva di questo file. Scrivi qui soltanto le brevi spiegazioni richieste:

- Come il selector del Service individua i Pod: il Service `web-intro` seleziona per label `app=web-intro` tutti i Pod con quella label nello stesso namespace; il controller crea gli EndpointSlice con gli IP dei Pod pronti (`ready: true`), che il dataplane usa per inoltrare il traffico. Il nome del Deployment o del Pod non conta.
- Che cosa cambia con lo scaling e perché la revisione resta uguale: `--replicas=3` cambia solo il numero di copie nel Deployment e fa creare al ReplicaSet esistente altri due Pod con lo stesso template. La revisione resta la stessa perché `spec.template` non cambia: non nasce un nuovo ReplicaSet e non viene registrata una nuova revisione.
- Confronto fra immagine aggiornata e immagine dopo il rollback: con `set image` il Deployment è passato a `nginx:1.29.0-alpine`, ha creato il ReplicaSet `web-intro-54449bc466` (revisione 2) e ha sostituito i Pod. Il rollback ha ripristinato `nginx:1.28.0-alpine`, riportando a tre repliche il ReplicaSet `web-intro-846844b5c9` e registrando la revisione 3; l'header HTTP è passato da `Server: nginx/1.29.0` a `Server: nginx/1.28.0`.
- Causa del guasto letta negli eventi e disponibilità dei log: il tag `nginx:tag-ft152-che-non-esiste` non esiste. Gli eventi del Pod mostrano `Failed to pull image ... not found`, poi `ErrImagePull` e `ImagePullBackOff`. I log non sono disponibili perché il container non è mai stato creato (`Container ID` vuoto, stato `Waiting`): non esiste un processo Nginx da cui leggere output né un'istanza precedente.
- Esiti osservati nel browser per immagine iniziale, aggiornata e dopo rollback: la pagina è la pagina Nginx standard in tutte e tre le fasi e il contenuto HTML è identico. Per la fase finale ho usato Chrome headless (Google Chrome 156): risposta `HTTP 200` e titolo `Welcome to nginx!`; per le fasi iniziale e aggiornata la verifica HTTP è documentata da `curl`, con header `Server: nginx/1.28.0` e `Server: nginx/1.29.0`. La versione si distingue dall'header e dall'immagine dei Pod, non dalla pagina.
- Tempi effettivi e problemi incontrati: circa 4 minuti effettivi (16:32–16:36). All'inizio il profilo Minikube era fermo: è stato riavviato con `minikube start -p minikube --kubernetes-version=v1.37.0` in meno di un minuto. Le immagini `nginx:1.28.0-alpine` e `nginx:1.29.0-alpine` sono state scaricate in pochi secondi. Durante il rollback `kubectl` ha emesso un warning sull'annotazione `last-applied-configuration`, poi riallineata dal successivo `apply` del manifest; nessun problema bloccante.
- Profilo che intendo conservare attivo/fermo a fine giornata: attivo, per poter svolgere l'autonomo e riprendere le letture nella UD16.
- Risorse Azure precedenti eventualmente ancora conservate: l'ACR `acrud1315kws5mnriekyoq` delle UD13–UD14; la UD15 non crea né modifica risorse Azure.

## Evidenze raccolte dal terminale

I blocchi del guidato aggiungono qui data/ora e output effettivi. Gli errori restano visibili insieme alla successiva prova corretta. Non sostituire un errore con un risultato atteso.

### Primo Deployment e collegamento ai Pod

```text
2026-11-04T16:33:34+01:00
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                SELECTOR
deployment.apps/web-intro   1/1     1            1           9s    web          nginx:1.28.0-alpine   app=web-intro

NAME                                   DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                SELECTOR
replicaset.apps/web-intro-846844b5c9   1         1         1       9s    web          nginx:1.28.0-alpine   app=web-intro,pod-template-hash=846844b5c9

NAME                             READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
pod/web-intro-846844b5c9-dvw2q   1/1     Running   0          9s    10.244.0.3   minikube   <none>           <none>
NAME                         READY   STATUS    RESTARTS   AGE   LABELS
web-intro-846844b5c9-dvw2q   1/1     Running   0          9s    app=web-intro,pod-template-hash=846844b5c9
Name:                   web-intro
Namespace:              ft152-ud15
CreationTimestamp:      Wed, 04 Nov 2026 16:33:25 +0100
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=web-intro
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=web-intro
  Containers:
   web:
    Image:         nginx:1.28.0-alpine
    Port:          80/TCP (http)
    Host Port:     0/TCP (http)
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   web-intro-846844b5c9 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  9s    deployment-controller  Scaled up replica set web-intro-846844b5c9 from 0 to 1
LAST SEEN   TYPE     REASON              OBJECT                            MESSAGE
9s          Normal   Scheduled           pod/web-intro-846844b5c9-dvw2q    Successfully assigned ft152-ud15/web-intro-846844b5c9-dvw2q to minikube
9s          Normal   Pulling             pod/web-intro-846844b5c9-dvw2q    Pulling image "nginx:1.28.0-alpine"
9s          Normal   SuccessfulCreate    replicaset/web-intro-846844b5c9   Created pod: web-intro-846844b5c9-dvw2q
9s          Normal   ScalingReplicaSet   deployment/web-intro              Scaled up replica set web-intro-846844b5c9 from 0 to 1
4s          Normal   Pulled              pod/web-intro-846844b5c9-dvw2q    Successfully pulled image "nginx:1.28.0-alpine" in 4.266s (4.266s including waiting). Image size: 21015643 bytes.
4s          Normal   Created             pod/web-intro-846844b5c9-dvw2q    Container created
4s          Normal   Started             pod/web-intro-846844b5c9-dvw2q    Container started
```

### Service web-intro e indirizzi dei Pod

```text
2026-11-04T16:33:46+01:00
Name:                     web-intro
Namespace:                ft152-ud15
Labels:                   <none>
Annotations:              <none>
Selector:                 app=web-intro
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.216.27
IPs:                      10.96.216.27
Port:                     http  80/TCP
TargetPort:               http/TCP
Endpoints:                10.244.0.3:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
NAME                         READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
web-intro-846844b5c9-dvw2q   1/1     Running   0          21s   10.244.0.3   minikube   <none>           <none>
apiVersion: v1
items:
- addressType: IPv4
  apiVersion: discovery.k8s.io/v1
  endpoints:
  - addresses:
    - 10.244.0.3
    conditions:
      ready: true
      serving: true
      terminating: false
    nodeName: minikube
    targetRef:
      kind: Pod
      name: web-intro-846844b5c9-dvw2q
      namespace: ft152-ud15
      uid: 242e6c4f-13db-4de2-b341-b2d4195fcdc2
  kind: EndpointSlice
  metadata:
    annotations:
      endpoints.kubernetes.io/last-change-trigger-time: "2026-11-04T15:33:41Z"
    creationTimestamp: "2026-11-04T15:33:41Z"
    generateName: web-intro-
    generation: 1
    labels:
      endpointslice.kubernetes.io/managed-by: endpointslice-controller.k8s.io
      kubernetes.io/service-name: web-intro
    name: web-intro-rr2sn
    namespace: ft152-ud15
    ownerReferences:
    - apiVersion: v1
      blockOwnerDeletion: true
      controller: true
      kind: Service
      name: web-intro
      uid: 6e722228-199c-4b76-ad17-442806be59e6
    resourceVersion: "4100"
    uid: 920539fe-4f14-4f3c-b94c-1fdc3973daa2
  ports:
  - name: http
    port: 80
    protocol: TCP
kind: List
metadata:
  resourceVersion: ""
```

### Risposta HTTP della demo iniziale

```text
2026-11-04T16:34:28+01:00
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0100   615  100   615    0     0   287k      0 --:--:-- --:--:-- --:--:--  300k
HTTP/1.1 200 OK
Server: nginx/1.28.0
Date: Wed, 04 Nov 2026 15:34:28 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 23 Apr 2025 12:59:25 GMT
Connection: keep-alive
ETag: "6808e42d-267"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Prima dello scaling: una replica e revisione corrente

```text
2026-11-04T16:34:34+01:00
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                SELECTOR
deployment.apps/web-intro   1/1     1            1           69s   web          nginx:1.28.0-alpine   app=web-intro

NAME                                   DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                SELECTOR
replicaset.apps/web-intro-846844b5c9   1         1         1       69s   web          nginx:1.28.0-alpine   app=web-intro,pod-template-hash=846844b5c9

NAME                             READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
pod/web-intro-846844b5c9-dvw2q   1/1     Running   0          69s   10.244.0.3   minikube   <none>           <none>
deployment.apps/web-intro 
REVISION  CHANGE-CAUSE
1         <none>

```

### Dopo lo scaling: tre Pod Nginx

```text
2026-11-04T16:34:41+01:00
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                SELECTOR
deployment.apps/web-intro   3/3     3            3           76s   web          nginx:1.28.0-alpine   app=web-intro

NAME                                   DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                SELECTOR
replicaset.apps/web-intro-846844b5c9   3         3         3       76s   web          nginx:1.28.0-alpine   app=web-intro,pod-template-hash=846844b5c9

NAME                             READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
pod/web-intro-846844b5c9-dvw2q   1/1     Running   0          76s   10.244.0.3   minikube   <none>           <none>
pod/web-intro-846844b5c9-nhz54   1/1     Running   0          7s    10.244.0.5   minikube   <none>           <none>
pod/web-intro-846844b5c9-vxcdt   1/1     Running   0          7s    10.244.0.4   minikube   <none>           <none>
apiVersion: v1
items:
- addressType: IPv4
  apiVersion: discovery.k8s.io/v1
  endpoints:
  - addresses:
    - 10.244.0.3
    conditions:
      ready: true
      serving: true
      terminating: false
    nodeName: minikube
    targetRef:
      kind: Pod
      name: web-intro-846844b5c9-dvw2q
      namespace: ft152-ud15
      uid: 242e6c4f-13db-4de2-b341-b2d4195fcdc2
  - addresses:
    - 10.244.0.4
    conditions:
      ready: true
      serving: true
      terminating: false
    nodeName: minikube
    targetRef:
      kind: Pod
      name: web-intro-846844b5c9-vxcdt
      namespace: ft152-ud15
      uid: 5d8ab24e-88b2-4576-919f-5fdb7d644cc4
  - addresses:
    - 10.244.0.5
    conditions:
      ready: true
      serving: true
      terminating: false
    nodeName: minikube
    targetRef:
      kind: Pod
      name: web-intro-846844b5c9-nhz54
      namespace: ft152-ud15
      uid: be6d2849-3381-4a40-9152-8de4f2025b29
  kind: EndpointSlice
  metadata:
    annotations:
      endpoints.kubernetes.io/last-change-trigger-time: "2026-11-04T15:34:35Z"
    creationTimestamp: "2026-11-04T15:33:41Z"
    generateName: web-intro-
    generation: 3
    labels:
      endpointslice.kubernetes.io/managed-by: endpointslice-controller.k8s.io
      kubernetes.io/service-name: web-intro
    name: web-intro-rr2sn
    namespace: ft152-ud15
    ownerReferences:
    - apiVersion: v1
      blockOwnerDeletion: true
      controller: true
      kind: Service
      name: web-intro
      uid: 6e722228-199c-4b76-ad17-442806be59e6
    resourceVersion: "4179"
    uid: 920539fe-4f14-4f3c-b94c-1fdc3973daa2
  ports:
  - name: http
    port: 80
    protocol: TCP
kind: List
metadata:
  resourceVersion: ""
deployment.apps/web-intro 
REVISION  CHANGE-CAUSE
1         <none>

```

### File riallineato a tre repliche

```text
2026-11-04T16:34:49+01:00
# Micro-demo: Nginx standard, non il frontend completo del Catalogo.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-intro
  namespace: ft152-ud15
spec:
  replicas: 3
  # Conserviamo i template precedenti per l'esercizio di rollback.
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: web-intro
  template:
    metadata:
      labels:
        app: web-intro
    spec:
      containers:
        - name: web
          image: nginx:1.28.0-alpine
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
web-intro   3/3     3            3           84s
```

### Prima dell’aggiornamento immagine

```text
2026-11-04T16:34:54+01:00
deployment.apps/web-intro 
REVISION  CHANGE-CAUSE
1         <none>

apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"web-intro","namespace":"ft152-ud15"},"spec":{"replicas":3,"revisionHistoryLimit":5,"selector":{"matchLabels":{"app":"web-intro"}},"template":{"metadata":{"labels":{"app":"web-intro"}},"spec":{"containers":[{"image":"nginx:1.28.0-alpine","imagePullPolicy":"IfNotPresent","name":"web","ports":[{"containerPort":80,"name":"http"}]}]}}}}
  creationTimestamp: "2026-11-04T15:33:25Z"
  generation: 3
  name: web-intro
  namespace: ft152-ud15
  resourceVersion: "4194"
  uid: 5a2af6b8-b874-4698-a62a-cf4459b5c79d
spec:
  progressDeadlineSeconds: 600
  replicas: 3
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: web-intro
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: web-intro
    spec:
      containers:
      - image: nginx:1.28.0-alpine
        imagePullPolicy: IfNotPresent
        name: web
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 3
  conditions:
  - lastTransitionTime: "2026-11-04T15:33:25Z"
    lastUpdateTime: "2026-11-04T15:33:30Z"
    message: ReplicaSet "web-intro-846844b5c9" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  - lastTransitionTime: "2026-11-04T15:34:35Z"
    lastUpdateTime: "2026-11-04T15:34:35Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  observedGeneration: 3
  readyReplicas: 3
  replicas: 3
  terminatingReplicas: 0
  updatedReplicas: 3
```

### Immagine aggiornata e Pod avviati

```text
2026-11-04T16:35:10+01:00
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES                SELECTOR
deployment.apps/web-intro   3/3     3            3           105s   web          nginx:1.29.0-alpine   app=web-intro

NAME                                   DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES                SELECTOR
replicaset.apps/web-intro-54449bc466   3         3         3       11s    web          nginx:1.29.0-alpine   app=web-intro,pod-template-hash=54449bc466
replicaset.apps/web-intro-846844b5c9   0         0         0       105s   web          nginx:1.28.0-alpine   app=web-intro,pod-template-hash=846844b5c9

NAME                             READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
pod/web-intro-54449bc466-5tnp6   1/1     Running   0          6s    10.244.0.8   minikube   <none>           <none>
pod/web-intro-54449bc466-cgcqc   1/1     Running   0          11s   10.244.0.6   minikube   <none>           <none>
pod/web-intro-54449bc466-k4nv4   1/1     Running   0          6s    10.244.0.7   minikube   <none>           <none>
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    creationTimestamp: "2026-11-04T15:35:04Z"
    generateName: web-intro-54449bc466-
    generation: 1
    labels:
      app: web-intro
      pod-template-hash: 54449bc466
    name: web-intro-54449bc466-5tnp6
    namespace: ft152-ud15
    ownerReferences:
    - apiVersion: apps/v1
      blockOwnerDeletion: true
      controller: true
      kind: ReplicaSet
      name: web-intro-54449bc466
      uid: 264d21d8-8521-47a6-a6bd-234e8cf1e1ee
    resourceVersion: "4299"
    uid: 776fd670-0216-402a-9b9a-436ccf5df405
  spec:
    containers:
    - image: nginx:1.29.0-alpine
      imagePullPolicy: IfNotPresent
      name: web
      ports:
      - containerPort: 80
        name: http
        protocol: TCP
      resources: {}
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-znpw6
        readOnly: true
    dnsPolicy: ClusterFirst
    enableServiceLinks: true
    nodeName: minikube
    preemptionPolicy: PreemptLowerPriority
    priority: 0
    restartPolicy: Always
    schedulerName: default-scheduler
    securityContext: {}
    serviceAccount: default
    serviceAccountName: default
    terminationGracePeriodSeconds: 30
    tolerations:
    - effect: NoExecute
      key: node.kubernetes.io/not-ready
      operator: Exists
      tolerationSeconds: 300
    - effect: NoExecute
      key: node.kubernetes.io/unreachable
      operator: Exists
      tolerationSeconds: 300
    volumes:
    - name: kube-api-access-znpw6
      projected:
        defaultMode: 420
        sources:
        - serviceAccountToken:
            expirationSeconds: 3607
            path: token
        - configMap:
            items:
            - key: ca.crt
              path: ca.crt
            name: kube-root-ca.crt
        - downwardAPI:
            items:
            - fieldRef:
                apiVersion: v1
                fieldPath: metadata.namespace
              path: namespace
  status:
    conditions:
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:05Z"
      observedGeneration: 1
      status: "True"
      type: PodReadyToStartContainers
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: Initialized
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:05Z"
      observedGeneration: 1
      status: "True"
      type: Ready
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:05Z"
      observedGeneration: 1
      status: "True"
      type: ContainersReady
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: PodScheduled
    containerStatuses:
    - containerID: containerd://f295e909bfae341a9aee545afcf99aea1765db8165b0ad6581c6ae47d5db28e8
      image: docker.io/library/nginx:1.29.0-alpine
      imageID: docker.io/library/nginx@sha256:d67ea0d64d518b1bb04acde3b00f722ac3e9764b3209a9b0a98924ba35e4b779
      lastState: {}
      name: web
      ready: true
      resources: {}
      restartCount: 0
      started: true
      state:
        running:
          startedAt: "2026-11-04T15:35:05Z"
      user:
        linux:
          gid: 0
          supplementalGroups:
          - 0
          - 1
          - 2
          - 3
          - 4
          - 6
          - 10
          - 11
          - 20
          - 26
          - 27
          uid: 0
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-znpw6
        readOnly: true
        recursiveReadOnly: Disabled
    hostIP: 192.168.49.2
    hostIPs:
    - ip: 192.168.49.2
    observedGeneration: 1
    phase: Running
    podIP: 10.244.0.8
    podIPs:
    - ip: 10.244.0.8
    qosClass: BestEffort
    resources: {}
    startTime: "2026-11-04T15:35:04Z"
- apiVersion: v1
  kind: Pod
  metadata:
    creationTimestamp: "2026-11-04T15:34:59Z"
    generateName: web-intro-54449bc466-
    generation: 1
    labels:
      app: web-intro
      pod-template-hash: 54449bc466
    name: web-intro-54449bc466-cgcqc
    namespace: ft152-ud15
    ownerReferences:
    - apiVersion: apps/v1
      blockOwnerDeletion: true
      controller: true
      kind: ReplicaSet
      name: web-intro-54449bc466
      uid: 264d21d8-8521-47a6-a6bd-234e8cf1e1ee
    resourceVersion: "4229"
    uid: 3d8b870e-919e-451d-a418-869db971eec0
  spec:
    containers:
    - image: nginx:1.29.0-alpine
      imagePullPolicy: IfNotPresent
      name: web
      ports:
      - containerPort: 80
        name: http
        protocol: TCP
      resources: {}
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-zmnrg
        readOnly: true
    dnsPolicy: ClusterFirst
    enableServiceLinks: true
    nodeName: minikube
    preemptionPolicy: PreemptLowerPriority
    priority: 0
    restartPolicy: Always
    schedulerName: default-scheduler
    securityContext: {}
    serviceAccount: default
    serviceAccountName: default
    terminationGracePeriodSeconds: 30
    tolerations:
    - effect: NoExecute
      key: node.kubernetes.io/not-ready
      operator: Exists
      tolerationSeconds: 300
    - effect: NoExecute
      key: node.kubernetes.io/unreachable
      operator: Exists
      tolerationSeconds: 300
    volumes:
    - name: kube-api-access-zmnrg
      projected:
        defaultMode: 420
        sources:
        - serviceAccountToken:
            expirationSeconds: 3607
            path: token
        - configMap:
            items:
            - key: ca.crt
              path: ca.crt
            name: kube-root-ca.crt
        - downwardAPI:
            items:
            - fieldRef:
                apiVersion: v1
                fieldPath: metadata.namespace
              path: namespace
  status:
    conditions:
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:00Z"
      observedGeneration: 1
      status: "True"
      type: PodReadyToStartContainers
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:34:59Z"
      observedGeneration: 1
      status: "True"
      type: Initialized
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: Ready
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: ContainersReady
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:34:59Z"
      observedGeneration: 1
      status: "True"
      type: PodScheduled
    containerStatuses:
    - containerID: containerd://fbceb92f02c567d2e78f91bb8f53068dd797238f66214b3e2132fe7dac12f97a
      image: docker.io/library/nginx:1.29.0-alpine
      imageID: docker.io/library/nginx@sha256:d67ea0d64d518b1bb04acde3b00f722ac3e9764b3209a9b0a98924ba35e4b779
      lastState: {}
      name: web
      ready: true
      resources: {}
      restartCount: 0
      started: true
      state:
        running:
          startedAt: "2026-11-04T15:35:04Z"
      user:
        linux:
          gid: 0
          supplementalGroups:
          - 0
          - 1
          - 2
          - 3
          - 4
          - 6
          - 10
          - 11
          - 20
          - 26
          - 27
          uid: 0
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-zmnrg
        readOnly: true
        recursiveReadOnly: Disabled
    hostIP: 192.168.49.2
    hostIPs:
    - ip: 192.168.49.2
    observedGeneration: 1
    phase: Running
    podIP: 10.244.0.6
    podIPs:
    - ip: 10.244.0.6
    qosClass: BestEffort
    resources: {}
    startTime: "2026-11-04T15:34:59Z"
- apiVersion: v1
  kind: Pod
  metadata:
    creationTimestamp: "2026-11-04T15:35:04Z"
    generateName: web-intro-54449bc466-
    generation: 1
    labels:
      app: web-intro
      pod-template-hash: 54449bc466
    name: web-intro-54449bc466-k4nv4
    namespace: ft152-ud15
    ownerReferences:
    - apiVersion: apps/v1
      blockOwnerDeletion: true
      controller: true
      kind: ReplicaSet
      name: web-intro-54449bc466
      uid: 264d21d8-8521-47a6-a6bd-234e8cf1e1ee
    resourceVersion: "4265"
    uid: 5bd1a471-8c56-4ef2-9fa3-4039c0e3f37d
  spec:
    containers:
    - image: nginx:1.29.0-alpine
      imagePullPolicy: IfNotPresent
      name: web
      ports:
      - containerPort: 80
        name: http
        protocol: TCP
      resources: {}
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-6cqm6
        readOnly: true
    dnsPolicy: ClusterFirst
    enableServiceLinks: true
    nodeName: minikube
    preemptionPolicy: PreemptLowerPriority
    priority: 0
    restartPolicy: Always
    schedulerName: default-scheduler
    securityContext: {}
    serviceAccount: default
    serviceAccountName: default
    terminationGracePeriodSeconds: 30
    tolerations:
    - effect: NoExecute
      key: node.kubernetes.io/not-ready
      operator: Exists
      tolerationSeconds: 300
    - effect: NoExecute
      key: node.kubernetes.io/unreachable
      operator: Exists
      tolerationSeconds: 300
    volumes:
    - name: kube-api-access-6cqm6
      projected:
        defaultMode: 420
        sources:
        - serviceAccountToken:
            expirationSeconds: 3607
            path: token
        - configMap:
            items:
            - key: ca.crt
              path: ca.crt
            name: kube-root-ca.crt
        - downwardAPI:
            items:
            - fieldRef:
                apiVersion: v1
                fieldPath: metadata.namespace
              path: namespace
  status:
    conditions:
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: PodReadyToStartContainers
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: Initialized
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: Ready
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: ContainersReady
    - lastProbeTime: null
      lastTransitionTime: "2026-11-04T15:35:04Z"
      observedGeneration: 1
      status: "True"
      type: PodScheduled
    containerStatuses:
    - containerID: containerd://996f68a2848268653a5e41322b0f7729e08f2875b17fcc8332cdc9cf04f124a3
      image: docker.io/library/nginx:1.29.0-alpine
      imageID: docker.io/library/nginx@sha256:d67ea0d64d518b1bb04acde3b00f722ac3e9764b3209a9b0a98924ba35e4b779
      lastState: {}
      name: web
      ready: true
      resources: {}
      restartCount: 0
      started: true
      state:
        running:
          startedAt: "2026-11-04T15:35:04Z"
      user:
        linux:
          gid: 0
          supplementalGroups:
          - 0
          - 1
          - 2
          - 3
          - 4
          - 6
          - 10
          - 11
          - 20
          - 26
          - 27
          uid: 0
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-6cqm6
        readOnly: true
        recursiveReadOnly: Disabled
    hostIP: 192.168.49.2
    hostIPs:
    - ip: 192.168.49.2
    observedGeneration: 1
    phase: Running
    podIP: 10.244.0.7
    podIPs:
    - ip: 10.244.0.7
    qosClass: BestEffort
    resources: {}
    startTime: "2026-11-04T15:35:04Z"
kind: List
metadata:
  resourceVersion: ""
deployment.apps/web-intro 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

```

### Test HTTP dopo aggiornamento immagine

```text
2026-11-04T16:35:14+01:00
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0100   615  100   615    0     0   281k      0 --:--:-- --:--:-- --:--:--  300k
HTTP/1.1 200 OK
Server: nginx/1.29.0
Date: Wed, 04 Nov 2026 15:35:14 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 24 Jun 2025 17:57:38 GMT
Connection: keep-alive
ETag: "685ae712-267"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Dopo il rollback dell’immagine

```text
2026-11-04T16:35:26+01:00
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES                SELECTOR
deployment.apps/web-intro   3/3     3            3           2m1s   web          nginx:1.28.0-alpine   app=web-intro

NAME                                   DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES                SELECTOR
replicaset.apps/web-intro-54449bc466   0         0         0       27s    web          nginx:1.29.0-alpine   app=web-intro,pod-template-hash=54449bc466
replicaset.apps/web-intro-846844b5c9   3         3         3       2m1s   web          nginx:1.28.0-alpine   app=web-intro,pod-template-hash=846844b5c9

NAME                             READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/web-intro-846844b5c9-bq7gg   1/1     Running   0          6s    10.244.0.11   minikube   <none>           <none>
pod/web-intro-846844b5c9-sk6sc   1/1     Running   0          7s    10.244.0.9    minikube   <none>           <none>
pod/web-intro-846844b5c9-vqdsf   1/1     Running   0          6s    10.244.0.10   minikube   <none>           <none>
deployment.apps/web-intro 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>

```

### Test HTTP dopo rollback

```text
2026-11-04T16:35:31+01:00
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0100   615  100   615    0     0  84142      0 --:--:-- --:--:-- --:--:-- 87857
HTTP/1.1 200 OK
Server: nginx/1.28.0
Date: Wed, 04 Nov 2026 15:35:31 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 23 Apr 2025 12:59:25 GMT
Connection: keep-alive
ETag: "6808e42d-267"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Guasto di immagine: stato e messaggio osservati

```text
2026-11-04T16:35:51+01:00
NAME                         READY   STATUS         RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
web-intro-6d4c975bcd-4dt7l   0/1     ErrImagePull   0          11s   10.244.0.12   minikube   <none>           <none>
web-intro-846844b5c9-bq7gg   1/1     Running        0          31s   10.244.0.11   minikube   <none>           <none>
web-intro-846844b5c9-sk6sc   1/1     Running        0          32s   10.244.0.9    minikube   <none>           <none>
web-intro-846844b5c9-vqdsf   1/1     Running        0          31s   10.244.0.10   minikube   <none>           <none>
Name:             web-intro-6d4c975bcd-4dt7l
Namespace:        ft152-ud15
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Wed, 04 Nov 2026 16:35:40 +0100
Labels:           app=web-intro
                  pod-template-hash=6d4c975bcd
Annotations:      <none>
Status:           Pending
IP:               10.244.0.12
IPs:
  IP:           10.244.0.12
Controlled By:  ReplicaSet/web-intro-6d4c975bcd
Containers:
  web:
    Container ID:   
    Image:          nginx:tag-ft152-che-non-esiste
    Image ID:       
    Port:           80/TCP (http)
    Host Port:      0/TCP (http)
    State:          Waiting
      Reason:       ErrImagePull
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-q9kcj (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  kube-api-access-q9kcj:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  11s   default-scheduler  Successfully assigned ft152-ud15/web-intro-6d4c975bcd-4dt7l to minikube
  Normal   Pulling    11s   kubelet            spec.containers{web}: Pulling image "nginx:tag-ft152-che-non-esiste"
  Warning  Failed     9s    kubelet            spec.containers{web}: Failed to pull image "nginx:tag-ft152-che-non-esiste": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:tag-ft152-che-non-esiste": failed to resolve reference "docker.io/library/nginx:tag-ft152-che-non-esiste": docker.io/library/nginx:tag-ft152-che-non-esiste: not found
  Warning  Failed     9s    kubelet            spec.containers{web}: Error: ErrImagePull
  Normal   BackOff    9s    kubelet            spec.containers{web}: Back-off pulling image "nginx:tag-ft152-che-non-esiste"
  Warning  Failed     9s    kubelet            spec.containers{web}: Error: ImagePullBackOff
LAST SEEN   TYPE      REASON              OBJECT                            MESSAGE
2m26s       Normal    Scheduled           pod/web-intro-846844b5c9-dvw2q    Successfully assigned ft152-ud15/web-intro-846844b5c9-dvw2q to minikube
32s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled up replica set web-intro-846844b5c9 from 0 to 1
2m26s       Normal    SuccessfulCreate    replicaset/web-intro-846844b5c9   Created pod: web-intro-846844b5c9-dvw2q
2m26s       Normal    Pulling             pod/web-intro-846844b5c9-dvw2q    Pulling image "nginx:1.28.0-alpine"
2m21s       Normal    Started             pod/web-intro-846844b5c9-dvw2q    Container started
2m21s       Normal    Created             pod/web-intro-846844b5c9-dvw2q    Container created
2m21s       Normal    Pulled              pod/web-intro-846844b5c9-dvw2q    Successfully pulled image "nginx:1.28.0-alpine" in 4.266s (4.266s including waiting). Image size: 21015643 bytes.
77s         Normal    SuccessfulCreate    replicaset/web-intro-846844b5c9   Created pod: web-intro-846844b5c9-vxcdt
77s         Normal    Scheduled           pod/web-intro-846844b5c9-vxcdt    Successfully assigned ft152-ud15/web-intro-846844b5c9-vxcdt to minikube
77s         Normal    Scheduled           pod/web-intro-846844b5c9-nhz54    Successfully assigned ft152-ud15/web-intro-846844b5c9-nhz54 to minikube
77s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled up replica set web-intro-846844b5c9 from 1 to 3
77s         Normal    SuccessfulCreate    replicaset/web-intro-846844b5c9   Created pod: web-intro-846844b5c9-nhz54
76s         Normal    Created             pod/web-intro-846844b5c9-nhz54    Container created
76s         Normal    Started             pod/web-intro-846844b5c9-vxcdt    Container started
76s         Normal    Created             pod/web-intro-846844b5c9-vxcdt    Container created
76s         Normal    Pulled              pod/web-intro-846844b5c9-vxcdt    Container image "nginx:1.28.0-alpine" already present on machine and can be accessed by the pod
76s         Normal    Pulled              pod/web-intro-846844b5c9-nhz54    Container image "nginx:1.28.0-alpine" already present on machine and can be accessed by the pod
76s         Normal    Started             pod/web-intro-846844b5c9-nhz54    Container started
52s         Normal    SuccessfulCreate    replicaset/web-intro-54449bc466   Created pod: web-intro-54449bc466-cgcqc
52s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled up replica set web-intro-54449bc466 from 0 to 1
52s         Normal    Scheduled           pod/web-intro-54449bc466-cgcqc    Successfully assigned ft152-ud15/web-intro-54449bc466-cgcqc to minikube
51s         Normal    Pulling             pod/web-intro-54449bc466-cgcqc    Pulling image "nginx:1.29.0-alpine"
47s         Normal    Scheduled           pod/web-intro-54449bc466-5tnp6    Successfully assigned ft152-ud15/web-intro-54449bc466-5tnp6 to minikube
47s         Normal    SuccessfulDelete    replicaset/web-intro-846844b5c9   Deleted pod: web-intro-846844b5c9-vxcdt
47s         Normal    Started             pod/web-intro-54449bc466-k4nv4    Container started
47s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled up replica set web-intro-54449bc466 from 2 to 3
47s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled down replica set web-intro-846844b5c9 from 2 to 1
47s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled up replica set web-intro-54449bc466 from 1 to 2
47s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled down replica set web-intro-846844b5c9 from 3 to 2
47s         Normal    Started             pod/web-intro-54449bc466-cgcqc    Container started
47s         Normal    Created             pod/web-intro-54449bc466-k4nv4    Container created
47s         Normal    Killing             pod/web-intro-846844b5c9-vxcdt    Stopping container web
47s         Normal    SuccessfulCreate    replicaset/web-intro-54449bc466   Created pod: web-intro-54449bc466-5tnp6
47s         Normal    Pulled              pod/web-intro-54449bc466-cgcqc    Successfully pulled image "nginx:1.29.0-alpine" in 4.208s (4.208s including waiting). Image size: 22414794 bytes.
47s         Normal    SuccessfulDelete    replicaset/web-intro-846844b5c9   Deleted pod: web-intro-846844b5c9-nhz54
47s         Normal    SuccessfulCreate    replicaset/web-intro-54449bc466   Created pod: web-intro-54449bc466-k4nv4
47s         Normal    Scheduled           pod/web-intro-54449bc466-k4nv4    Successfully assigned ft152-ud15/web-intro-54449bc466-k4nv4 to minikube
47s         Normal    Created             pod/web-intro-54449bc466-cgcqc    Container created
47s         Normal    Killing             pod/web-intro-846844b5c9-nhz54    Stopping container web
47s         Normal    Pulled              pod/web-intro-54449bc466-k4nv4    Container image "nginx:1.29.0-alpine" already present on machine and can be accessed by the pod
46s         Normal    Killing             pod/web-intro-846844b5c9-dvw2q    Stopping container web
46s         Normal    Started             pod/web-intro-54449bc466-5tnp6    Container started
46s         Normal    Created             pod/web-intro-54449bc466-5tnp6    Container created
46s         Normal    SuccessfulDelete    replicaset/web-intro-846844b5c9   Deleted pod: web-intro-846844b5c9-dvw2q
46s         Normal    Pulled              pod/web-intro-54449bc466-5tnp6    Container image "nginx:1.29.0-alpine" already present on machine and can be accessed by the pod
46s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled down replica set web-intro-846844b5c9 from 1 to 0
32s         Normal    Scheduled           pod/web-intro-846844b5c9-sk6sc    Successfully assigned ft152-ud15/web-intro-846844b5c9-sk6sc to minikube
32s         Normal    SuccessfulCreate    replicaset/web-intro-846844b5c9   Created pod: web-intro-846844b5c9-sk6sc
31s         Normal    Pulled              pod/web-intro-846844b5c9-vqdsf    Container image "nginx:1.28.0-alpine" already present on machine and can be accessed by the pod
31s         Normal    Killing             pod/web-intro-54449bc466-cgcqc    Stopping container web
31s         Normal    Created             pod/web-intro-846844b5c9-vqdsf    Container created
31s         Normal    Started             pod/web-intro-846844b5c9-vqdsf    Container started
31s         Normal    Scheduled           pod/web-intro-846844b5c9-vqdsf    Successfully assigned ft152-ud15/web-intro-846844b5c9-vqdsf to minikube
31s         Normal    Killing             pod/web-intro-54449bc466-k4nv4    Stopping container web
31s         Normal    Started             pod/web-intro-846844b5c9-sk6sc    Container started
31s         Normal    Created             pod/web-intro-846844b5c9-sk6sc    Container created
31s         Normal    Pulled              pod/web-intro-846844b5c9-sk6sc    Container image "nginx:1.28.0-alpine" already present on machine and can be accessed by the pod
31s         Normal    SuccessfulDelete    replicaset/web-intro-54449bc466   Deleted pod: web-intro-54449bc466-k4nv4
31s         Normal    SuccessfulDelete    replicaset/web-intro-54449bc466   Deleted pod: web-intro-54449bc466-cgcqc
11s         Normal    ScalingReplicaSet   deployment/web-intro              (combined from similar events): Scaled up replica set web-intro-6d4c975bcd from 0 to 1
31s         Normal    ScalingReplicaSet   deployment/web-intro              Scaled down replica set web-intro-54449bc466 from 3 to 2
31s         Normal    Scheduled           pod/web-intro-846844b5c9-bq7gg    Successfully assigned ft152-ud15/web-intro-846844b5c9-bq7gg to minikube
31s         Normal    SuccessfulCreate    replicaset/web-intro-846844b5c9   Created pod: web-intro-846844b5c9-bq7gg
31s         Normal    SuccessfulCreate    replicaset/web-intro-846844b5c9   Created pod: web-intro-846844b5c9-vqdsf
30s         Normal    Created             pod/web-intro-846844b5c9-bq7gg    Container created
30s         Normal    Started             pod/web-intro-846844b5c9-bq7gg    Container started
30s         Normal    Pulled              pod/web-intro-846844b5c9-bq7gg    Container image "nginx:1.28.0-alpine" already present on machine and can be accessed by the pod
30s         Normal    SuccessfulDelete    replicaset/web-intro-54449bc466   Deleted pod: web-intro-54449bc466-5tnp6
30s         Normal    Killing             pod/web-intro-54449bc466-5tnp6    Stopping container web
11s         Normal    Pulling             pod/web-intro-6d4c975bcd-4dt7l    Pulling image "nginx:tag-ft152-che-non-esiste"
11s         Normal    Scheduled           pod/web-intro-6d4c975bcd-4dt7l    Successfully assigned ft152-ud15/web-intro-6d4c975bcd-4dt7l to minikube
11s         Normal    SuccessfulCreate    replicaset/web-intro-6d4c975bcd   Created pod: web-intro-6d4c975bcd-4dt7l
9s          Warning   Failed              pod/web-intro-6d4c975bcd-4dt7l    Error: ImagePullBackOff
9s          Normal    BackOff             pod/web-intro-6d4c975bcd-4dt7l    Back-off pulling image "nginx:tag-ft152-che-non-esiste"
9s          Warning   Failed              pod/web-intro-6d4c975bcd-4dt7l    Error: ErrImagePull
9s          Warning   Failed              pod/web-intro-6d4c975bcd-4dt7l    Failed to pull image "nginx:tag-ft152-che-non-esiste": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:tag-ft152-che-non-esiste": failed to resolve reference "docker.io/library/nginx:tag-ft152-che-non-esiste": docker.io/library/nginx:tag-ft152-che-non-esiste: not found
```

### Recupero del guasto: immagine iniziale e tre repliche

```text
2026-11-04T16:36:01+01:00
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                SELECTOR
deployment.apps/web-intro   3/3     3            3           2m36s   web          nginx:1.28.0-alpine   app=web-intro

NAME                                   DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES                           SELECTOR
replicaset.apps/web-intro-54449bc466   0         0         0       62s     web          nginx:1.29.0-alpine              app=web-intro,pod-template-hash=54449bc466
replicaset.apps/web-intro-6d4c975bcd   0         0         0       21s     web          nginx:tag-ft152-che-non-esiste   app=web-intro,pod-template-hash=6d4c975bcd
replicaset.apps/web-intro-846844b5c9   3         3         3       2m36s   web          nginx:1.28.0-alpine              app=web-intro,pod-template-hash=846844b5c9

NAME                             READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/web-intro-846844b5c9-bq7gg   1/1     Running   0          41s   10.244.0.11   minikube   <none>           <none>
pod/web-intro-846844b5c9-sk6sc   1/1     Running   0          42s   10.244.0.9    minikube   <none>           <none>
pod/web-intro-846844b5c9-vqdsf   1/1     Running   0          41s   10.244.0.10   minikube   <none>           <none>
```

### Fine guidato: file e cluster a una replica

```text
2026-11-04T16:36:12+01:00
# Micro-demo: Nginx standard, non il frontend completo del Catalogo.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-intro
  namespace: ft152-ud15
spec:
  replicas: 1
  # Conserviamo i template precedenti per l'esercizio di rollback.
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: web-intro
  template:
    metadata:
      labels:
        app: web-intro
    spec:
      containers:
        - name: web
          image: nginx:1.28.0-alpine
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                SELECTOR
deployment.apps/web-intro   1/1     1            1           2m47s   web          nginx:1.28.0-alpine   app=web-intro

NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/web-intro   ClusterIP   10.96.216.27   <none>        80/TCP    2m31s   app=web-intro

NAME                             READY   STATUS        RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/web-intro-846844b5c9-bq7gg   1/1     Running       0          52s   10.244.0.11   minikube   <none>           <none>
pod/web-intro-846844b5c9-sk6sc   1/1     Terminating   0          53s   10.244.0.9    minikube   <none>           <none>
pod/web-intro-846844b5c9-vqdsf   1/1     Terminating   0          52s   10.244.0.10   minikube   <none>           <none>
```

### Conclusione del guidato: riferimento conservato

```text
2026-11-04T16:36:21+01:00
# Micro-demo: Nginx standard, non il frontend completo del Catalogo.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-intro
  namespace: ft152-ud15
spec:
  replicas: 1
  # Conserviamo i template precedenti per l'esercizio di rollback.
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: web-intro
  template:
    metadata:
      labels:
        app: web-intro
    spec:
      containers:
        - name: web
          image: nginx:1.28.0-alpine
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                SELECTOR
deployment.apps/web-intro   1/1     1            1           2m56s   web          nginx:1.28.0-alpine   app=web-intro

NAME                                   DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES                           SELECTOR
replicaset.apps/web-intro-54449bc466   0         0         0       82s     web          nginx:1.29.0-alpine              app=web-intro,pod-template-hash=54449bc466
replicaset.apps/web-intro-6d4c975bcd   0         0         0       41s     web          nginx:tag-ft152-che-non-esiste   app=web-intro,pod-template-hash=6d4c975bcd
replicaset.apps/web-intro-846844b5c9   1         1         1       2m56s   web          nginx:1.28.0-alpine              app=web-intro,pod-template-hash=846844b5c9

NAME                             READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/web-intro-846844b5c9-bq7gg   1/1     Running   0          61s   10.244.0.11   minikube   <none>           <none>
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "5"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"web-intro","namespace":"ft152-ud15"},"spec":{"replicas":1,"revisionHistoryLimit":5,"selector":{"matchLabels":{"app":"web-intro"}},"template":{"metadata":{"labels":{"app":"web-intro"}},"spec":{"containers":[{"image":"nginx:1.28.0-alpine","imagePullPolicy":"IfNotPresent","name":"web","ports":[{"containerPort":80,"name":"http"}]}]}}}}
  creationTimestamp: "2026-11-04T15:33:25Z"
  generation: 8
  name: web-intro
  namespace: ft152-ud15
  resourceVersion: "4563"
  uid: 5a2af6b8-b874-4698-a62a-cf4459b5c79d
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: web-intro
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: web-intro
    spec:
      containers:
      - image: nginx:1.28.0-alpine
        imagePullPolicy: IfNotPresent
        name: web
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: "2026-11-04T15:34:35Z"
    lastUpdateTime: "2026-11-04T15:34:35Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2026-11-04T15:33:25Z"
    lastUpdateTime: "2026-11-04T15:35:55Z"
    message: ReplicaSet "web-intro-846844b5c9" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  observedGeneration: 8
  readyReplicas: 1
  replicas: 1
  terminatingReplicas: 0
  updatedReplicas: 1
Name:                     web-intro
Namespace:                ft152-ud15
Labels:                   <none>
Annotations:              <none>
Selector:                 app=web-intro
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.216.27
IPs:                      10.96.216.27
Port:                     http  80/TCP
TargetPort:               http/TCP
Endpoints:                10.244.0.11:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
apiVersion: v1
items:
- addressType: IPv4
  apiVersion: discovery.k8s.io/v1
  endpoints:
  - addresses:
    - 10.244.0.11
    conditions:
      ready: true
      serving: true
      terminating: false
    nodeName: minikube
    targetRef:
      kind: Pod
      name: web-intro-846844b5c9-bq7gg
      namespace: ft152-ud15
      uid: f7715100-cecb-4503-b5f1-e82ebd9a554a
  kind: EndpointSlice
  metadata:
    annotations:
      endpoints.kubernetes.io/last-change-trigger-time: "2026-11-04T15:36:12Z"
    creationTimestamp: "2026-11-04T15:33:41Z"
    generateName: web-intro-
    generation: 27
    labels:
      endpointslice.kubernetes.io/managed-by: endpointslice-controller.k8s.io
      kubernetes.io/service-name: web-intro
    name: web-intro-rr2sn
    namespace: ft152-ud15
    ownerReferences:
    - apiVersion: v1
      blockOwnerDeletion: true
      controller: true
      kind: Service
      name: web-intro
      uid: 6e722228-199c-4b76-ad17-442806be59e6
    resourceVersion: "4561"
    uid: 920539fe-4f14-4f3c-b94c-1fdc3973daa2
  ports:
  - name: http
    port: 80
    protocol: TCP
kind: List
metadata:
  resourceVersion: ""
State Recv-Q Send-Q Local Address:Port Peer Address:Port
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

```
