# Consegna UD05 — Domande sui concetti

Per ciascuna domanda 1–8 riporta una risposta motivata.

1. Perché peering e VPN instradano traffico tra le due reti come se fossero una rete unica: se gli spazi di indirizzamento si sovrappongono, un indirizzo esisterebbe in entrambe le reti e il piano di instradamento non potrebbe decidere a quale rete inviare i pacchetti, generando conflitti e malfunzionamenti. Microsoft richiama esplicitamente unicità dei prefissi nella guida di pianificazione VNet.

2. È più grande `/24`: lascia 8 bit per gli indirizzi del blocco e contiene 256 indirizzi complessivi, mentre `/26` ne contiene 64. Un prefisso più alto indica una rete più piccola, perché fissa più bit e lascia meno bit liberi per gli indirizzi.

3. Perché un public IP rende possibile un endpoint pubblico solo quando è associato a una risorsa che ascolta e quando NSG, route e sistema operativo consentono il flusso. “Ha un IP pubblico” non equivale a “è raggiungibile”: senza regole aperte, route corrette e un processo in ascolto sulla porta, il traffico viene comunque bloccato.

4. Le regole hanno priorità da 100 a 4096 e il numero più basso viene valutato per primo; alla prima corrispondenza l'elaborazione termina. Le regole predefinite, con numeri più alti, sono valutate per ultime e possono essere superate da regole personalizzate.

5. Significa che, se un flusso è consentito in una direzione, il traffico di risposta dello stesso flusso non richiede una regola speculare nella direzione opposta. Questo non autorizza una nuova connessione indipendente nella direzione opposta: resta necessaria una regola che la consenta.

6.  Perché quando NSG esistono sia sulla subnet sia sulla NIC, il traffico deve essere consentito da entrambi; una regola `Allow` in uno non annulla un `Deny` nell'altro. Il pacchetto deve superare tutti i filtri applicabili, non uno solo.

7. Il DNS traduce nomi in indirizzi IP, ma non autorizza il traffico né sostituisce route o NSG. Il routing (route di sistema o user-defined) determina il percorso che i pacchetti seguono verso la destinazione, associando un prefisso a un next hop. L'NSG filtra il traffico in base a origine, destinazione, porta e protocollo, consentendo o negando i flussi. Sono tre funzioni distinte: nome→indirizzo, percorso, controllo di accesso.

8. Perché molti strumenti di Network Watcher, inclusi IP Flow Verify, richiedono una VM o un endpoint supportato. In questa UD controlliamo solo associazioni NSG, regole e route table; i report che richiedono una VM collegata e in esecuzione, come Effective security rules e Effective routes, e il test di flusso verranno affrontati in UD06 insieme alla VM.
