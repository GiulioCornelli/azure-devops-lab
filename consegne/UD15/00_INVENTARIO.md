# UD15 — Inventario aggiornato

Partecipante: GiulioCornelli  
Data/ora e fuso: 2026-11-04 16:32 CET (UTC+1)  
Repository operativo e commit prima della prova: `/home/giulio/Corsi/Corso-Azure/azure-devops-lab`, branch `main...origin/main`, commit `50bd16f`

| Elemento | Versione / stato osservato | Intervento necessario ed esito |
|---|---|---|
| WSL/architettura, memoria e spazio | Non WSL: Debian GNU/Linux 13 (trixie), kernel `6.12.113+deb13-amd64`, architettura `x86_64`; RAM 31 GiB (22 GiB disponibili), swap 31 GiB; 566 GiB liberi su `/` (27% usato) | Nessuno; annotata la differenza rispetto a WSL2: ambiente Debian nativo |
| Docker Client/Server e context | Client `29.9.2`, Server `29.9.2` (Docker Engine Community), API `1.56`, context `default`; containerd `2.4.2`, runc `1.5.2` | Nessuno: Server raggiungibile |
| kubectl Client/Server | Client `v1.37.0` (Kustomize `v5.8.1`), Server `v1.37.0` | Nessuno: versioni allineate |
| Minikube e profilo | Minikube `v1.39.0`; profilo `minikube`, driver `docker`, runtime `containerd`, Kubernetes `v1.37.0`, 1 nodo; all'inizio della prova il profilo era fermo (`Stopped`) | Riavviato con `minikube start -p minikube --kubernetes-version=v1.37.0`; esito `Running`/`OK` |
| Context e nodo | Context `minikube` (namespace `default`); nodo `minikube` `Ready`, ruolo `control-plane`, `v1.37.0`, runtime `containerd://2.3.4`, età circa 5h23m; API `https://192.168.49.2:8443` | Nessuno dopo il riavvio del profilo |
| Porte 8081/8082 | Libere: `ss` non mostra alcun listener | Nessuna: porte disponibili per i port-forward |

Tempo setup effettivo, con download/attese: circa 1 minuto per il riavvio del profilo Minikube esistente (16:32–16:33); nessun download perché kubectl e Minikube erano già installati.  
Controllo funzionale cluster, output essenziale: `minikube status` mostra host, kubelet e apiserver `Running` e kubeconfig `Configured`; nodo `minikube` `Ready` con Kubernetes `v1.37.0`; Pod di `kube-system` in stato `Running`; namespace `ft152-ud15` assente (`NotFound`), come previsto prima del guidato.  
Modifiche Git preesistenti conservate: nessuna modifica tracciata; presenti solo file UD15 non tracciati (`consegne/UD15/*`), da aggiungere selettivamente.

Non inserire kubeconfig, certificati o token. Se un controllo non è stato possibile, scriverlo.

### Ambiente iniziale

```text
2026-11-04T16:33:20+01:00
/home/giulio/Corsi/Corso-Azure/azure-devops-lab
50bd16f laboratorio autonomo e verifica UD14
x86_64
               total        used        free      shared  buff/cache   available
Mem:            31Gi       6.6Gi        20Gi       605Mi       4.7Gi        24Gi
Swap:           31Gi          0B        31Gi
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p6  817G  209G  566G  27% /
Client: Docker Engine - Community
 Version:           29.9.2
 API version:       1.56
 Go version:        go1.26.10
 Git commit:        a82e528
 Built:             Tue Oct 20 18:45:13 2026
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          29.9.2
  API version:      1.56 (minimum version 1.40)
  Go version:       go1.26.10
  Git commit:       0367cbe
  Built:            Tue Oct 20 18:45:13 2026
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.4.2
  GitCommit:        b7a25261e029d68978bbf290df0a62fc819b3c51
 runc:
  Version:          1.5.2
  GitCommit:        v1.5.2-0-g29dd3dc2
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
Client Version: v1.37.0
Kustomize Version: v5.8.1
minikube version: v1.39.0
commit: 7a9f6a841470a207de8cf4bafcccee0969d8ba10
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
*         minikube   minikube   minikube   default
NAME       STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION                 CONTAINER-RUNTIME
minikube   Ready    control-plane   5h23m   v1.37.0   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.12.113+deb13-amd64 (amd64)   containerd://2.3.4
```
