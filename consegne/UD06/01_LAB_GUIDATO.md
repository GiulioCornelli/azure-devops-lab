# UD06 — Consegna laboratorio guidato

## VM

- regione selezionata: italynorth
- size selezionata: Standard_F1als_v7
- image: Ubuntu Server 24.04 LTS (Canonical, ubuntu-24_04-lts / ubuntu-pro)
- size: Standard_F1als_v7
- private IP: 10.50.10.5
- public IP: 72.146.234.223
- NIC: vm-ud06-linux940
- subnet: snet-web (in vnet-ud06)
- OS disk: vm-ud06-linux_OsDisk_1_351e3d4d39184f87aaf2f524399efd1b

## Accesso e workload

- SSH: OK — `ssh -i ~/.ssh/ud06_azure azureuser@72.146.234.223`, hostname `vm-ud06-linux`
- Nginx: attivo (`systemctl is-active nginx` → active)
- test localhost: OK — `curl -I http://localhost` → HTTP/1.1 200 OK (nginx/1.24.0 Ubuntu)
- test esterno: OK — `curl -I http://72.146.234.223` → HTTP/1.1 200 OK (nginx welcome page)
- IP Flow Verify: flusso Inbound TCP 80 dal proprio IP → Allowed (dedotto dalle regole NSG; IP Flow Verify non eseguibile via CLI per errore del modulo monitor, da ripetere nel Portale)
- regola responsabile: nginix-inbound-vmud06 — priority 310, Inbound, Allow, TCP 80, sorgente 93.66.98.131/32 (regola SSH: Allow-SSH-MyIP, priority 300, TCP 22)

## Azure Monitor

- metrica VM: Percentage CPU
- intervallo: ultime 24 ore, aggregation Average, intervallo PT5M
- aggregazione: Average
- osservazione: CPU media ~1.6%, picco ~11.8% (durante l'installazione di Nginx), min ~0.3% — la VM Standard_B1/F1 è quasi sempre a riposo dopo l'installazione; Network In ~430 byte e Network Out ~49 byte (valori medi orari) confermanti solo traffico di amministrazione

## VMSS / Autoscale

Nessun VM Scale Set presente nel Resource Group: sezione compilata come configurazione concettuale-guidata dai comandi di esempio.

- min: 1
- default: 1
- max: 3
- metrica: Percentage CPU
- soglia: > 70 (media su 5 minuti)
- azione: scale out +1 istanza
- perché serve un max: per limitare il numero massimo di istanze e quindi contenere il costo e la capacità erogata; senza un massimo l'autoscaling potrebbe crescere senza controllo in caso di carico anomalo o di una regola mal configurata

## App Service

- App Service Plan: plan-ud06-6376 (piano Linux, F1 — lo script ha anche prodotto in precedenza plan-ud06-5649 con web app ud06-web-1792419258-18989, senza deployment)
- tier: Free (F1)
- Web App: ud06-web-1792419302-27203 (Running)
- hostname: ud06-web-1792419302-27203.azurewebsites.net
- test HTTPS: OK — HTTP/2 200 e contenuto verificato: `curl -fsS` restituisce "Deployment riuscito." (pagina personalizzata pubblicata, non la default di App Service)

## Scaling App Service

| Modalità | Basata su |
|---|---|
| Manual | numero di istanze impostato manualmente dall'utente |
| Azure Monitor Autoscale | metriche, regole e schedule definiti dall'utente |
| Automatic Scaling | traffico in ingresso, gestito dalla piattaforma (Always ready, Maximum burst, Prewarmed instances; disponibilità dipende dal tier) |

## Azure Monitor App Service

- metrica: Requests (media ~0.014, max 2) e HttpResponseTime (media ~0.013 s, max 0.022 s) sulle ultime 24 ore
- osservazione: poche richieste di test, tempi di risposta molto bassi (~13 ms); confronto con la VM: su App Service le metriche sono relative al servizio applicativo (requests, response time, cpu time), mentre sulla VM si misura la risorsa sottostante (CPU, rete, disco)

## Backup

- Recovery Services vault: nessuno presente nel Resource Group — Azure Backup non abilitato, come previsto dalla UD
- frequenza ipotizzata: 1 volta al giorno
- retention: 30 giorni
- recovery point: non creato (backup reale non avviato)
- backup reale avviato?: no — non previsto nella UD

## HA / Backup / DR

- Scenario A: High Availability
- Scenario B: Backup
- Scenario C: Disaster Recovery

## Cleanup

- Resource Group eliminato: no — non eseguito in questa sessione (sola lettura); prima dell'eliminazione verificare che tutte le risorse appartengano alla UD06. Presenti: vnet-ud06, vm-ud06-linux (+ NIC, IP, NSG, OS disk), nic-web-01, plan-ud06-5649, plan-ud06-6376, ud06-web-1792419258-18989, ud06-web-1792419302-27203
- `az group exists`: true (rg-ud06-compute ancora presente)
