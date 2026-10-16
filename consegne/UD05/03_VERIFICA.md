# Consegna UD05 — Verifica

## Parte A — Scelta singola

Per le domande 1–8 riporta risposta e motivazione.

1. B 
2. B 
3. B 
4. A 
5. A 
6. A 
7. B 
8. B 

## Parte B — Risposte brevi

9. Ogni subnet riserva indirizzi Azure (gateway, DNS, reserved) e le risorse future vanno indirizzate nello stesso segmento. Ridimensionare una subnet attiva è impattivo perché può invalidare indirizzi già assegnati: dimensionarla solo per le risorse di oggi costringe a rimodellamenti frequenti e rischiosi.

10. Distingui NSG, route e DNS.
    - **DNS**: traduce nomi in indirizzi (risoluzione), non autorizza il traffico.
    - **Route**: determinano il percorso dei pacchetti (prefisso di destinazione → next hop), incluse quelle di sistema create da Azure e le user-defined.
    - **NSG**: filtra il traffico a livello 4 in base a origine, destinazione, porta e protocollo, con regole Allow/Deny a priorità crescente.

11. Se un flusso è consentito in una direzione, il traffico di risposta dello stesso flusso non richiede una regola speculare nella direzione opposta. Non autorizza però nuove connessioni indipendenti verso la direzione opposta: per quelle serve una regola dedicata.

12. Un solo NSG sulla subnet applica lo stesso filtro a tutte le NIC collegate, con un punto unico di regole e di diagnosi. Con NSG sia sulla subnet sia sulla NIC il traffico deve essere consentito da entrambi e le combinazioni `Allow`/`Deny` diventano difficili da diagnosticare.

13. Possibili: leggere IP privato, subnet di appartenenza, NSG associati (subnet e NIC), route table della subnet e regole configurate. Mancano i report effettivi (`Effective security rules`, `Effective routes`) e i test di flusso (IP Flow Verify, Connection Troubleshoot), che richiedono una VM collegata e in esecuzione: si deduce la configurazione, non si osserva il comportamento reale del data plane.

## Parte C — Caso situazionale

Una regola `Allow-Web` priorità 400 consente TCP 443 da `10.60.10.0/24`. Una regola `Deny-Web` priorità 150 nega TCP 443 dalla stessa origine. Il tecnico cambia il nome della prima in `AAA-Allow-Web`, ma il traffico resta negato.

14. Spiega perché il cambio di nome non modifica l'esito.
    L'NSG valuta le regole per priorità numerica, non per nome né per ordine di creazione. `Deny-Web` (150) viene sempre valutata prima di `AAA-Allow-Web` (400); alla prima corrispondenza — il Deny — l'elaborazione termina. Il nome è solo un identificativo e non entra nella selezione.

15. Proponi una correzione minima senza aprire Internet.
    Rimuovere `Deny-Web`, oppure assegnarle una priorità numerica più alta di 400 (es. 500) in modo che `Allow-Web` venga valutata per prima. In alternativa, se il Deny deve restare per altre origini, restringere la sua origine in modo che non copra `10.60.10.0/24`. In ogni caso resta limitato a TCP 443 da `10.60.10.0/24`: nessuna apertura verso `Internet`.

16. Elenca i controlli successivi se, dopo la correzione, l'applicazione resta irraggiungibile.
    Ordine di troubleshooting:
    1. Risoluzione DNS del nome dell'applicazione;
    2. Route verso la destinazione (route di sistema o user-defined, next hop corretto);
    3. NSG su subnet e NIC (tutti devono consentire; regole in ordine di priorità);
    4. Endpoint e porta (indirizzo e porta reali del servizio);
    5. Servizio in ascolto sulla VM (processo, binding su 0.0.0.0, firewall di sistema);
    6. Con VM in esecuzione: IP Flow Verify, Effective security rules, Effective routes e Connection Troubleshoot (Network Watcher).
