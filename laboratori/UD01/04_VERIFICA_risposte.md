# Risposte — Verifica "Preparazione dell'ambiente e metodo di lavoro"

Domande invariate in `04_VERIFICA.md`.

## Parte A — Scelte operative

**1.** **B** — Windows e la distribuzione Ubuntu hanno installazioni di Git distinte e indipendenti, quindi possono esporre versioni diverse. Conta solo che la versione in uso sia compatibile.

**2.** **C** — `wsl --list --verbose` mostra l'elenco delle distribuzioni con la colonna `VERSION` (1 oppure 2).

**3.** **C** — `~/workspace` è nel file system Linux, più adatto al successivo workflow con Docker e bind mount; evita i problemi di permessi e prestazioni tipici dei percorsi montati da Windows (`/mnt/c`).

**4.** **C** — Se Git è presente e compatibile si verifica il funzionamento (es. `git --version`) e si prosegue senza reinstallare.

**5.** **A** — Il commit esiste solo nella storia locale; finché non si esegue `git push` il repository remoto su GitHub non cambia.

**6.** **A** — `git status` dopo `git add`: mostra i file in staging, cioè quelli che entreranno nel prossimo commit.

**7.** **C** — Il codice è temporaneo e privato: si usa solo nella pagina di autenticazione e non va mai conservato nel repository né condiviso.

**8.** **B** — L'indicatore `WSL: Ubuntu` nella barra di stato e un terminale integrato con percorso Linux (es. `/home/...`) confermano che VS Code lavora dentro WSL.

**9.** **C** — La collaborazione serve per le attività di scrittura, revisione e collaborazione previste dal percorso. Un repository pubblico è già visibile a tutti, quindi A è falsa.

## Parte B — Risposte brevi

**10.** Git è il sistema di controllo di versione distribuito che gestisce storia e commit in locale. GitHub è un servizio di hosting cloud per repository Git, usato per condividerli, collaborare e fare backup. Git funziona anche senza GitHub; GitHub richiede Git.

**11.**
```bash
git status                 # osservo lo stato del working tree
git diff                   # osservo le modifiche non ancora in staging
git add nota-operativa.md  # preparo un singolo file
git commit -m "Messaggio descrittivo"
git push                   # invio il commit al remote
```

**12.** Due controlli prima di decidere:
1. verificare la versione attuale (`wsl --version` oppure `wsl --list --verbose`) per capire se l'aggiornamento è davvero necessario;
2. verificare che l'aggiornamento non comprometta l'ambiente già validato (compatibilità con gli strumenti del corso, disponibilità di un piano di ripristino) e coordinarsi con il gruppo.

**13.** Sospetto: VS Code è stato avviato da Windows (PowerShell) invece che dalla distribuzione Ubuntu, quindi il terminale integrato è quello di Windows (`C:\Users\...`). Verifica: nella barra di stato controllare l'indicatore `WSL: Ubuntu`, nel terminale eseguire `pwd` e `uname -r` e `which code`; soluzione: riaprire con `code .` dal terminale Ubuntu.

**14.** Perché Git conserva tutta la storia: il token resta visibile nel commit precedente e quindi esposto a chiunque cloni il repository. Cancellare la riga con un secondo commit non lo rimuove dalla storia. Occorre revocare/rigenerare subito il token e, se necessario, riscrivere la storia (`git filter-repo`/BFG).

## Parte C — Prova pratica

Sequenza attesa nel repository personale:

```bash
echo "Il comando più utile incontrato nell'unità è git status." >> laboratori/UD01/nota-operativa.md
git diff
git add laboratori/UD01/nota-operativa.md
git commit -m "Aggiunge riflessione sul comando più utile (UD01)"
git push
git log -1 --oneline
```

Effetto di ogni comando: `git diff` mostra i cambiamenti non ancora in staging; `git add` prepara solo il file indicato; `git commit` crea l'istantanea locale; `git push` la invia al remote; `git log -1 --oneline` mostra hash e messaggio dell'ultimo commit locale. Confrontandoli con la pagina GitHub, **hash abbreviato e messaggio devono coincidere**: se coincidono, il push ha pubblicato esattamente quel commit.
