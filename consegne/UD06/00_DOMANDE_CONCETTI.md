# UD06 — Risposte alle domande sui concetti

## 1.
**Domanda:** Quali risorse e componenti principali costituiscono una VM Azure?
**Risposta:** Una VM Azure è composta da: Image (base del sistema operativo), Size (combinazione di vCPU, RAM e I/O), OS Disk (contiene il sistema operativo), eventuale Data Disk (volume aggiuntivo per dati/applicazioni) e una NIC, che a sua volta comprende Private IP, eventuale Public IP, Subnet e NSG.

## 2.
**Domanda:** Perché Public IP e raggiungibilità non sono sinonimi?
**Risposta:** Perché avere un Public IP non basta: serve anche un routing coerente, un NSG che consenta il traffico, un firewall OS coerente, un servizio in ascolto sulla VM e la porta corretta aperta. Un IP pubblico senza questi elementi non rende la VM raggiungibile.

## 3.
**Domanda:** Distingui Availability Zone, Availability Set e VM Scale Set.
**Risposta:** Availability Zone distribuisce le VM tra zone fisicamente separate ma nella stessa regione. Availability Set distribuisce più VM tra Fault Domain e Update Domain per proteggerle da guasti hardware e aggiornamenti pianificati. VM Scale Set gestisce un insieme di istanze VM identiche con gestione coordinata, crescita/riduzione del numero di istanze e supporto all'autoscaling.

## 4.
**Domanda:** Qual è la differenza tra scale up e scale out?
**Risposta:** Scale up significa passare a un'istanza più potente (es. da 2 a 4 vCPU), mentre scale out significa aumentare il numero di istanze (es. da 1 a 3 VM). Regola: UP → più potente, OUT → più numerose.

## 5.
**Domanda:** Come può Azure Monitor Autoscale modificare un VM Scale Set?
**Risposta:** Azure Monitor Autoscale modifica il numero di istanze di un VM Scale Set sulla base di metriche, soglie, intervalli temporali ed eventuali schedule. Ad esempio: se la CPU media supera il 70% per 5 minuti, vengono aggiunte istanze, rispettando un profilo con minimo, default e massimo (importante anche per i costi).

## 6.
**Domanda:** Qual è la differenza tra App Service Plan e Web App?
**Risposta:** L'App Service Plan definisce la piattaforma sottostante: regione, sistema operativo, tier, capacità e funzionalità disponibili. La Web App rappresenta l'applicazione ospitata su quel piano. Più Web App possono condividere lo stesso App Service Plan.

## 7.
**Domanda:** Qual è la differenza tra Azure Monitor Autoscale e App Service Automatic Scaling?
**Risposta:** Azure Monitor Autoscale è una configurazione basata su metriche, regole e schedule definiti dall'utente. L'Automatic Scaling (auto-scaling traffic-based) è una modalità gestita dalla piattaforma basata sul traffico, con concetti come Always ready, Maximum burst, Maximum scale limit e Prewarmed instances, e la disponibilità dipende dal tier.

## 8.
**Domanda:** Distingui Metrics e Logs/Log Analytics.
**Risposta:** Metrics sono dati numerici nel tempo (es. Percentage CPU, Requests, Response Time), visualizzabili con Metrics Explorer. Logs sono record interrogabili raccolti in un Log Analytics workspace e interrogabili con KQL (Kusto Query Language).

## 9.
**Domanda:** Qual è il ruolo di Recovery Services vault, backup policy e recovery point?
**Risposta:** Il Recovery Services vault è la risorsa che gestisce la protezione e i recovery point. La backup policy definisce frequenza, schedule e retention delle copie. Il recovery point è lo stato recuperabile prodotto dal backup, da cui è possibile ripristinare la VM.

## 10.
**Domanda:** Distingui High Availability, Backup e Disaster Recovery.
**Risposta:** High Availability riduce o interrompe il downtime permettendo al servizio di continuare a funzionare. Backup consente di recuperare dati o stati precedentemente salvati. Disaster Recovery ripristina il servizio dopo un evento significativo, ad esempio replicando le VM in un'altra regione con Azure Site Recovery (replica, failover, failback).

## 11.
**Domanda:** Che cosa indicano RPO e RTO?
**Risposta:** RPO (Recovery Point Objective) indica quanta perdita di dati è accettabile (es. RPO = 1 ora significa che al massimo si perdono 1 ora di dati). RTO (Recovery Time Objective) indica quanto tempo può impiegare il servizio a tornare operativo dopo un guasto (es. RTO = 30 minuti).

## 12.
**Domanda:** Perché una VM `deallocated` può continuare a generare costi?
**Risposta:** Perché `az vm deallocate` rilascia solo la compute allocation, ma restano attivi e a pagamento altri componenti collegati: dischi (OS e Data), backup, indirizzi IP (in base a configurazione e SKU) e altri servizi collegati alla VM.
