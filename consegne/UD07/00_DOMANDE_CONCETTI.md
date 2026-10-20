# UD07 — Risposte alle domande sui concetti

## 1.
Perché `--query` è preferibile a cercare manualmente una stringa nell'output JSON?
**Risposta:**
E' preferibile utilizzare query, perche' e' uno strumentro integrato e ti permette di filtrare direttamente sull'output che la cli ti restituisce, senza ad andare a modificare l'output dopo la ricezione.

## 2.
Qual è la differenza tra `table` e `tsv` in Azure CLI?
**Risposta:**
La differenza tra i due formati di outpunt e' che table restituisce una tabella ordinata con i capi richiesti ed e' perfetta per gli output visivi, dove l'opearatore puo' controllere le caratteristiche delle risorse. Mentre tsv viene utilizzata per estrapolare un singolo dato ed inserirlo in una variabile d'ambiente o in un codice in generale.
## 3.
Che cosa significa lavorare con oggetti in PowerShell?
**Risposta:**
I cmdlet restituiscono oggetti con proprietà, non testo: con $rg = Get-AzResourceGroup -Name "rg-demo" poi leggi $rg.ResourceGroupName, $rg.Location, $rg.Tags direttamente, e passi l'oggetto tra comandi via pipeline. Diverso da Bash/CLI, dove si lavora con testo/JSON e variabili testuali.

## 4.
Che cosa significa che una procedura amministrativa è idempotente?
**Risposta:**
Che puoi rieguirla più volte senza paura: rieseguire la procedura porta sempre allo stato desiderato senza produrre effetti indesiderati (es. verifica prima se il Resource Group esiste, e crealo solo se non esiste).

## 5.
Distingui Activity Log, Metrics e Logs.
**Risposta:**
- Activity Log, sono eventi dove viene segnalato ogni comando che viene eseguito, esplicitando chi ha fatto cosa e l'esito del comando.
- Metrics: sono tutta una serie di dati e parametri provenienti dalla CPU, GPU, transazioni, rete, che permettono di andare a vedere l'andamento di una o piu'  risorse
- Log, sono invece dei record ricchi di informazioni (dati grezzi) che seguono un teplate (timestamp, risorsa, categoria, status, identità) e possono essere interrogati, fitrati e intradati intradati in altri servizi per la visualizzazione
## 6.
A che cosa serve un Log Analytics workspace?
**Risposta:**
È l'ambiente in cui i log vengono raccolti e interrogati con query KQL. Serve come destinazione dei dati instradiati tramite una diagnostic setting: senza workspace, i log non hanno un luogo dove essere conservati e analizzati. Da solo però non raccoglie nulla: va collegato alle sorgenti.

## 7.
A che cosa serve una diagnostic setting?
**Risposta:**
Definisce quali categorie di log/metriche instradare e verso quale destinazione (Log Analytics, Storage Account, Event Hub). È la "regola di instradamento" tra sorgente e destinazione: senza di essa i dati restano solo nella sorgente e non raggiungono il workspace.

## 8.
Perché Activity Log e AzureActivity non sono esattamente la stessa cosa?
**Risposta:**
Perché Activity Log sono appunto una tipologie di eventi spiegati in nella domanda 5, Log Analytics Workspacementre  è invece il luogo dove i log finiscono e all'interno di esso si possono eseguire le query KQL
## 9.
Distingui Alert Rule e Action Group.
**Risposta:**
- Alert Rule definisce cosa osservare e quando: scope, segnale, condizione e frequenza di valutazione (es. "Transactions Total > 0 ogni 5 min").

- Action Group definisce che cosa fare quando la condizione è vera: email, SMS, webhook, Function... Ed è separato e riusabile da più regole.

## 10.
Perché un alert Fired non equivale automaticamente a un incidente?
**Risposta:**
Un alert Fired è solo un segnale: indica che una soglia è stata superata, non che c'è un impatto reale. La soglia può essere mal configurata o normale nel comportamento della risorsa; un incidente esiste solo se la situazione richiede gestione perché produce impatto effettivo.
## 11.
Qual è la differenza tra correlazione e causalità?
**Risposta:**
- Correlazione: due eventi sono avvenuti in sequenza o insieme (es. modifica 10:15, alert 10:25). È solo una constatazione temporale.

- Causalità: il primo evento ha causato il secondo. Serve evidenza in più: nesso tecnico tra modifica e metrica, log coerenti, comportamento che ritorna normale col rollback, riproducibilità.
## 12.
Quali sono i passaggi essenziali di un troubleshooting ripetibile?
**Risposta:**
1. Descrivere il sintomo
2. Chiarire il risultato atteso
3. Raccogliere evidenze
4. Formulare un'ipotesi
5. Verificare l'ipotesi
6. Applicare la modifica minima
7. Ripetere il test
8. Documentare




