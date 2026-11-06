# UD16 — Laboratorio autonomo

Ambiente: host Linux Debian, context `minikube`, namespace `ft152-catalogo`. Prove eseguite il 05/11/2026. Il laboratorio guidato è stato svolto per intero; i risultati sono riportati qui.

## 1. Configurazione: soglia 5 → 10 → 5

Manifest modificato: `k8s/ud16/configmap.yaml`, chiave `LOW_STOCK_THRESHOLD` da `'5'` a `'10'`, poi ripristinata a `'5'`. Il backend riceve la ConfigMap tramite `envFrom` e la monta anche in `/etc/catalog-config`.

Prove HTTP su `P001` con `stock: 8`:

| Stato | ConfigMap | Pod backend | Risposta |
|---|---|---|---|
| Iniziale | 5 | avviato con 5 | `stock_status: OK` |
| Dopo apply 10, senza restart | 10 | ancora quello vecchio | `stock_status: OK` |
| Dopo sostituzione Pod | 10 | nuovo Pod | `stock_status: LOW` |
| Ripristino 5 + restart | 5 | nuovo Pod | `stock_status: OK` |

La sola modifica della ConfigMap non cambia il processo già avviato: le variabili d'ambiente vengono lette all'avvio del container. È stato quindi necessario eliminare il Pod backend e lasciare che il Deployment ne creasse uno nuovo. Il file montato viene aggiornato dal kubelet, ma il programma deve rileggerlo esplicitamente.

## 2. Persistenza

- Prima: Pod `backend-5cfd7c8c-4j8jl`, IP `10.244.0.11`, `/runtime/counter.txt` = **2**.
- Sostituzione del solo Pod: `kubectl delete pod -l app=backend`, senza toccare Deployment e PVC.
- Dopo: Pod `backend-5cfd7c8c-42t2p`, IP `10.244.0.12`, `/runtime/counter.txt` = **2**.
- PVC `catalog-runtime`: `Bound`, 1 GiB, StorageClass `standard`.

Il valore è rimasto uguale dopo la ricreazione del Pod, quindi il dato è sopravvissuto alla sostituzione. Il solo stato `PVC Bound` non lo dimostra: dimostra che la richiesta ha trovato storage, non che il dato sia stato scritto e riletto. La prova non riguarda la perdita del nodo, la perdita dello storage o i backup.

## 3. Service: guasto intenzionale e recupero

Guasto introdotto con:

```bash
kubectl --context=minikube -n ft152-catalogo patch service backend \
  --type merge -p '{"spec":{"selector":{"app":"backend-broken"}}}'
```

- Sintomo: il Service `backend` esiste ancora e il DNS continua a risolvere `backend.ft152-catalogo.svc.cluster.local` verso `10.111.116.130`, ma il frontend risponde `502 Bad Gateway` su `/health`.
- Ipotesi: il selector non corrisponde più alle label dei Pod backend, quindi il Service non ha endpoint utilizzabili.
- Prova: l'EndpointSlice `backend-f8c2x` risultava senza endpoint; i Pod backend erano invece `Running`.
- Correzione: riapplicato il manifest versionato corretto `k8s/ud16/backend-service.yaml`, con `selector: app: backend`.
- Verifica finale: EndpointSlice con endpoint `10.244.0.12`; `/health` e `/api/products/P001` raggiungibili tramite l'ingresso persistente, senza port-forward.

## 4. Gateway e stato finale

Componenti installati: Helm 3.19.0 (in `~/.local/bin`), CRD Gateway API standard per NGINX Gateway Fabric 2.7.2, release `ngf` nel namespace `nginx-gateway` con Service NodePort.

Condizioni osservate:

- GatewayClass `nginx`: `Accepted=True`.
- Gateway `catalog`: `Accepted=True`, `Programmed=True`, indirizzo `10.103.51.165`.
- HTTPRoute `catalog`: `Accepted=True`, `ResolvedRefs=True`, hostname `catalogo.lab`.
- Service `catalog-nginx`: NodePort `30151`.

Percorso verificato: PC → container Compose `ft152-entry-ud16-ingresso-1` su `127.0.0.1:18016` → `minikube:30151` → proxy del Gateway → Service `frontend` → Pod frontend → Service `backend` → Pod backend → PVC.

Richieste eseguite con header Host corretto:

```bash
curl -H 'Host: catalogo.lab' http://127.0.0.1:18016/health
curl -H 'Host: catalogo.lab' http://127.0.0.1:18016/api/products/P001
```

Risultati: `/health` restituisce `status: ok`; `P001` restituisce `stock: 8` e `stock_status: OK`. Senza header `Host: catalogo.lab` la risposta è `404`, coerente con il matching della HTTPRoute.

Stato finale: Deployment `backend`, `frontend` e `catalog-nginx` con 1/1 repliche disponibili; PVC `catalog-runtime` ancora `Bound`; EndpointSlice backend con endpoint; Gateway e HTTPRoute presenti; ingresso Compose attivo. ConfigMap riportata a soglia 5.

## Collegamento architetturale e accesso

- Oggetto configurato e componente che realizza il comportamento: la ConfigMap fornisce le variabili al container backend; il selector del Service determina gli EndpointSlice usati per il traffico; Gateway e HTTPRoute vengono tradotti dal controller NGF nella configurazione del proxy `catalog-nginx`; il PVC monta lo storage hostpath in `/runtime`.
- Prova reale, momento e interpretazione: il 05/11/2026 sono stati osservati il cambio di risposta `OK → LOW → OK` dopo modifica ConfigMap e restart, il contatore `2` prima e dopo la sostituzione del Pod, e il `502` durante il guasto del selector seguito dal ripristino.
- Indirizzo e percorso verificato: `http://127.0.0.1:18016` con `Host: catalogo.lab`, attraverso il Gateway; non è stato usato un port-forward per la prova finale.
- Stato dell'ingresso locale e limiti della prova: container Compose attivo e persistente alla chiusura del terminale; è un accesso HTTP locale, senza TLS, DNS pubblico o alta disponibilità, e dipende da Docker e Minikube in esecuzione.
