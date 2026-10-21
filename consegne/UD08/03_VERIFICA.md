# UD08 — Verifica

## Parte A

1. B
2. A
3. B
4. B
5. B
6. B
7. B
8. A

## Parte B

9. Continuous Delivery mantiene il software sempre pronto per il rilascio, ma il deploy in produzione richiede un'approvazione manuale. Continuous Deployment rilascia in produzione automaticamente ogni modifica che supera i test, senza intervento umano.

10. Il feature branch isola la modifica: `main` resta stabile e funzionante, si può lavorare e sperimentare senza rischi, e il cambiamento può essere rivisto tramite Pull Request prima di entrare in `main`.

11. La PR si aggiorna automaticamente e mostra anche i nuovi commit, perché punta alla branch e non a un singolo commit. Non serve aprirne una nuova (è quello che è successo nel lab con il commit di correzione dopo la review).

12. - Il contenuto risponde al requisito.
    - Non ci sono file estranei o non previsti.
    - Non ci sono token, password o altri dati sensibili.
    - Il codice è corretto e leggibile, e i test o le verifiche sono documentati.

13. Il permesso dato serve solo per quella collaborazione. Lasciarlo attivo viola il principio del minimo privilegio: la persona potrebbe continuare a scrivere sul repository, e se il suo account venisse compromesso l'attaccante avrebbe accesso al repo.

14. - Frontend: `static/index.html`, la pagina che il browser mostra all'utente.
    - Backend/API: `server.py`, che gestisce `/health`, `/api/products` e `/api/products/<id>`.
    - Configurazione: `config.json`, i parametri come la porta, separati dal codice.
    - Dati: `data/products.json`, l'elenco dei prodotti.

## Parte C

15. - `token.txt` è un segreto: non deve essere pubblicato nel repository, e anche se rimosso resta nella cronologia.
    - Il file di consegna di un'altra UD è fuori scopo: la PR dovrebbe avere una sola finalità.
    - Modifiche contemporanee a `config.json` e `server.py` senza spiegazione: non si capisce cosa cambia nel comportamento.
    - Non ci sono test HTTP documentati, quindi non si sa se l'applicazione funziona ancora.

16. 1. Chiedere di rimuovere `token.txt` dalla PR (e dalla cronologia, ruotando il token se è reale), e di togliere il file dell'altra UD.
    2. Chiedere una descrizione di cosa cambia in `config.json` e `server.py`, e rileggere il diff con attenzione.
    3. Far avviare il server e verificare con `curl` `/health` (200), `/api/products` (4 prodotti), `/api/products/P001` (200) e un id inesistente (404), documentando gli output.
    4. Rileggere `Files changed` dopo la correzione e approvare solo se la PR contiene solo i file previsti e i test sono documentati; poi fare il merge.
