# UD08 — Risposte domande concetti

## 1.
Perché DevOps non coincide con Azure DevOps?
**Risposta:**
DevOps è un modo di lavorare (cultura e pratiche: collaborazione, integrazione frequente, automazione, feedback continuo), mentre Azure DevOps è solo uno dei possibili strumenti che lo rendono praticabile. La stessa pratica si può realizzare con GitHub, GitLab, Jenkins, GitHub Actions, ecc.

## 2.
Distingui Continuous Integration, Continuous Delivery e Continuous Deployment.
**Risposta:**
- Continuous Integration: integrare frequentemente modifiche piccole e verificabili nella repository/progetto comune, riducendo i conflitti.

- Continuous Delivery: il software è sempre in uno stato rilasciabile; i controlli sono automatizzati, ma il passaggio in produzione richiede ancora una decisione esplicita.

- Continuous Deployment:  come il precedente, ma se una modifica supera tutti i controlli viene distribuita in produzione automaticamente, senza intervento umano.

## 3.
Che differenza c'è tra working tree, staging area e commit?
**Risposta:**
La working tree contiene i file su cui sto lavorando, con le modifiche non ancora registrate. La staging area (git add) contiene solo le modifiche che ho scelto di preparare per il prossimo commit: è un'area di preparazione, non ancora parte della cronologia. Il commit (git commit) registra uno snapshot stabile nella cronologia locale del repository. Solo dopo il git push il commit diventa visibile sul remote GitHub.
## 4.
Perché conviene creare un feature branch da `main` aggiornata?
**Risposta:**
Creare la feature da main aggiornata garantisce di partire dal codice più recente e pulito: la branch nasce da una base comune e i conflitti si riducono al minimo. Lavorare direttamente su main esporrebbe gli altri a modifiche non verificate e non revisionate.
## 5.
Che cosa rappresentano base branch e head branch in una Pull Request?
**Risposta:**
In una PR feature/x → main la head branch è feature/x, cioè la branch che contiene la proposta e i commit del contributor; la base branch è main, quella che dovrebbe ricevere e integrare la modifica. La PR è quindi il confronto (diff, commit, commenti, check) tra le due.

## 6.
Perché una review non dovrebbe limitarsi a controllare che il codice "funzioni"?
**Risposta:**
"Funziona" è solo il minimo. Una review deve verificare che la modifica risponda al requisito, che il diff contenga solo ciò che serve (niente file estranei), che non ci siano token o password, che il codice sia leggibile, che esistano verifiche coerenti e che non siano introdotte regressioni. Sono controlli che l'automazione fatica a fare e che proteggono il progetto nel tempo.
## 7.
Che cosa succede a una Pull Request quando il contributor aggiunge un nuovo commit allo stesso branch?
**Risposta:**
La Pull Request non viene sostituita: si aggiorna automaticamente. La PR punta a una branch, quindi quando il contributor esegue un nuovo commit e git push sulla stessa branch, diff, commit e check si aggiornano da soli e la discussione preesistente resta valida. Non serve aprire una nuova Pull Request.

## 8.
Che cosa provoca tipicamente un merge conflict?
**Risposta:**
Un conflitto nasce quando due branch modificano la stessa porzione di file in modo incompatibile, così Git non può determinare da solo quale contenuto tenere. Tipicamente: due persone cambiano la stessa riga (o lo stesso file) partendo dalla stessa base e si integrano a vicenda.
## 9.
Perché l'accesso del collaboratore deve essere rimosso al termine?
**Risposta:**
L'accesso del collaboratore è utile solo per la durata della collaborazione: mantenerlo accresce inutilmente la superficie di rischio (accesso a un repository personale, possibilità di push non autorizzati). Rimuoverlo applica il principio del least privilege: accesso necessario, solo alla risorsa necessaria, solo per il tempo necessario.

## 10.
Distingui frontend, backend/API, configurazione e dati nel Catalogo prodotti.
**Risposta:**
- Frontend: static/index.html, la pagina che il browser visualizza e il suo JavaScript che chiama l'API.
- Backend/API: server.py, il server HTTP che legge configurazione e dati e risponde in JSON.
- Configurazione: config.json, i parametri non funzionali (host, porta, api_prefix, low_stock_threshold).
- Dati: data/products.json, il contenuto della collezione prodotti.
## 11.
Quali endpoint principali espone l'applicazione?
**Risposta:**
GET /health (il servizio HTTP risponde), GET /api/products (la collezione dei prodotti), GET /api/products/<id> (un prodotto specifico, 404 se inesistente) e GET / (il frontend statico).

## 12.
Perché è utile eseguire `git diff` prima del commit?
**Risposta:**
git diff mostra esattamente le modifiche non ancora in staging: permette di rileggere ciò che si sta per registrare, individuare file estranei o errori prima che diventino cronologia, e capire se la modifica è ancora coerente come unica modifica logica. git diff --cached fa la stessa verifica dopo lo staging, subito prima del commit.