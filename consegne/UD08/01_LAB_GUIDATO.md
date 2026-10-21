# UD08 — Consegna laboratorio guidato

## Repository

- repository: GiulioCornelli/azure-devops-lab
- branch principale: main
- `gh auth status` verificato: sì, account GiulioCornelli autenticato su github.com (protocollo SSH, scope `gist`, `read:org`, `repo`)
- working tree iniziale pulito: sì (`main` allineata a `origin/main`)

## Collaborazione ricevuta sul mio repository

- collaborator: JesusAlvarado2005
- invito accettato: sì (nessun invito pendente; il collaboratore ha poi pubblicato una branch sul repository)
- branch contributor: `feature/ud08-collab-JesusAlvarado2005`
- numero PR: #1
- URL PR: https://github.com/GiulioCornelli/azure-devops-lab/pull/1
- prima review: `CHANGES_REQUESTED` (12:38 UTC) sul commit `fc628ef`
- modifica richiesta: aggiungere la sezione `## Esito` con la frase «Review completata e modifica corretta.»
- nuovo commit: `ab2a364` «docs: address UD08 review», sulla stessa PR
- approvazione/commento finale: `APPROVED` (12:41 UTC) sul commit `ab2a364`
- merge: squash and merge, commit `8f07fe1` «UD08: collaboration evidence (#1)» su `main`; `docs/ud08-collaboration.md` presente in locale dopo `git pull --ff-only`
- branch remota eliminata: no, `feature/ud08-collab-JesusAlvarado2005` esiste ancora su origin
- collaboratore rimosso: sì, JesusAlvarado2005 non compare più tra i collaboratori del repository (restano GiulioCornelli ed EttorePannain)

## Collaborazione eseguita sul repository altrui

- repository: JesusAlvarado2005/azure-devops-lab
- branch: `feature/ud08-collab-GiulioCornelli` → `main`
- numero PR: #1 (https://github.com/JesusAlvarado2005/azure-devops-lab/pull/1)
- prima review ricevuta: `CHANGES_REQUESTED` (12:38 UTC), richiesta della sezione `## Esito`
- correzione eseguita: commit `f322195` «docs: address UD08 review» sulla stessa PR (il primo commit era `557cfe6`)
- merge completato: sì, squash and merge alle 12:42 UTC, commit `fa36f5b` su `main`, dopo `APPROVED` alle 12:41 UTC

## Conflitto locale

- branch A: `lab/conflict-a` (commit `5cef040`, `PORT=9000`), creata da `lab/conflict-base`
- branch B: `lab/conflict-b` (commit `58ad449`, `PORT=7000`), creata dalla stessa base `lab/conflict-base` (commit `83c8e79`, `PORT=8000`)
- file: `ud08-conflict.txt`
- marker osservati: `<<<<<<< HEAD`, `=======`, `>>>>>>> lab/conflict-a`, con `PORT=7000` e `PORT=9000` ai due lati: la stessa riga era stata modificata in modo diverso
- contenuto finale scelto: una sola riga `PORT=8000`, il valore richiesto dall'esercizio (non una delle due versioni in conflitto)
- commit risoluzione: `lab: resolve port conflict` (`797eebe`, merge su `lab/conflict-b`)
- cleanup completato: sì, tornato su `main` ed eliminate le tre branch locali `lab/conflict-a`, `lab/conflict-b` e `lab/conflict-base`; `main` non contiene `ud08-conflict.txt`

## Catalogo prodotti

- server avviato: `python3 server.py` da `laboratori/UD08/app/catalogo-prodotti`; messaggio «Catalogo prodotti in ascolto su http://127.0.0.1:8000»
- `/health`: HTTP 200, `{"status": "ok", "service": "catalogo-prodotti", "version": "1.0"}`
- `/api/products`: HTTP 200, `count = 4`
- `/api/products/P001`: HTTP 200, Notebook Pro 14, prezzo 1299.0, stock 8
- `/api/products/XXX`: HTTP 404, `{"error": "product_not_found", "product_id": "XXX"}`; atteso, perché il prodotto non esiste
- frontend browser: `http://127.0.0.1:8000/` risponde 200 e la pagina carica i prodotti con `fetch("/api/products")`
- prodotti restituiti: 4 (P001 Notebook Pro 14, P002 Monitor 27 UHD, P003 Dock USB-C, P004 Keyboard Business)
- prodotto LOW: P002 (stock 4) e P004 (stock 2), perché `stock <= low_stock_threshold` (5); P001 e P003 sono OK

## Architettura

- frontend: `static/index.html`, pagina servita dal server che chiama l'API dal browser
- backend/API: `server.py`, server HTTP Python (`ThreadingHTTPServer`) che serve l'API e i file statici, e calcola `stock_status`
- configurazione: `config.json` (host `127.0.0.1`, porta `8000`, prefisso API `/api`, soglia stock basso `5`)
- dati: `data/products.json`, elenco di 4 prodotti (id, nome, categoria, prezzo, stock)
- endpoint: `GET /health`, `GET /api/products`, `GET /api/products/{id}` (404 se non esiste)

## Baseline Git

- commit: `5d1573f` «feat: add local product catalog», che aggiunge `laboratori/UD08/app/catalogo-prodotti` (5 file)
- push/PR: non ancora eseguiti, `main` è avanti di 2 commit rispetto a `origin/main`
- stato finale main: working tree pulito, `main` locale su `5d1573f`
