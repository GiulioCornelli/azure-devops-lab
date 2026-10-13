# Consegna UD02 — Domande sui concetti

Per ciascuna domanda 1–8 riporta una risposta motivata.

1. Una macchina virtuale è un servizio IaaS: Azure fornisce solo l'hardware virtualizzato e la connettività, mentre tutto ciò che sta sopra resta al cliente. App Service è un servizio PaaS: Azure fornisce e amministra anche il sistema operativo, il runtime e la piattaforma di hosting. Più si sale di livello nel servizio, più responsabilità passano dal cliente al provider: è il principio della responsabilità condivisa.


2. Il tenet e' il contenitore iniziel dove risiede l'identita' e gli oggetti della directory ed e' gestito da Microsoft Entra. La sottoscrizione e' cio' che configura i metodi di pagamento, i login con accessi e permessi ad una o piu' risorse. Infine il resource group e' un contenitore logico che raggruppa piu' risorse.

3. Il resouce group non e' un contenitore fisico ma logico, e appunto a raggruppare risorse con lo stesso ciclo di vita e ownership. Inoltre la regione del gruppo serve solo per salvare i metadati delle singole risorse (come nome, tag) e non per i dati di funzionamento. Raggruppare piu' risorse di localita' diverse serve solo  a una questione di chi possiede le risorse

4. Una region è un'area geografica che contiene uno o più datacenter, collegati tra loro da una rete a bassa latenza e definiti da confini di residenza dei dati: è l'unità in cui si sceglie dove creare le risorse.
Mentre una availability zone è invece una separazione fisica all'interno di una singola region: un gruppo di datacenter con alimentazione, raffreddamento e rete indipendenti. Distribuire le risorse su più zone mette al riparo dal guasto di un singolo datacenter, quindi serve ad alta disponibilità e tolleranza ai guasti. Le zone di una region sono connesse da una rete privata ad alta velocità.

5. Si utilizza il  comando `az account show` per capire che che sottoscrizione e che utente si sta utilizzando per la creazione.


6. I tag sono solo metadati pemnsati per l'inventario, governace e analisi dei costi e azure non concede ne nega gli accessi in base ai tag. 


7. Azure CLI rende le procedure riproducibili. Un comando può essere conservato, confrontato, inserito in uno script e poi trasformato in una pipeline. Il portale è utile per scoprire servizi e leggere proprietà, ma non rende ripetibile una procedura: due persone possono scegliere opzioni diverse senza accorgersene. Per questo il corso verifica con la CLI ogni azione importante fatta nel portale, quando possibile .


8. Eseguire il comando dimostra solo di averlo lanciato, non quale effetto abbia avuto. Il cleanup è completo solo quando Azure conferma che il resource group non esiste più. Questa verifica evita che dischi, indirizzi pubblici, registry o ambienti applicativi restino attivi dopo una prova e continuino a generare costi (§11). Per questo la sequenza del corso termina con la verifica dell'eliminazione: inventario → creazione → verifica → evidenza → eliminazione → verifica dell'eliminazione. Vale lo stesso principio del: aver digitato un comando non prova il suo effetto, che va riletto.

