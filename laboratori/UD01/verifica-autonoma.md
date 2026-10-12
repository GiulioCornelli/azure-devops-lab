# Verifica autonoma — UD01

Questa nota documenta la verifica dell'ambiente eseguita in autonomia, senza modificare installazioni o configurazioni di sistema.

Il contesto di lavoro è un ambiente Linux nativo: la postazione è un PC personale con Debian GNU/Linux 13 (trixie) installato direttamente e il comando `wsl` non è disponibile. Il kernel rilevato con `uname -r` è `6.12.111+deb13-amd64`, privo di riferimenti a Microsoft. Non essendo presente WSL, la prova della versione 2 di WSL non è applicabile; la verifica equivalente è che il progetto risieda nel filesystem Linux e non in un percorso montato da Windows.

Il repository personale si trova in `~/Corsi/Corso-Azure/resources/azure-devops-lab`. I comandi `pwd` e `git rev-parse --show-toplevel` restituiscono lo stesso percorso radice, quindi la cartella corrente e la radice del repository coincidono. Il remote `origin` è `https://github.com/GiulioCornelli/azure-devops-lab.git`, senza token o parametri riservati.

I quattro stati di Git si distinguono così: il working tree è l'insieme dei file presenti su disco con le modifiche non ancora registrate; la staging area è l'insieme delle modifiche selezionate con `git add` e destinate al prossimo commit; il commit locale è l'istantanea salvata nella storia locale del repository; il repository remoto è la copia ospitata su GitHub, aggiornata solo tramite `git push`.

Il login ad Azure è stato eseguito con `az login --use-device-code` e `az account show` ha confermato la sottoscrizione attiva; la versione di Azure CLI è 2.74.0. Gli identificativi di sottoscrizione e tenant non sono riportati perché riservati.

Lo stato dell'invito al docente risulta inviato e in attesa di accettazione, verificato da **Settings → Collaborators** del repository personale.

Un possibile errore di contesto è lanciare i comandi dalla shell sbagliata o da una cartella sbagliata. Il comando che permette di riconoscerlo è `pwd`, che mostrerebbe un percorso diverso da un percorso interno alla home Linux del progetto.

## Autovalutazione

| Capacità                                        | Valutazione |
| ----------------------------------------------- | ----------- |
| Distinguo PowerShell dal terminale Linux        | Completato  |
| Verifico che Ubuntu utilizzi WSL 2              | Completato  |
| Riconosco la radice del repository Git          | Completato  |
| Verifico il remote prima del push               | Completato  |
| Distinguo file non tracciato e file in staging  | Completato  |
| Inserisco in staging soltanto il file richiesto | Completato  |
| Verifico lo stesso commit in locale e su GitHub | Completato  |
| Verifico lo stato dell'invito al docente        | Completato  |
| Riconosco ed escludo dati riservati             | Completato  |
