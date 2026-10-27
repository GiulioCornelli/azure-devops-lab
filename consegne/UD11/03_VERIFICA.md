# UD11 — Verifica

## Parte A — Scelta singola

1. **B.** repository

2. **B.** leggerlo con `az acr show --query loginServer`

3. **A.** il nome della risorsa ACR

4. **B.** uno snapshot immutabile di una versione/configurazione della app

5. **A.** una istanza in esecuzione di una revision

6. **A.** managed identity

7. **B.** pull delle immagini dal registry nel modello RBAC appropriato

8. **B.** la app può scalare a zero repliche quando non necessarie

## Parte B — Risposte brevi

9. **Distingui tag e digest.**  
   Il **tag** è un'etichetta leggibile (es. `v1`) che può essere riutilizzata e non garantisce immutabilità. Il **digest** (`sha256:...`) identifica invece il contenuto in modo univoco e content-addressed, garantendo l'identificazione esatta dell'immagine.

10. **Distingui Container Apps Environment, Container App, revision e replica.**  
   - **Container Apps Environment**: boundary infrastrutturale condiviso che ospita una o più Container App.  
   - **Container App**: definisce l'app da eseguire (immagine, ingress, scaling, identità, variabili).  
   - **Revision**: snapshot immutabile della configurazione della Container App (cambia con immagine/variabili/CPU/memoria).  
   - **Replica**: istanza runtime in esecuzione di una determinata revision.

11. **Perché il corso usa managed identity invece di ACR admin credentials?**  
   Per evitare credenziali statiche. Con **Managed Identity** + RBAC si concede solo il permesso minimo necessario (`AcrPull`) senza dover gestire username/password nel codice o nelle configurazioni.

12. **Perché una nuova image normalmente produce una nuova revision?**  
   Perché l'immagine è una proprietà revision-scope della Container App. Modificandola, Azure crea un nuovo snapshot immutabile della configurazione, dando origine a una nuova revision tracciabile.

13. **Che cosa deve coincidere tra backend e ingress target port?**  
   Il **targetPort** dell'ingress deve coincidere esattamente con la porta sulla quale l'applicazione backend è in ascolto (nel nostro caso `8000`). Se diverso, il traffico viene inoltrato a una porta vuota.

14. **Elenca almeno cinque controlli per una Container App non raggiungibile.**  
   1. **Ingress**: verificare che sia `external: true` e che il FQDN sia corretto.  
   2. **Target port**: controllare che corrisponda alla porta di ascolto dell'app.  
   3. **Revision/replica**: verificare che ci sia una revision attiva, healthy e con repliche avviate.  
   4. **ACR/auth**: verificare che l'immagine esista in ACR e che la managed identity abbia il ruolo `AcrPull`.  
   5. **Log applicativi**: consultare i log con `az containerapp logs show` per individuare errori di avvio.

15. **Perché il laboratorio UD11 esegue manualmente build, push e deployment invece di partire subito da una pipeline?**  
   Per **comprendere il processo prima di automatizzarlo**. Eseguendo manualmente ogni passaggio si vedono ruoli, dipendenze e responsabilità; nelle UD successive quelle operazioni verranno codificate e rese ripetibili.

16. **Se un registry è configurato in modalità RBAC+ABAC, perché non puoi dare per scontato che `AcrPull` sia il ruolo corretto?**  
   Perché in modalità **RBAC+ABAC Repository Permissions** i ruoli legacy `AcrPull/AcrPush` non vengono utilizzati per l'accesso ai repository. Vanno usati ruoli più recenti e granulari come `Container Registry Repository Reader/Writer`. Il ruolo corretto dipende dal modello di autorizzazione configurato sul registry.

17. **In che modo il lavoro manuale di UD11 prepara UD13 e UD14?**  
   Fornisce le basi operative: comprensione di ACR, managed identity, Container Apps, revision e ingress. Ciò permette di scrivere pipeline consapevolmente in UD13–UD14, sapendo quali comandi eseguire, con quale identità e cosa verificare.

18. **Distingui system-assigned e user-assigned managed identity.**  
   - **System-assigned**: creata e gestita da Azure per una singola risorsa; il suo ciclo di vita è legato alla risorsa (viene eliminata con essa).  
   - **User-assigned**: identità autonoma creata separatamente, riutilizzabile da più risorse e che sopravvive all'eliminazione delle risorse che la usano.

## Parte C — Scenario

19. **Qual è la causa più probabile e qual è la correzione minima?**  
   **Causa più probabile:** `targetPort` impostato a `9000` mentre il backend ascolta su `8000`.  
   **Correzione minima:** aggiornare l'ingress della Container App impostando `targetPort=8000` (creando così una nuova revision o aggiornando la configurazione).

20. **Quali verifiche eseguiresti dopo la correzione prima di dichiarare risolto il problema?**  
   1. Verificare che la **nuova revision** sia attiva e **Healthy** (`az containerapp revision list`).  
   2. Controllare che le **repliche** siano avviate.  
   3. Testare il **FQDN** (es. `curl` su endpoint/health) per confermare la risposta.  
   4. Consultare i **log** (`az containerapp logs show`) per assicurarsi che non ci siano errori.  
   5. Confermare che l'**ingress** punti al `targetPort` corretto (`8000`). 

## Cleanup finale

- resource list verificata: sì
- Resource Group eliminato: sì (rg-ud11-containers)
- `az group exists` = false: sì
- immagini Docker locali UD11 rimosse: catalog-backend:ud11-v1, catalog-backend:ud11-v2
- prune globale usato: NO