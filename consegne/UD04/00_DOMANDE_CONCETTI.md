# Consegna UD04 — Domande sui concetti

Per ciascuna domanda 1–8 riporta una risposta motivata.


1. Non sono intercambiabili perché adottano modelli di accesso diversi: Blob organizza dati in oggetti dentro container ed è accessibile via REST/SDK, pensato per l'archiviazione e il recupero da applicazioni (log, immagini, documenti, backup). Azure Files espone condivisioni e directory via SMB/NFS, pensato per essere montato come unità di rete da VM e utenti. Un Blob non è un disco montato; la scelta parte dal modello di accesso, non dal solo contenuto del file.

2. Il management plan serve per gestire la rete e le proprieta' del blob storage tramite Azure Resource Manager, mentre il data plane serve per gestire il caricare, leggere ed eliminare file.

3. Perché ruolo e piano di controllo sono separati: Contributor agisce sul management plane, mentre l'accesso ai dati Blob via Microsoft Entra ID richiede ruoli specifici sul data plane.

4. Perché la geo-ridondaza serve a ridurre la latenza di accesso ad un dato tramite la ridondanza di esso su piu' regioni/continenti, mentre il backup serve a tenere una copia del file in caso di guasto.


5. I fattori da valutre prima discelglere la soluzione Archiv sono: la frequenza all'accesso del dato, la velocita' che serve per l'accesso a quel dato (visto che e' offline e richiede tempo e costi per essere di nuovo disponibile), la permanenza che ho bisogno e la gestione dei costi.

6. Una Account Key ha un impatto maggiore rispetto ad un SAS, perche' in base alla configurazione e al tipo di untete potra' acere piu' o meno permessi. Metre un SAS e' sempre una chiave temporanea(e' breve), ma e' un token che viene utilizzato nell'url e ha permessimi minimi.

7.  Il fatto che e' un token che risiede nell'URL, inoltre e' firmata da un account con credenziali mincrosoft Entra e quindi puo' gestire granuralmente i permessi che SAS dispone.

8.  La policy lifecycle effettua dei job come eliminazione del blob, passaggio ad un tear differente  e quidni l'elaborazione puo' partire anche dopo ore.

