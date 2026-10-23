# UD10 — Verifica

## Parte A — Scelta singola

### 1. Una Docker image è:
- A. un processo in esecuzione
- B. un artefatto usato per creare container
- C. una VNet
- D. un volume Windows

**Risposta:** B

### 2. Nel comando `docker build -f docker/backend.Dockerfile .`, il punto finale rappresenta:
- A. la porta
- B. il build context
- C. il tag
- D. il registry

**Risposta:** B

### 3. `EXPOSE 8000`:
- A. pubblica automaticamente la porta sull'host
- B. documenta la porta prevista nell'immagine ma non sostituisce `-p`
- C. crea un NSG
- D. crea una rete

**Risposta:** B

### 4. `127.0.0.1:8080:80` significa:
- A. host 80 → container 8080
- B. host 127.0.0.1:8080 → container 80
- C. backend → frontend
- D. DNS → volume

**Risposta:** B

### 5. In Compose, due servizi sulla stessa rete possono normalmente raggiungersi tramite:
- A. IP statico obbligatorio
- B. nome del servizio
- C. subscription ID
- D. tag Git

**Risposta:** B

### 6. Dentro il container frontend, `localhost` indica:
- A. sempre il backend
- B. il container frontend stesso
- C. l'host Windows
- D. Azure

**Risposta:** B

### 7. `docker compose down -v`:
- A. conserva tutti i volumi
- B. rimuove anche i volumi del progetto
- C. fa push delle immagini
- D. crea container

**Risposta:** B

### 8. Un container `running`:
- A. è necessariamente healthy
- B. può essere running ma unhealthy
- C. non produce log
- D. non appartiene a una rete

**Risposta:** B

---

## Parte B — Risposte brevi

### 9. Distingui image, container e registry.

**Risposta:** L'image è un artefatto immutabile che contiene filesystem e configurazione necessari a creare un container. Il container è un'istanza runtime creata a partire da un'image, con la propria configurazione (env, porte, volumi, rete). Il registry è il servizio che memorizza e distribuisce le image (es. Docker Hub, ACR): da lì si fa `pull` e verso lì si fa `push`.

### 10. Spiega perché il build context dovrebbe essere limitato.

**Risposta:** Perché è l'insieme di file che Docker invia al builder e rende disponibili a `COPY`. Un context troppo grande rallenta la build, peggiora l'uso della cache e aumenta il rischio di includere file inutili o sensibili (`.git`, `.env`, credenziali, log). Si limita con `.dockerignore` e scegliendo una directory di build ristretta.

### 11. Distingui named volume e bind mount.

**Risposta:** Un named volume è gestito da Docker, identificato da un nome e salvato in un'area controllata dal daemon: è pensato per la persistenza e resta indipendente dai path dell'host. Un bind mount mappa direttamente una directory o un file dell'host dentro il container: è comodo in sviluppo (modifiche immediate), ma dipende dal filesystem e dai permessi dell'host ed è meno portabile.

### 12. Perché le variabili d'ambiente permettono di riusare la stessa immagine?

**Risposta:** Perché l'image resta identica e la differenza tra ambienti viene applicata a runtime tramite environment variable (es. `LOW_STOCK_THRESHOLD`, `APP_PORT`). Si può quindi usare lo stesso artefatto in contesti diversi cambiando solo la configurazione del container, senza ricostruire l'image: serve un `recreate`, non un `rebuild`.

### 13. Perché il backend Compose non deve necessariamente pubblicare una porta sull'host?

**Risposta:** Perché il backend deve essere raggiunto solo dal frontend attraverso la rete interna Docker, usando il nome del servizio (`http://backend:8000`). Pubblicare una porta sull'host non è necessario: aumenta la superficie esposta e può creare conflitti di porte. In UD10 solo il frontend pubblica `127.0.0.1:8080:80`; il backend usa `expose` come documentazione.

### 14. Quali comandi useresti per iniziare il troubleshooting di uno stack Compose che non risponde?

**Risposta:** `docker compose ps` per lo stato dei servizi, `docker compose logs <servizio>` per gli errori, `docker compose config` per verificare la configurazione risolta (YAML, env, porte, volumi). Poi controllerei healthcheck, variabili d'ambiente, mapping delle porte, rete/DNS e mount; infine deciderei se serve `recreate` o `rebuild`, applicando una modifica minima alla volta.

---

## Parte C — Scenario

> `docker compose ps` mostra frontend Running e backend Restarting. Il browser restituisce 502. Nei log backend compare `LOW_STOCK_THRESHOLD deve essere un intero, ricevuto: 'abc'`.

### 15. Qual è la causa più probabile e qual è la modifica minima?

**Risposta:** La causa più probabile è la variabile `LOW_STOCK_THRESHOLD` impostata a `abc`: il backend la legge all'avvio con `read_int_env` e, non riuscendo a convertirla in intero, termina con errore; Docker lo riavvia continuamente e Nginx restituisce 502 perché non trova un upstream disponibile. La modifica minima è impostare un valore intero valido, ad esempio `LOW_STOCK_THRESHOLD: "5"`, nel `compose.yaml` (o nella configurazione runtime), quindi ricreare il container con `docker compose up -d`.

### 16. È necessario ricostruire l'immagine? Quali verifiche eseguiresti dopo la correzione?

**Risposta:** No, non è necessario ricostruire l'image: codice e Dockerfile non sono cambiati, cambia solo una variabile d'ambiente runtime. Dopo la correzione verificherei `docker compose config`, eseguirei `docker compose up -d` e controllerei `docker compose ps` (backend `healthy`, frontend `running`), `docker compose logs backend` (nessun errore), `curl -i http://127.0.0.1:8080/health` (200), `/api/products` (200, `count` 4), `/api/products/P001` (200) e l'apertura del browser su `http://127.0.0.1:8080/` senza 502.

### 17. Una futura pipeline gira su `pool-ud09-wsl` e lo step `docker build` fallisce con errore di connessione al Docker daemon. Quale componente dell'ambiente controlleresti per primo e perché?

**Risposta:** Controllerei per primo il Docker daemon sull'ambiente che ospita l'Agent self-hosted: Docker Desktop avviato e integrazione WSL2 abilitata per la distro Ubuntu, oltre ai permessi dell'utente/servizio che esegue l'Agent (accesso al socket Docker, gruppo `docker`, eventuale `DOCKER_HOST`). L'errore indica che la CLI non raggiunge il motore, quindi il problema è nell'integrazione/daemon, non nel codice della pipeline.

### 18. Distingui, rispetto alla disponibilità dei tool, un self-hosted Agent da un Microsoft-hosted Agent.

**Risposta:** Un self-hosted Agent gira su una macchina gestita da noi (nel nostro caso WSL2/Docker): i tool disponibili sono quelli installati e mantenuti nell'ambiente (Docker, WSL2, accessi ACR) e persistono tra i job. Un Microsoft-hosted Agent gira su una VM gestita da Microsoft, nuova per ogni job: si può usare solo ciò che è preinstallato o installabile nel job, non si può contare su Docker/WSL2 locali né su stato persistente.

---

## Cleanup finale

- `docker compose down`:
- volume presente dopo `down`:
- `docker compose down -v`:
- volume rimosso:
- immagini UD10 rimosse:
- prune globale usato: NO
