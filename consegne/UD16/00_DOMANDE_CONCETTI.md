# UD16 — Inventario dei concetti e prerequisiti

Spiega con parole tue in che cosa differiscono ConfigMap, Secret, PV, PVC, Service e Gateway. Indica la postazione e il context Kubernetes effettivamente usati.

ConfigMap e Secret distribuiscono configurazione ai Pod: la prima per valori non sensibili, il secondo per dati riservati (codificati Base64, non cifrati). PV e PVC riguardano lo storage: il PV è la risorsa disponibile, il PVC è la richiesta dell'applicazione. Service dà un indirizzo stabile verso Pod selezionati; Gateway descrive l'ingresso HTTP esterno e il percorso verso i Service.

## Oggetti e relazioni

1. In che cosa differiscono ConfigMap e Secret?

   La ConfigMap contiene dati non sensibili (es. `LOW_STOCK_THRESHOLD`), leggibili e versionabili senza particolari cautele. Il Secret è pensato per dati riservati (password, token) e richiede RBAC e gestione attenta delle credenziali. Base64 non è cifratura: non protegge il valore da solo.

2. Che cosa significa montare una ConfigMap come file rispetto a usarla come variabile d'ambiente?

   Come variabile, il valore viene letto dal processo all'avvio: modificare la ConfigMap non aggiorna il processo già in esecuzione, serve un nuovo Pod. Come file montato, la ConfigMap compare come file nel filesystem del container, aggiornabile dal kubelet; il programma deve però rileggerlo. Nel laboratorio il backend usa entrambi i modi per confrontarli.

3. Che cosa chiedono PVC e StorageClass?

   Il PVC chiede spazio con una certa capacità e modalità di accesso (es. 1 GiB ReadWriteOnce). La StorageClass definisce come il cluster predispone lo storage, indicando il provisioner da usare. Il PVC diventa `Bound` quando trova o crea un PV corrispondente; questo non dimostra ancora che i dati sopravvivano.

4. Qual è il rapporto fra Service, selector, label ed EndpointSlice?

   Il Service espone un indirizzo stabile e seleziona i Pod tramite `selector` confrontato con le `label` dei Pod. Gli EndpointSlice elencano gli endpoint effettivamente associati al Service. Se selector e label non coincidono, il Service esiste e il DNS risolve, ma non ha endpoint e le richieste falliscono.

5. Quali ruoli hanno GatewayClass, Gateway, HTTPRoute e controller?

   GatewayClass indica l'implementazione disponibile (es. NGINX), Gateway configura i listener (HTTP sulla porta 80), HTTPRoute definisce host e percorsi da inoltrare a un Service. Il controller osserva questi oggetti e configura il proxy che realizza davvero il traffico. Senza controller o CRD, i manifest Gateway non producono un ingresso funzionante.

## Prerequisiti osservati

- Postazione: host Linux Debian (`Linux 6.12.113+deb13-amd64`), terminale con `kubectl` e profilo Minikube `minikube`.
- Context Kubernetes corrente: `minikube`.
- Stato al momento della compilazione: profilo Minikube presente ma **fermo** (control plane, kubelet e apiserver `Stopped`), quindi i controlli su nodi, StorageClass e CoreDNS non sono eseguibili finché il cluster non viene avviato.
- Helm: non disponibile (`helm` non trovato nel `PATH`).

## Schema o esempio significativo

```text
Browser -> ingresso Docker :18016 -> NodePort del Gateway -> proxy Nginx
        -> Service frontend -> Pod frontend -> Service backend -> Pod backend -> PVC /runtime
```

La configurazione arriva da ConfigMap/Secret, il contatore vive sul PVC, il nome `backend` è risolto da CoreDNS e il percorso HTTP esterno è descritto da Gateway e HTTPRoute.
