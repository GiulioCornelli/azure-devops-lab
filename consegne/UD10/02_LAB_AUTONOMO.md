# UD10 — Consegna laboratorio autonomo

## Baseline

- compose ps: `catalogo-prodotti-backend-1` Up (healthy), `catalogo-prodotti-frontend-1` Up, `127.0.0.1:8080->80/tcp`
- health: `HTTP/1.1 200 OK` — `{"status":"ok","service":"catalog-backend","version":"2.0"}`

## Errore

- variabile: `LOW_STOCK_THRESHOLD`
- valore errato: `"not-a-number"`
- stato backend: `Exited (1)`; `docker compose up -d` termina con exit code 1 e `dependency failed to start`
- log/errore: `ValueError: invalid literal for int() with base 10: 'not-a-number'` e `ValueError: LOW_STOCK_THRESHOLD deve essere un intero, ricevuto: 'not-a-number'` (traceback in `server.py`, righe 21, 23 e 28)

## Diagnosi

- Sintomo: `docker compose up -d` non completa l'avvio; backend `Exited (1)`; il frontend resta Running ma `http://127.0.0.1:8080/health` restituisce `502 Bad Gateway`.
- Risultato atteso: backend `healthy`, `/health` 200 e `/api/products` 200 con `count` 4.
- Evidenza: `docker compose ps -a` mostra il backend `Exited (1)`; `docker compose logs backend` riporta il `ValueError`; `docker compose config` mostra `LOW_STOCK_THRESHOLD: not-a-number`; `curl -i http://127.0.0.1:8080/health` restituisce 502; la pagina statica `/` risponde 200 ma le chiamate API falliscono.
- Ipotesi: il valore non convertibile in intero fa terminare il processo Python all'avvio; Nginx non trova un upstream disponibile e risponde 502.
- Causa: `read_int_env("LOW_STOCK_THRESHOLD", 5)` esegue `int("not-a-number")` e l'eccezione non gestita interrompe il backend. Non essendoci una restart policy, il container resta `Exited (1)`.

## Fix

- modifica minima: ripristinare `LOW_STOCK_THRESHOLD: "5"` nel blocco `environment` del backend in `app/catalogo-prodotti/compose.yaml`; nessuna modifica a Dockerfile, rete o porte.
- rebuild necessario?: No
- motivazione: l'errore è in una variabile runtime del `compose.yaml`, non nel contenuto dell'image. L'image è rimasta invariata; Compose ricrea il container con la nuova environment variable.

## Test

- backend healthy: sì — `Up (healthy)`
- health: `HTTP/1.1 200 OK` con `{"status":"ok","service":"catalog-backend","version":"2.0"}`
- products: `HTTP 200`, `count: 4` (P001 `OK`, P002 `LOW`, P003 `OK`, P004 `LOW`)
- browser: `http://127.0.0.1:8080/` raggiungibile (HTTP 200); `/api/products` attraverso Nginx risponde 200, quindi la UI carica i prodotti.

## Modifica conservata

- APP_ENV: `"local-docker"` aggiunto nel blocco `environment` già esistente del backend
- compose config: `APP_ENV: local-docker`, `LOW_STOCK_THRESHOLD: "5"`, `APP_PORT: "8000"`, `RUNTIME_DIR: /runtime`
- test: `docker compose up -d` completato, backend `healthy`, `/health` 200; nel container `APP_ENV=local-docker`

## Git

- branch: `fix/ud10-invalid-threshold` (creato localmente)
- commit: non eseguito (su richiesta dell'utente)
- PR: non eseguita (su richiesta dell'utente)
- diff verificato: `git diff -- app/catalogo-prodotti/compose.yaml` mostra la sola aggiunta di `APP_ENV: "local-docker"`; il threshold è tornato a `"5"`. Il file di consegna `03_VERIFICA.md` risulta modificato a parte.
- merge: non eseguito (su richiesta dell'utente)
- nota: la preparazione di `app/catalogo-prodotti` è stata salvata nel commit `993561f` su `main` e pushata prima della richiesta di non eseguire operazioni Git; nessun commit/push è stato fatto dopo tale richiesta.

## Passaggio alla verifica

- stack mantenuto attivo: sì
