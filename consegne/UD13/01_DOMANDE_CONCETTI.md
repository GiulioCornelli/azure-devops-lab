# UD13 — Domande concetti (Continuous Integration)

## 1.
**Domanda:** Qual è lo scopo principale della Continuous Integration?
**Risposta:** Trasformare ogni modifica al repository in una sequenza di controlli ripetibili, con gli stessi passaggi e regole, così il risultato non dipende da chi esegue i comandi manualmente.

## 2.
**Domanda:** Perché eseguiamo i test prima della build Docker?
**Risposta:** Perché prima si verifica e poi si produce l'artefatto: se i test falliscono non ha senso costruire e pubblicare una nuova immagine. Un fallimento nei test blocca la pipeline.

## 3.
**Domanda:** Che cosa significa realmente una pipeline verde?
**Risposta:** Che i controlli automatizzati scelti sono stati superati. Non garantisce che il software sia privo di bug, sicuro o pronto per la produzione.

## 4.
**Domanda:** Perché `Build.BuildId` è più utile di `latest` come tag dell'immagine?
**Risposta:** Permette di risalire alla run che ha prodotto l'immagine e di identificare la versione costruita, testata e distribuita; `latest` è generico e non traccia la provenienza.

## 5.
**Domanda:** Qual è la differenza tra `sc-azure-ud13-15` e `sc-acr-ud14`?
**Risposta:** `sc-azure-ud13-15` è una service connection ARM per gestire risorse Azure; `sc-acr-ud14` è una Docker Registry service connection usata da `Docker@2` per autenticarsi all'ACR durante build e push.

## 6.
**Domanda:** Perché l'admin user dell'ACR rimane disabilitato?
**Risposta:** Perché l'autenticazione avviene con Workload Identity Federation tramite service connection, senza username/password salvati nel YAML.

## 7.
**Domanda:** Qual è l'effetto del trigger sul branch `main`?
**Risposta:** Un nuovo commit su `main` (es. dopo un merge) avvia automaticamente una nuova run della pipeline CI.

## 8.
**Domanda:** Perché due Job Microsoft-hosted distinti effettuano entrambi il checkout del repository?
**Risposta:** Perché ogni Job riceve una VM temporanea diversa e deve ricostruire il proprio contesto di lavoro dal repository; i file non passano da un Job all'altro.

## 9.
**Domanda:** Che cosa significa che un Job Microsoft-hosted riceve un ambiente temporaneo?
**Risposta:** Che la VM viene fornita per quel Job e poi eliminata: non si può contare sui file lasciati da esecuzioni o Job precedenti.

## 10.
**Domanda:** Qual è la differenza fra responsabilità dell'Agent e responsabilità della service connection?
**Risposta:** L'Agent esegue i task e fornisce l'ambiente (es. python, docker, git); la service connection fornisce l'identità con cui i task accedono al servizio esterno.

## 11.
**Domanda:** Perché verifichiamo `python3 --version` e `docker --version` nei Job?
**Risposta:** Per controllare che gli strumenti necessari esistano nell'ambiente dell'Agent e distinguere subito un problema dell'ambiente da un problema applicativo o di autorizzazione.

## 12.
**Domanda:** Quando utilizziamo il file YAML self-hosted di fallback?
**Risposta:** Quando il Microsoft-hosted non è utilizzabile (grant, billing, policy o disponibilità); il file alternativo usa il pool self-hosted già predisposto.

## 13.
**Domanda:** A cosa serve `workspace.clean: all` nel fallback self-hosted?
**Risposta:** Pulisce l'intero workspace prima del Job, riducendo il rischio che file rimasti da esecuzioni precedenti influenzino la nuova run.

## 14.
**Domanda:** Che cosa fa `Docker@2` con `buildAndPush`?
**Risposta:** Esegue in sequenza build dell'immagine, applicazione del tag e push verso ACR, autenticandosi tramite la Docker Registry service connection.

## 15.
**Domanda:** In quale ordine conviene leggere i log quando una pipeline fallisce?
**Risposta:** Stage → Job → Step → comando → messaggio di errore, per restringere progressivamente il campo di ricerca.

## 16.
**Domanda:** Perché un errore nei test non deve portarci immediatamente a controllare ACR?
**Risposta:** Perché il problema è nello stage di test e la pipeline non è ancora arrivata a build e push; ACR e service connection non sono ancora coinvolti.

## 17.
**Domanda:** Che cosa dimostra il test failure intenzionale del laboratorio autonomo?
**Risposta:** Che la pipeline non sa in assoluto se il software è corretto: esegue solo i controlli definiti. Test incompleti o sbagliati possono dare una pipeline verde ma insufficiente.

## 18.
**Domanda:** Perché non eliminiamo ACR e immagini al termine della preparazione CI?
**Risposta:** Perché l'output della CI (immagine pubblicata) è l'input della Continuous Delivery nella UD14.

## 19.
**Domanda:** In che modo l'immagine pubblicata dalla CI prepara il successivo deployment con Terraform?
**Risposta:** Terraform nella UD14 userà il riferimento all'immagine (nome e tag basato su `Build.BuildId`) presente in ACR per distribuire l'applicazione nell'ambiente di destinazione.
