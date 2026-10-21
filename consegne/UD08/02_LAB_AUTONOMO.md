# UD08 — Consegna laboratorio autonomo

## Baseline

- health: HTTP 200
- products: HTTP 200 su `/api/products` (4 prodotti)

## Errore introdotto

- configurazione modificata: `config.json`, `"api_prefix": "/api"` → `"api_prefix": "/api-v2"` (`index.html` non modificato)
- endpoint funzionante: `/api-v2/products` → HTTP 200 (e `/health` → 200)
- endpoint non funzionante: `/api/products` → HTTP 404 (`File not found`)
- comportamento frontend: la pagina `/` si carica (200) ma `fetch("/api/products")` riceve 404, quindi il frontend non mostra i prodotti e segnala l'errore

## Diagnosi

1. Sì, il backend è avviato: risponde alle richieste.
2. Sì, `/health` funziona (200).
3. Funziona `/api-v2/products`, il nuovo prefisso configurato nel backend.
4. Il frontend usa `/api/products`, il prefisso scritto in `index.html`.
5. Non è un problema di rete né di backend spento: è un contratto/configurazione incoerente, perché backend e frontend usano prefissi API diversi.

## Fix

- causa: il backend esponeva `/api-v2` mentre il frontend richiedeva `/api`
- fix: ripristinato `"api_prefix": "/api"` in `config.json`, la correzione minima per riportare backend e frontend allo stesso contratto
- environment aggiunto: `"environment": "local"` in `config.json`, perché dopo il ripristino `git diff` era vuoto (identico a `main`) e serviva una modifica reale e innocua da versionare; il server ignora la chiave

## Test finali

- `/health`: HTTP 200
- `/api/products`: HTTP 200
- `/api/products/P001`: HTTP 200
- `/api/products/XXX`: HTTP 404 (atteso, prodotto inesistente)
- browser: la pagina `/` risponde 200 e usa `/api/products`, che ora restituisce 200; non ho fatto un controllo visivo nel browser

## Git

- branch: `fix/ud08-api-prefix`
- `git diff` verificato: sì; dopo il fix era vuoto, dopo `environment` conteneva solo la riga aggiunta in `config.json`
- commit: `e17bf89` «fix: restore API contract and mark local environment»
- push: `git push -u origin fix/ud08-api-prefix`, eseguito. Prima ho pubblicato `main` (`8f07fe1..5d1573f`) perché contenesse già il Catalogo.
- PR: #2, https://github.com/GiulioCornelli/azure-devops-lab/pull/2 (`fix/ud08-api-prefix` → `main`)
- `gh pr diff` verificato: sì, un solo file modificato (`config.json`), solo la riga `environment`, nessun segreto
- merge: squash merge completato il 21/10/2026 alle 13:49 UTC, commit `1a31f91` «fix: restore API contract and mark local environment (#2)» su `main`
- main sincronizzata: sì, `git pull --ff-only`; `main` locale = `origin/main` su `1a31f91`

## Distinzione

- review collaborativa: nel LAB guidato la PR #1 è stata revisionata da una seconda persona (JesusAlvarado2005): `CHANGES_REQUESTED`, correzione, `APPROVED`
- auto-verifica PR individuale: nella PR #2 autore e revisore coincidono; ho solo controllato il mio diff con `gh pr diff`, senza una review indipendente
