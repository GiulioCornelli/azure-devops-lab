# UD06 — Verifica

## Parte A

1.
**Domanda:** Quale componente collega normalmente una VM Azure alla subnet?
**Risposta:** A. NIC

2.
**Domanda:** Quale tecnologia gestisce un insieme di VM e può supportare autoscaling?
**Risposta:** B. VM Scale Set

3.
**Domanda:** Passare da 2 a 4 istanze è:
**Risposta:** B. scale out

4.
**Domanda:** Quale elemento definisce capacità e tier di una Web App?
**Risposta:** A. App Service Plan

5.
**Domanda:** Azure Monitor Autoscale può usare:
**Risposta:** B. metriche e regole

6.
**Domanda:** Quale affermazione è corretta?
**Risposta:** B. Metrics rappresentano valori numerici nel tempo; Logs sono record interrogabili

7.
**Domanda:** Quale risorsa è centrale nel workflow tradizionale di Azure Backup per VM?
**Risposta:** A. Recovery Services vault

8.
**Domanda:** Azure Site Recovery è principalmente associato a:
**Risposta:** B. Disaster Recovery

## Parte B

9.
**Domanda:** Distingui Availability Zone, Availability Set e VM Scale Set.
**Risposta:** Availability Zone distribuisce le VM tra zone fisicamente separate ma nella stessa regione. Availability Set distribuisce più VM tra Fault Domain e Update Domain per proteggerle da guasti hardware e aggiornamenti pianificati. VM Scale Set gestisce un insieme di istanze VM identiche con gestione coordinata, crescita/riduzione del numero di istanze e supporto all'autoscaling.

10.
**Domanda:** Distingui scale up e scale out.
**Risposta:** Scale up significa passare a un'istanza più potente (es. da 2 a 4 vCPU), mentre scale out significa aumentare il numero di istanze (es. da 1 a 3 VM). Regola: UP → più potente, OUT → più numerose.

11.
**Domanda:** Distingui App Service Autoscale e Automatic Scaling.
**Risposta:** Azure Monitor Autoscale è una configurazione basata su metriche, regole e schedule definiti dall'utente. L'Automatic Scaling è una modalità traffic-based gestita dalla piattaforma, con concetti come Always ready, Maximum burst, Maximum scale limit e Prewarmed instances; la disponibilità dipende dal tier.

12.
**Domanda:** Distingui High Availability, Backup e Disaster Recovery.
**Risposta:** High Availability riduce o interrompe il downtime permettendo al servizio di continuare a funzionare. Backup consente di recuperare dati o stati precedentemente salvati. Disaster Recovery ripristina il servizio dopo un evento significativo, ad esempio replicando le VM in un'altra regione con Azure Site Recovery (replica, failover, failback).

13.
**Domanda:** Spiega Recovery Services vault, backup policy e recovery point.
**Risposta:** Il Recovery Services vault è la risorsa che gestisce la protezione e i recovery point. La backup policy definisce frequenza, schedule e retention delle copie. Il recovery point è lo stato recuperabile prodotto dal backup, da cui è possibile ripristinare la VM.

14.
**Domanda:** Distingui RPO e RTO.
**Risposta:** RPO (Recovery Point Objective) indica quanta perdita di dati è accettabile (es. RPO = 1 ora significa che al massimo si perdono 1 ora di dati). RTO (Recovery Time Objective) indica quanto tempo può impiegare il servizio a tornare operativo dopo un guasto (es. RTO = 30 minuti).

## Parte C

15.
**Domanda:** Qual è la causa più probabile e perché?
**Risposta:** La causa più probabile è la regola NSG `Deny-HTTP` (priority 100), che nega il traffico TCP 80 dalla nostra IP pubblica. Nelle NSG le regole vengono valutate per priorità dal numero più basso: la regola Deny-HTTP ha priorità 100 e viene quindi processata prima di `Allow-HTTP` (priority 300), che non ha mai effetto. Il fatto che Nginx risponda a `curl localhost` dimostra che il servizio funziona sulla VM, ma il traffico esterno viene bloccato a livello di NSG prima di raggiungere la NIC.

16.
**Domanda:** Qual è la correzione minima e quali verifiche useresti per dimostrare il ripristino end-to-end?
**Risposta:** La correzione minima è eliminare (o disabilitare) la regola `Deny-HTTP`, oppure in alternativa crearla con una sorgente diversa dalla nostra IP, in modo che la regola `Allow-HTTP` possa essere applicata. Per verificare il ripristino end-to-end useresti: (1) IP Flow Verify di Network Watcher per confermare che il flusso TCP 80 dalla propria IP è ora `Allowed` e che la regola responsabile è `Allow-HTTP`; (2) una richiesta `curl http://<public-ip>` da una macchina esterna (o dalla shell locale) per confermare che Nginx risponde effettivamente; (3) un eventuale controllo con Connection Monitor o Test Integration per validare la raggiungibilità completa del percorso Internet → Public IP → NSG → NIC → VM → servizio.
