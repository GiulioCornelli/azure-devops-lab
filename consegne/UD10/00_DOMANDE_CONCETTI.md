# UD10 — Risposte alle domande sui concetti

## 1.
Qual è la differenza fra codice sorgente, image e container?
**Risposta:**
- codice sorgente: il codice sorgente e' il codice che compone il software
- image: l'immagine sono l'insieme di istruzioni che permettono di ricreare un container
- container: sono delle instanze di un immagine, ed e' considerato come una macchina virtuale molto piu' leggera, ma ha caratteristiche diverse perche' rispetto ad una macchina virtuale classica. Ad esempio condivide il kernel della macchina ospitante.

## 2.
Che cosa fa `docker build` e che cosa **non** fa?
**Risposta:**
docker build legge il Dockerfile, parte dall'image base indicata da FROM, e combina codice e configurazione presi dal build context eseguendo le istruzioni per produrre una nuova image locale, organizzata in layer con cache. Non avvia l'applicazione, non esegue CMD, non crea container, non pubblica porte e non applica configurazioni runtime: quello lo fa docker run

## 3.
Che ruolo hanno Dockerfile, build context e `.dockerignore` nella creazione di un'image?
**Risposta:**
- Dockerfile: la "ricetta", descrive come costruire l'image (istruzioni FROM, WORKDIR, COPY, RUN, ...).
- Build context: l'insieme dei file che il builder può usare; è la directory indicata a docker build (nel nostro caso .). Solo i file dentro il context possono essere copiati con COPY.
- .dockerignore: riduce il context escludendo file inutili o sensibili (.git, __pycache__, .env, ...). Migliora efficienza e sicurezza. Non va confuso con .gitignore.

## 4.
Se l'image di FROM non è locale, cosa succede?
**Risposta:**
Docker la recupera da un registry configurato, normalmente Docker Hub: FROM python:3.13-slim → se assente localmente, pull dal registry. La nostra image è quindi costruita sopra un'image base che porta già filesystem e runtime Python.

## 5.
Distingui `RUN` e `CMD`.
**Risposta:**
- RUN viene eseguito durante la build e le sue modifiche entrano nell'image (es. useradd, mkdir, chown).
- CMD non viene eseguito durante la build: definisce il comando predefinito eseguito quando nasce il container (python /app/server.py).

## 6.
Perché modificare `server.py` non modifica l'image?
**Risposta:**
Il container esegue la copia di server.py inserita nell'image al momento del COPY, non il file nel repository. L'image è un artefatto immutabile: per incorporare modifiche serve ricostruire l'image (docker compose up -d --build). Inoltre cambia il layer del COPY e invalidando la cache possono essere ricostruiti anche i layer successivi.

## 7.
A cosa serve il tag `catalog-backend:ud10`?
**Risposta:**
A dare un nome riferibile all'image: catalog-backend è il nome del repository locale, ud10 il tag (etichetta/versione). Serve per richiamarla in docker run/Compose. latest è solo un tag convenzionale, non significa "la più nuova".

## 8.
Cosa succede, in ordine, con `docker run catalog-backend:ud10`?
**Risposta:**
Docker prende l'image → crea un nuovo container → applica la configurazione runtime (env, porte, volumi, rete) → esegue il CMD (python /app/server.py). Da una stessa image si possono creare più container.

## 9.
Distingui `EXPOSE 8000` da `--publish 127.0.0.1:8000:8000`.
**Risposta:**
- EXPOSE 8000 è solo informazione/documentazione nell'image: l'app ascolta su quella porta, ma non la rende raggiungibile dall'host.
- --publish 127.0.0.1:8000:8000 crea il collegamento reale host→container al runtime: 127.0.0.1:8000 (host) → porta 8000 (container), solo in locale.

## 10.
Quale problema risolve Compose rispetto ai comandi manuali?
**Risposta:**
Evita di dover eseguire a mano molti comandi (docker build, network create, volume create, run) con il rischio di dimenticare parametri, usare porte/reti sbagliate, o avviare i servizi nell'ordine errato. Descrive lo stato desiderato in YAML e lo realizza con un solo comando.

## 11.
Distingui Dockerfile e `compose.yaml`.
**Risposta:**
- Dockerfile: descrive come costruire una singola image.
- Compose: descrive come far funzionare insieme più servizi/container (image, reti, volumi, env, dipendenze, healthcheck). Compose non sostituisce il Dockerfile: lo usa per le build.

## 12.
Cosa crea/gestisce Compose in UD10?
**Risposta:**
Due servizi/container (backend e frontend), due image (catalog-backend:ud10, catalog-frontend:ud10), una rete catalog-net, un volume catalog-runtime, la pubblicazione di 127.0.0.1:8080, l'healthcheck del backend e la dipendenza del frontend dal backend healthy.

## 13.
Perché `docker compose up -d --build` costruisce sia backend sia frontend?
**Risposta:**
Perché entrambi i servizi nel compose.yaml hanno una sezione build: con context e dockerfile. Compose legge quei Dockerfile ed esegue le build prima di creare i container.

## 14.
Perché il backend non è pubblicato direttamente sull'host?
**Risposta:**
Per scelta architetturale: il backend è interno e deve essere raggiunto solo dal frontend tramite la rete catalog-net. Solo il frontend espone 127.0.0.1:8080:80. (Nel test isolato con docker run invece pubblicavamo la 8000.)

## 15.
Perché Nginx usa `http://backend:8000` e non `localhost:8000`?
**Risposta:**
Dentro il container frontend localhost è il frontend stesso, non il backend. backend è il nome del servizio Compose, risolto dal DNS interno Docker sulla rete catalog-net.

## 16.
Qual è la funzione di `catalog-net`?
**Risposta:**
È la rete bridge privata che collega backend e frontend, abilitando il DNS interno: il frontend raggiunge il backend per nome senza conoscere gli IP.

## 17.
Qual è la funzione di `catalog-runtime`?
**Risposta:**
È un named volume montato su /runtime nel backend: rende persistenti i dati indipendentemente dal ciclo di vita del container. Sopravvive a docker compose down; si elimina con docker compose down -v.

## 18.
Perché `running` ≠ `healthy`?
**Risposta:**
running significa solo che il processo del container esiste. healthy significa che l'healthcheck applicativo definito (GET /health) ha avuto successo. Sono due livelli diversi: il processo può girare ma il servizio non essere pronto o non rispondere.

## 19.
Cosa fa `depends_on: condition: service_healthy`?
**Risposta:**
Fa sì che il frontend venga avviato solo dopo che il backend è healthy, cioè dopo che il suo healthcheck è passato. Rende esplicito il rapporto tra ordine di avvio e prontezza applicativa (non sostituisce tutta la resilienza di un'app reale).

## 20.
Distingui rebuild e recreate.
**Risposta:**
- Rebuild: ricostruire l'image quando cambia codice o Dockerfile (docker compose up -d --build).
- Recreate: ricreare il container con la stessa image quando cambia solo la configurazione runtime (es. LOW_STOCK_THRESHOLD), senza rebuild.

## 21.
Qual è l'ordine di diagnosi di uno stack Compose che non risponde?
**Risposta:**
docker compose ps → docker compose logs <servizio> → docker compose config → verificare health → environment → porte → rete/DNS → mount/volume → decidere se serve recreate o rebuild → fare una modifica minima → ripetere il test. Principio: prima osservare, poi ipotizzare, infine modificare.

## 22.
Come il lavoro manuale di UD10 verrà riutilizzato nelle pipeline?
**Risposta:**
Le stesse operazioni (docker build, push, immagini versionate) saranno eseguite da un Agent di pipeline (UD14/UD15): build e push su ACR, deployment e smoke test. Con self-hosted Agent gira nello stesso ambiente WSL2/Docker; con Microsoft-hosted su ambiente gestito. Capire a mano build, run, rete, volumi e troubleshooting è il prerequisito per automatizzarli.
