# UD07 — Verifica

## Parte A

1.A
2.B
3.B
4.A
5.B
6.B
7.B
8.B

## Parte B

9. **Activity Log, Metrics e Logs**
   - *Activity Log*: eventi del **control plane** della subscription/risorsa ("chi ha fatto cosa",
     operazioni ARM: create, update, delete, start, stop). Una riga per evento, retention di 90 giorni.
     Risponde a "chi/cosa/cosa è successo a livello di gestione".
   - *Metrics*: serie **numeriche** campionate automaticamente dalle risorse (CPU %, UsedCapacity,
     Transactions), con granularità fissa (minuti/ore) e aggregazioni (Avg/Min/Max/Total).
     Risponde a "come si comporta la risorsa nel tempo".
   - *Logs*: **contenuto testuale/strutturato** generato dalle risorse o dalle applicazioni
     (diagnostic logs, syslog, trace), raccolto nel Log Analytics workspace e interrogabile con KQL.
     Risponde a "cosa è successo dentro la risorsa".

10. **Idempotenza**: un'operazione è idempotente se eseguirla più volte produce **lo stesso stato finale**
    dell'eseguirla una volta sola, senza effetti collaterali aggiuntivi.
    Esempio amministrativo: lo script del lab — se `rg-ud07-auto` non esiste lo crea, se esiste lo riutilizza
    e in entrambi i casi riscrive gli stessi tag `UD=07`: rieseguendolo il RG non viene duplicato né modificato
    in modo anomalo. Al contrario, un `az group create` sempre eseguito fallirebbe alla seconda run.

11. **`table` vs `tsv`**
    - `table`: formato per **lettura umana**, allineato in colonne con intestazioni e trattini;
      non è pensato per essere parsato da uno script.
    - `tsv`: valori separati da tab, **una riga per elemento, senza intestazioni né decorazioni**:
      è il formato adatto a incapsulare un singolo valore in una variabile Bash
      (`SUB_ID=$(az account show --query id -o tsv)`).

12. **Log Analytics workspace ≠ diagnostic setting**
    - Il **workspace** è il **destinatario**: il repository dove i dati vengono *immagazzinati*
      e dove poi scrivi le query KQL (ha un ID, una regione, un costo di ingestion).
    - Il **diagnostic setting** è il **collegamento/pipeline**: definisce *quali categorie di log
      della risorsa* (per l'Activity Log è a livello subscription) vanno instradate *verso quale
      destinazione* (workspace, Storage Account, Event Hub).
    Senza diagnostic setting i dati non arrivano al workspace; senza workspace il diagnostic setting
    non ha dove mandarli: sono due pezzi distinti dello stesso flusso.

13. **Alert rule vs Action Group**
    - **Alert rule**: la *condizione di valutazione* — scope, metrica, criterio/soglia, finestra e
      frequenza di valutazione, severity. Decide **quando** scatta.
    - **Action Group**: l'elenco delle **azioni/notifiche** da eseguire quando un alert scatta
      (e-mail, SMS, webhook, runbook). Decide **cosa succede** dopo.
    La stessa Action Group può essere collegata a molte regole e viceversa: sono oggetti separati.

14. **Correlazione temporale ≠ causalità**
    Due eventi che si susseguono possono dipendere da una **terza variabile comune** o essere
    del caso (`post hoc ergo propter hoc`). Il fatto che B segua A non implica che A abbia prodotto B:
    servono evidenza del meccanismo (cosa è stato modificato, nesso tecnico con la metrica),
    riproducibilità e possibili test di esclusione (rollback, evento di controllo).

## Parte C

15. **Fatti accertabili con certezza**
    - Alle 10:15 la risorsa è stata modificata (premessa).
    - Alle 10:16 l'Activity Log registra una `write` con esito **riuscita**: l'operazione ARM si è conclusa.
    - Alle 10:20 una metrica è aumentata: esiste un punto dati con valore più alto.
    - Alle 10:25 un alert è passato a **Fired**: la sua condizione è stata soddisfatta nella finestra di valutazione.
    - Tutti gli eventi sono ordinati temporalmente nella stessa subscription.
    **Non** si può affermare che la modifica abbia causato l'aumento della metrica né l'alert.

16. **Analisi necessaria prima di affermare la causalità**
    - Cosa è stato modificato esattamente (categoria operazione, risorsa, proprietà toccate)
      e se quel campo entra nel calcolo della metrica che è salita.
    - Verificare che l'incremento della metrica sia avvenuto **dentro la finestra di valutazione
      dell'alert** e non prima (sennò l'aumento non è la causa dello scatto).
    - Cercare cause alternative nello stesso intervallo: altre `write` nell'Activity Log,
      attività dell'applicazione, job, scaling, outage di servizio (Event Health/Service Health).
    - Controllare il nesso tecnico nei log/diagnostic logs (es. transazioni aumentate → cosa le ha generate).
    - Test di conferma: rollback della modifica e osservazione della metrica, oppure riproducibilità
      della stessa modifica in un ambiente controllato.

---

## Cleanup finale della UD07

Controlli preliminari eseguiti prima di ogni cancellazione:
- subscription corretta: `Azure subscription 1` / `giulio.cornelli05@gmail.com`
- diagnostic setting `ud07-activity-to-law` verificato: punta al workspace UD07
  `.../rg-ud07-monitor/.../law-ud07-3522` → confermata proprietà, eliminato
- `rg-ud07-cli-test`: tag `UD=07`, `ManagedBy=CLI`, nessuna risorsa → eliminato
- `rg-ud07-ps-test`: tag `UD=07`, `ManagedBy=PowerShell`, nessuna risorsa → eliminato
- `rg-ud07-monitor`: tag `UD=07`, contenuto solo risorse UD07
  (law-ud07-3522, stud0792490543, ag-ud07, alert-ud07-storage-transactions) → eliminato

- diagnostic setting subscription: **rimossa** (`ud07-activity-to-law`, nessun residuo)
- `rg-ud07-cli-test`: **eliminato** (`exists: false`)
- `rg-ud07-ps-test`: **eliminato** (`exists: false`)
- `rg-ud07-auto`: **assente** (già rimosso nel LAB autonomo)
- `rg-ud07-auto-ps`: **assente** (già rimosso nel LAB autonomo)
- `rg-ud07-monitor`: **eliminato** (`exists: false`)
- controllo finale Resource Group UD07: `az group list [?contains(name,'ud07')]` → **nessun residuo**; nessuna diagnostic setting residua a livello subscription

