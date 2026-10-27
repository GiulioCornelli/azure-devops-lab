# UD11 — Risposte alle domande sui concetti

## 1. Distingui registry, repository, tag e digest.

**Risposta:**  
- **Registry**: il servizio (es. Azure Container Registry) che ospita le immagini.  
- **Repository**: raggruppa logicamente le versioni della stessa immagine (es. `catalog-backend`).  
- **Tag**: un'etichetta leggibile associata a un contenuto (es. `v1`, `v2`). Può essere riutilizzato e non garantisce immutabilità.  
- **Digest**: identificatore univoco e content-addressed (`sha256:...`) che identifica in modo immutabile il contenuto dell'immagine.

## 2. Perché non conviene basare una release solo sul tag `latest`?

**Risposta:**  
`latest` è solo un tag, non implica che sia l'ultima versione approvata o cronologicamente più recente. Può essere sovrascritto nel tempo, rendendo difficile tracciare quale versione è effettivamente in esecuzione e complicando il rollback/debug.

## 3. Perché il login server ACR va letto dalla risorsa invece di costruirlo manualmente?

**Risposta:**  
Il nome risorsa ACR e il suo login server possono differire e sono valori forniti da Azure. Leggendolo con `az acr show --query loginServer` si evita di costruirlo per ipotesi e si usa sempre il valore corretto della risorsa creata.

## 4. Qual è la differenza tra Container Apps Environment e Container App?

**Risposta:**  
- **Container Apps Environment**: boundary infrastrutturale condiviso, può ospitare più Container App. Non è l'applicazione stessa.  
- **Container App**: definisce l'applicazione da eseguire (immagine, ingress, scaling, identità, variabili, ecc.).

## 5. Distingui revision e replica.

**Risposta:**  
- **Revision**: snapshot immutabile della configurazione scope della Container App (cambia quando varia immagine, variabili, CPU/memoria, scale).  
- **Replica**: istanza runtime in esecuzione di una determinata revision. Una revision può avere 0, 1 o più repliche (a seconda di `minReplicas`/scaling).

## 6. A che cosa serve ingress?

**Risposta:**  
L'**ingress** permette di esporre la Container App all'esterno (in genere HTTPS). Instrada il traffico dal FQDN esterno alla porta interna (`targetPort`) dove il processo del container è in ascolto.

## 7. Perché target port deve coincidere con la porta di ascolto dell'applicazione?

**Risposta:**  
Se `targetPort` è diverso dalla porta reale su cui l'app ascolta, l'ingress inoltrerà il traffico a una porta vuota: la revision può apparire attiva, ma le richieste falliranno.

## 8. Perché usare managed identity per il pull da ACR?

**Risposta:**  
Usando una **Managed Identity** (sistema o utente) si evita di inserire credenziali statiche (username/password ACR). L'identità è gestita da Azure e può ricevere permessi RBAC minimi per il pull delle immagini.

## 9. A che cosa serve `AcrPull`?

**Risposta:**  
`AcrPull` concede il permesso minimo necessario alla Container App per **leggere/estrarre (pull)** l'immagine dal registry privato ACR. Non serve per pubblicarla (`push`).

## 10. Che cosa succede tipicamente quando aggiorni l'image di una Container App?

**Risposta:**  
Aggiornando l'immagine (tag diverso) si crea una **nuova revision**. In modalità single-revision, la nuova revision diventa attiva al posto della precedente; le repliche della nuova configurazione vengono avviate e il traffico viene instradato ad essa.

## 11. Perché in UD11 eseguiamo manualmente operazioni che verranno automatizzate in UD13–UD14?

**Risposta:**  
Per **comprendere prima il processo**: eseguendo manualmente build, push, configurazione, identity, ingress e aggiornamento riusciamo a capire ruoli, dipendenze e responsabilità. Solo dopo codificheremo e renderemo ripetibile ciò che abbiamo appreso.

## 12. Qual è la differenza fra RBAC Registry Permissions e RBAC+ABAC rispetto ai ruoli `AcrPull`/`AcrPush`?

**Risposta:**  
- **RBAC Registry Permissions**: utilizza i ruoli legacy come `AcrPull`, `AcrPush`, `AcrDelete` a livello di registry.  
- **RBAC+ABAC Repository Permissions**: impiega ruoli più granulari (es. `Container Registry Repository Reader/Writer`) e non si basa sui ruoli legacy `AcrPull/AcrPush` per l'accesso a repository specifici. Nel laboratorio usiamo intenzionalmente RBAC Registry Permissions con `AcrPull` per fini didattici.

## 13. Perché il self-hosted Agent di UD09 non è necessario per svolgere UD11, pur essendo collegato alla progressione del corso?

**Risposta:**  
In UD11 tutte le operazioni vengono eseguite manualmente nel terminale WSL2 del partecipante. L'Agent diventerà utile più avanti (UD13–UD14) quando tali operazioni verranno spostate nelle pipeline; l'ambiente Docker/WSL rimane comunque lo stesso.

## 14. Distingui system-assigned e user-assigned managed identity.

**Risposta:**  
- **System-assigned**: creata e gestita da Azure per quella specifica risorsa. Il ciclo di vita è legato alla risorsa (se la risorsa viene eliminata, anche l'identità viene rimossa).  
- **User-assigned**: risorsa identità autonoma, creata separatamente e riutilizzabile da più risorse. Può essere preparata indipendentemente e sopravvive all'eliminazione delle singole risorse che la utilizzano.

## 15. Che cosa significa scale-to-zero?

**Risposta:**  
Con `minReplicas = 0`, la Container App può scalare a zero repliche quando non c'è traffico. Non significa che l'ambiente o altre risorse (come ACR) vengano eliminate, solo che il compute delle repliche viene ridotto a zero.

## 16. Quali controlli eseguiresti se il FQDN restituisce errore dopo una nuova revision?

**Risposta:**  
Seguirei il percorso diagnostico: verificare **ingress external** attivo, **targetPort** corretto rispetto alla porta di ascolto dell'app, **revision attiva/healthy**, **numero di repliche**, **log applicativi**, presenza dell'**image/tag in ACR**, assegnazione corretta di **AcrPull** alla **managed identity**, e correttezza delle **variabili d'ambiente**.
