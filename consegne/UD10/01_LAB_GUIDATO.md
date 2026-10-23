# UD10 — Consegna laboratorio guidato

## Preflight

- `docker version`: `29.9.2` (Client e Server Docker Engine 29.9.2)
- `docker compose version`: `v5.6.1`
- daemon: raggiungibile — `docker info` restituisce Server 29.9.2, storage driver `overlayfs`
- WSL2: non applicabile in questa sessione: host Linux nativo (kernel `6.12.113+deb13-amd64`), nessuna distro WSL2 rilevata
- RESULT: Docker da WSL2: N/A; Self-hosted future Docker readiness: OK (daemon raggiungibile e comandi Docker funzionanti)

## Build backend

- image: `catalog-backend`
- tag: `:ud10`
- build context: `.` (root di `app/catalogo-prodotti`)
- Dockerfile: `docker/backend.Dockerfile`
- layer/history osservati: image ID `2a5d63b3e9ee`, dimensione circa 176 MB. Riconosciuti `FROM python:3.13-slim`, `WORKDIR /app`, `COPY backend/server.py /app/server.py`, `RUN useradd --create-home --uid 10001 appuser && mkdir -p /runtime && chown ...`, `USER appuser`, `ENV APP_HOST/APP_PORT/LOW_STOCK_THRESHOLD/RUNTIME_DIR`, `EXPOSE [8000/tcp]`, `CMD ["python" "/app/server.py"]`.

## Container singolo

- nome: `catalog-backend-ud10`
- porta: `127.0.0.1:8000` host → `8000/tcp` container
- health: `HTTP 200` — `{"status":"ok","service":"catalog-backend","version":"2.0"}`
- products: `HTTP 200` — `count: 4`
- log: `Catalog backend listening on http://0.0.0.0:8000 threshold=5 runtime=/runtime`; richieste `GET /health` 200 e `GET /api/products` 200
- environment verificato: `APP_HOST=0.0.0.0`, `APP_PORT=8000`, `LOW_STOCK_THRESHOLD=5`, `RUNTIME_DIR=/runtime` (da `docker inspect`)

## Compose

- backend: `Up (healthy)`, porta interna `8000/tcp`, immagine `catalog-backend:ud10`
- frontend: `Up`, `127.0.0.1:8080->80/tcp`, immagine `catalog-frontend:ud10`
- rete: `catalogo-prodotti_catalog-net` (driver `bridge`)
- volume: `catalogo-prodotti_catalog-runtime`
- frontend URL: `http://127.0.0.1:8080/`
- backend healthy: sì
- `/health`: `200 OK`
- `/api/products`: `200 OK`, `count: 4`
- P001: `200 OK`
- XXX: `404 Not Found` con `{"error":"product_not_found","product_id":"XXX"}`

## Networking

- `backend` risolto dal frontend: `172.21.0.2 backend backend` (da `getent hosts backend`)
- `localhost:8000` dal frontend: connessione rifiutata — `wget: can't connect to remote host: Connection refused` (exit 1)
- spiegazione: dentro il container frontend `localhost` indica il frontend stesso, non il backend. Il nome `backend` è il nome del servizio Compose e viene risolto dal DNS interno Docker sulla rete `catalog-net`; per questo Nginx usa `http://backend:8000`.

## Environment

- threshold iniziale: `LOW_STOCK_THRESHOLD: "5"`
- threshold temporaneo: `LOW_STOCK_THRESHOLD: "10"`
- effetto osservato: con soglia 10 il prodotto P001 (stock 8) passa da `stock_status: OK` a `stock_status: LOW`; `docker compose up -d` ricrea il solo backend con la nuova variabile runtime, senza rebuild dell'image.
- valore ripristinato: `LOW_STOCK_THRESHOLD: "5"`; P001 torna `stock_status: OK`.

## Volume

- counter before: `4` (valore più alto dopo le chiamate a `/api/counter`)
- counter after recreate: `5` (dopo `docker compose down` e `docker compose up -d`)
- persistenza PASS/FAIL: PASS
- volume: `catalogo-prodotti_catalog-runtime` (named volume, ancora presente dopo `docker compose down`)

## Lifecycle

- restart test: `docker compose restart backend` completato; backend `Up (healthy)`; `GET /health` via Nginx `200 OK`; frontend non ricreato.
- log backend: avvio con `Catalog backend listening on http://0.0.0.0:8000 threshold=5 runtime=/runtime`; healthcheck e richieste HTTP rispondono `200`.
- log frontend: Nginx `1.31.8` avviato, worker process attivi; richieste `/health` e `/api/products` inoltrate al backend con risposta `200`.

## Git

- commit: `993561f` — `feat: containerize product catalog with Docker Compose` (asset `app/catalogo-prodotti`), eseguito prima della richiesta di non committare. Le modifiche successive (`APP_ENV` nel compose e file di consegna) restano non committate.
- push/PR: `git push origin main` eseguito per il commit `993561f`; nessuna PR (non richiesta dal laboratorio guidato).

Nota: nella repository non era presente `app/catalogo-prodotti`; gli asset Docker UD10 sono stati copiati dai materiali del corso.
