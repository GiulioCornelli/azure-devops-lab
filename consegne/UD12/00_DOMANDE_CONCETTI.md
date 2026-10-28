# UD12 — Domande sui concetti

Rispondere dopo avere studiato `00_CONCETTI.md`. Non limitarsi a definizioni di una riga: quando possibile aggiungere un piccolo esempio.

## 1.
**Risposta:**

**Che cosa si intende per Infrastructure as Code (IaC)?**

Infrastructure as Code (IaC) significa descrivere l'infrastruttura IT tramite file testuali trattati come codice, anziché crearla manualmente tramite interfacce grafiche o comandi eseguiti ad hoc. 

Tali file possono essere versionati con Git, revisionati tramite Pull Request, condivisi, riutilizzati e automatizzati in una pipeline. 

**Esempio:** invece di ricordare a memoria i passaggi per creare uno Storage Account dal Portale Azure, scriviamo un file `main.bicep` che descrive esattamente regione, SKU, TLS minimo e impostazioni desiderate, lasciando allo strumento il compito di crearle.

## 2.
**Risposta:**

**Quali vantaggi porta l'uso dell'IaC rispetto alla configurazione manuale?**

I principali vantaggi sono:
- **Ripetibilità:** posso creare lo stesso ambiente più volte ottenendo sempre lo stesso risultato.
- **Tracciabilità:** ogni modifica è tracciata nei commit Git.
- **Revisionabilità:** le modifiche possono essere sottoposte a revisione e approvazione (Pull Request).
- **Automatizzabilità:** può essere integrato in pipeline CI/CD.
- **Riduzione degli errori:** elimino il rischio di dimenticare impostazioni o di eseguire passi in ordine sbagliato.
- **Documentazione vivente:** il file IaC rappresenta la "verità" sull'infrastruttura desiderata.

**Esempio:** creare un ambiente di test identico a quello di produzione semplicemente rieseguendo lo stesso file IaC.

## 3.
**Risposta:**

**Qual è la differenza tra approccio imperativo e approccio dichiarativo?**

- **Approccio imperativo:** descrive *le azioni* da eseguire, passo dopo passo. Si specifica *"come"* fare qualcosa. È tipico di Azure CLI o PowerShell.
- **Approccio dichiarativo:** descrive *lo stato desiderato* dell'infrastruttura. Si specifica *"cosa"* si vuole ottenere, lasciando allo strumento decidere *"come"* raggiungerlo. È tipico di Bicep e Terraform.

**Esempio:**
- *Imperativo (Azure CLI):* `az group create`, poi `az storage account create` con una lista di parametri.
- *Dichiarativo (Bicep):* "Voglio uno Storage Account in West Europe con Standard_LRS, TLS 1.2, accesso pubblico ai blob disabilitato". Bicep/ARM si occupano delle operazioni necessarie.

## 4.
**Risposta:**

**Perché, nonostante l'uso di Bicep/Terraform, continuiamo ad usare Azure CLI, PowerShell o il Portale Azure?**

Perché sono strumenti complementari, non alternativi. Li utilizziamo per:
- **Verifica:** controllare lo stato delle risorse dopo un deployment (`az storage account show`, ecc.).
- **Troubleshooting:** diagnosticare problemi quando qualcosa non funziona come previsto.
- **Prerequisiti:** creare elementi non gestiti dal nostro file IaC (ad esempio permessi, configurazioni temporanee).
- **Interrogazioni rapide:** ottenere informazioni senza dover modificare i file IaC.

**Esempio:** dopo un `az deployment group create` con Bicep, posso usare `az resource list` per verificare rapidamente le risorse create nel Resource Group.

## 5.
**Risposta:**

**Perché nel corso si studia prima Bicep e poi Terraform?**

Perché la progressione è pensata per apprendere gradualmente:
- **Bicep:** è nativo per Azure, più semplice da apprendere per chi parte da zero con IaC e si integra direttamente con Azure Resource Manager (ARM).
- **Terraform:** ha un approccio più generale, funziona con molti cloud provider (multi-cloud) e introduce concetti importanti come *provider* e *state file*.

Studiare prima Bicep permette di capire bene il modello dichiarativo su Azure, poi passare a Terraform con maggiore consapevolezza delle differenze e delle analogie.

## 6.
**Risposta:**

**Che cos'è Azure Resource Manager (ARM)?**

Azure Resource Manager è il livello di gestione di Azure. È il servizio che riceve le richieste di creazione/modifica/eliminazione di risorse, le autentica, le autorizza e le distribuisce ai rispettivi *Resource Provider*.

Bicep non sostituisce ARM: viene "tradotto" in un template ARM JSON, che viene poi inviato ad ARM per l'esecuzione del deployment.

**Esempio:** quando eseguiamo `az deployment group create` con un file `.bicep`, Azure CLI chiama ARM passando la definizione tradotta in formato ARM.

## 7.
**Risposta:**

**Che cos'è Bicep? Qual è l'estensione dei suoi file e quale percorso useremo nel laboratorio?**

Bicep è un linguaggio dichiarativo, specifico per Azure, progettato per semplificare la scrittura dei template ARM. È più leggibile, meno verboso e più facile da manutenere rispetto al JSON ARM puro.

- **Estensione dei file:** `.bicep`
- **Percorso usato nel laboratorio:** `infra/bicep/main.bicep`

## 8.
**Risposta:**

**Nel file Bicep mostrato, a cosa serve il blocco `param`?**

Il blocco `param` serve a dichiarare dei valori che possono essere passati dall'esterno al template, rendendo il file più riutilizzabile. I parametri permettono di personalizzare il deployment senza modificare direttamente il codice Bicep.

**Esempio dal laboratorio:**
```bicep
@description('Regione Azure nella quale creare lo Storage Account.')
param location string = resourceGroup().location
```
Qui `location` ha un valore di default (la regione del Resource Group in cui stiamo effettuando il deployment), ma può anche essere passato esplicitamente se diverso.

## 9.
**Risposta:**

**Quale differenza c'è tra un parametro con valore di default e un parametro senza valore di default?**

- **Con valore di default:** se non viene specificato durante il deployment, viene usato automaticamente il valore predefinito.
- **Senza valore di default:** è obbligatorio fornire un valore al momento del deployment, altrimenti il comando fallirà.

**Esempio:**
- `param location string = resourceGroup().location` → opzionale (ha default)
- `param storageName string` → obbligatorio (nessun default), proprio perché il nome di uno Storage Account deve essere globalmente univoco e va scelto ad ogni deployment.

## 10.
**Risposta:**

**A cosa servono i decoratori `@description`, `@minLength`, `@maxLength`?**

I decoratori permettono di aggiungere metadati e validazioni ai parametri:
- `@description('...')`: aggiunge una descrizione leggibile, utile per chi usa il template.
- `@minLength(n)`: impone una lunghezza minima per stringhe/array.
- `@maxLength(n)`: impone una lunghezza massima per stringhe/array.

**Esempio dal laboratorio:**
```bicep
@description('Nome globalmente univoco dello Storage Account.')
@minLength(3)
@maxLength(24)
param storageName string
```
Questo aiuta a prevenire errori: Azure impone che il nome di uno Storage Account abbia lunghezza tra 3 e 24 caratteri.

## 11.
**Risposta:**

**A cosa serve il blocco `resource` in Bicep?**

Il blocco `resource` serve a dichiarare una risorsa Azure da creare (o gestire) con tipo, nome, posizione e proprietà desiderate. È il cuore del file dichiarativo: stiamo dicendo "voglio questa risorsa nello stato specificato".

**Esempio dal laboratorio:**
```bicep
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = { ... }
```
Dichiariamo uno Storage Account con un tipo API versione specifica.

## 12.
**Risposta:**

**Come si legge la sintassi `resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = { ... }`?**

- `resource` → keyword per dichiarare una risorsa
- `storage` → nome simbolico usato all'interno del file Bicep per fare riferimento a questa risorsa (es. `storage.name`)
- `'Microsoft.Storage/storageAccounts@2023-05-01'` → tipo della risorsa e versione dell'API da usare (`Provider/Risorsa@apiVersion`)
- `=` → indica che stiamo definendo lo stato desiderato
- `{ ... }` → corpo con le proprietà (nome, location, sku, kind, properties, tags)

## 13.
**Risposta:**

**Che cosa rappresentano `sku`, `kind`, `properties` in un Storage Account?**

- **`sku`**: definisce il livello di ridondanza e prestazioni. Nel laboratorio usiamo `Standard_LRS` (Local Redundant Storage).
- **`kind`**: definisce il tipo di Storage Account. `StorageV2` è il tipo moderno e consigliato per la maggior parte degli scenari.
- **`properties`**: contiene impostazioni di configurazione più dettagliate. Nel laboratorio impostiamo `allowBlobPublicAccess: false` (disabilita l'accesso pubblico ai blob) e `minimumTlsVersion: 'TLS1_2'` (forza l'uso di TLS 1.2 o superiore).

## 14.
**Risposta:**

**A cosa servono i `tags` in una risorsa Azure?**

I *tag* sono coppie chiave-valore utilizzate per organizzare, categorizzare e gestire le risorse. Sono utili per:
- **Organizzazione:** raggruppare risorse per progetto/corso
- **Cost Management:** filtrare i costi per ambiente/progetto
- **Automazione/Governance:** applicare policy basate sui tag
- **Tracciabilità:** identificare chi/come è stata gestita la risorsa

**Esempio dal laboratorio:**
```bicep
tags: {
  Course: 'AZ104'
  UD: '12'
  ManagedBy: 'Bicep'
}
```

## 15.
**Risposta:**

**A cosa serve il blocco `output` in Bicep?**

Il blocco `output` serve a restituire valori al termine del deployment. Questi valori possono essere visualizzati dall'utente, utilizzati in altri deployment o da script/pipeline.

**Esempio dal laboratorio:**
```bicep
output storageAccountName string = storage.name
output blobEndpoint string = storage.properties.primaryEndpoints.blob
```
Dopo il deployment, verranno mostrati il nome dello Storage Account e l'endpoint per i blob.

## 16.
**Risposta:**

**Che cosa significa "dichiarativo" nel contesto di Bicep/Terraform rispetto ad Azure CLI?**

Significa che ci limitiamo a *descrivere lo stato finale desiderato* della nostra infrastruttura, senza elencare manualmente tutte le operazioni. Lo strumento confronta lo stato desiderato con lo stato attuale (nei limiti del proprio modello) e applica solo le modifiche necessarie per raggiungere lo stato desiderato.

Con Azure CLI invece scriviamo esplicitamente *cosa fare* (crea, aggiorna, elimina) in sequenza.

## 17.
**Risposta:**

**Cosa succede concettualmente quando eseguiamo un deployment Bicep?**

Il flusso è il seguente:
1. Scriviamo `main.bicep` (stato desiderato)
2. Azure CLI (o altri strumenti) prende il file `.bicep`
3. Bicep viene tradotto in un template ARM JSON
4. La richiesta viene inviata ad **Azure Resource Manager (ARM)**
5. ARM identifica i **Resource Provider** corretti e crea/aggiorna le risorse
6. Al termine vengono mostrati gli `output` definiti nel file

## 18.
**Risposta:**

**Perché è importante versionare i file IaC con Git?**

Perché l'infrastruttura diventa parte del codice dell'applicazione:
- **Storia completa:** posso vedere chi ha fatto cosa e quando
- **Rollback:** posso tornare a una versione precedente se qualcosa va storto
- **Collaborazione:** più persone possono lavorare sullo stesso codice tramite branch e Pull Request
- **Audit:** tracciabilità per conformità e governance
- **Riproducibilità:** posso ricreare esattamente l'infrastruttura da una specifica versione del repository

## 19.
**Risposta:**

**Qual è la differenza tra Bicep e Terraform in termini di ambito d'uso?**

- **Bicep:** focalizzato principalmente su Azure (linguaggio nativo per Azure). Ottimizzato per l'ecosistema Microsoft.
- **Terraform:** multi-cloud e anche on-premise. Supporta Azure, AWS, GCP, Kubernetes, VMware e centinaia di altri provider tramite il suo ecosistema di *provider*.

Entrambi sono dichiarativi, ma Terraform è più generalista.

## 20.
**Risposta:**

**Cosa sono i "Resource Provider" in Azure?**

I *Resource Provider* sono servizi Azure che mettono a disposizione tipi di risorse specifici. Ad esempio:
- `Microsoft.Storage` gestisce Storage Account, Blob, File, Queue, Table
- `Microsoft.Compute` gestisce VM, Scale Sets
- `Microsoft.Network` gestisce VNet, NSG, Public IP

Quando definiamo `Microsoft.Storage/storageAccounts@2023-05-01` in Bicep, stiamo indicando a ARM quale Resource Provider deve occuparsi di creare quella risorsa.

## 21.
**Risposta:**

**Perché nel laboratorio usiamo proprio uno Storage Account come esempio?**

Perché è una risorsa semplice ma adatta a illustrare tutti i concetti base di IaC:
- Richiede pochi parametri
- Mostra chiaramente `param`, `resource`, `properties`, `tags`, `output`
- È facile da creare/verificare/eliminare
- Permette di vedere subito il risultato senza complessità eccessiva

## 22.
**Risposta:**

**Cosa significa che uno Storage Account deve avere un nome "globalmente univoco"?**

Significa che il nome scelto deve essere unico nell'intero namespace di Azure Storage, non solo all'interno del nostro Resource Group o della nostra sottoscrizione. Due persone diverse in tutto il mondo non possono avere uno Storage Account con lo stesso nome.

**Esempio:** `mystorageaccount12345` potrebbe essere già preso da qualcun altro; dovremo quindi scegliere un nome diverso (spesso si usano suffissi casuali o unici).

## 23.
**Risposta:**

**Perché nel file Bicep imponiamo `allowBlobPublicAccess: false` e `minimumTlsVersion: 'TLS1_2'`?**

Per motivi di sicurezza:
- **`allowBlobPublicAccess: false`**: impedisce l'esposizione pubblica dei blob. È una buona pratica per evitare accessi non autorizzati ai dati.
- **`minimumTlsVersion: 'TLS1_2'`**: obbliga l'uso di TLS 1.2 o superiore, disabilitando versioni più vecchie e meno sicure (come TLS 1.0/1.1) vulnerabili ad attacchi.

## 24.
**Risposta:**

**Qual è il ruolo di `resourceGroup().location` come valore di default?**

`resourceGroup().location` è una funzione intrinseca di Bicep che restituisce la regione in cui si trova il Resource Group di destinazione. Usandola come default, evitiamo di dover specificare sempre manualmente la location: il deployment creerà le risorse nella stessa regione del Resource Group, mantenendo coerenza e semplificando il comando.

## 25.
**Risposta:**

**In che modo Bicep migliora la leggibilità rispetto a un template ARM JSON?**

Bicep elimina gran parte del "boilerplate" JSON: meno parentesi graffe annidate, meno virgolette, sintassi più concisa e intuitiva, supporto nativo a parametri, moduli, cicli e condizioni. Inoltre ha un migliore supporto negli editor (IntelliSense).

**Esempio concettuale:** una stessa definizione di risorsa può occupare molte più righe in JSON ARM rispetto alla sua equivalente in Bicep, rendendola più difficile da leggere e manutenere.

## 26.
**Risposta:**

**Che cosa sono gli "output" e perché possono essere utili in una pipeline?**

Gli `output` restituiscono informazioni importanti generate durante il deployment (come nomi risorse, endpoint, chiavi in alcuni scenari). In una pipeline Azure DevOps/GitHub Actions possono essere catturati e passati ad altri step (ad esempio per configurare un'applicazione che deve puntare proprio a quell'endpoint appena creato).

## 27.
**Risposta:**

**Cosa significa "trattare l'infrastruttura come codice"?**

Significa applicare le stesse pratiche del codice applicativo all'infrastruttura: scrittura, revisione, test (laddove possibile), versionamento, branching, collaborazione e automazione. L'infrastruttura non è più "configurata una volta" manualmente, ma è definita, gestita e distribuita come parte del processo di sviluppo software.

## 28.
**Risposta:**

**Perché è meglio evitare di creare manualmente risorse che sono già definite nei file IaC?**

Perché si rischia di creare uno stato "drift" (deviazione) tra ciò che è definito nei file e ciò che esiste realmente in Azure. Questo può causare confusione, deployment non prevedibili e difficoltà nel mantenere l'ambiente coerente. L'ideale è che lo stato desiderato nei file IaC sia l'unica fonte di verità per quelle risorse.

## 29.
**Risposta:**

**Che differenza c'è tra "creare" e "gestire" risorse con un approccio dichiarativo?**

Con approccio dichiarativo, lo strumento cerca di portare l'ambiente allo *stato desiderato*. 
- Se la risorsa non esiste → la crea
- Se esiste ma differisce → la modifica per allinearla (quando possibile)
- Se è definita ma non più necessaria in alcuni scenari → dipende dallo strumento e dal tipo di deployment (in generale, eliminare risorse non più presenti va gestito con attenzione)

L'obiettivo è il *convergenza* allo stato dichiarato.

## 30.
**Risposta:**

**Quali sono i principali elementi sintattici visti finora in Bicep?**

I principali elementi sono:
- `param` – parametri di input
- `var` – variabili interne al template (non ancora molto approfondite, ma menzionate nel percorso)
- `resource` – dichiarazione di risorse
- `output` – valori in output
- Decoratori (`@description`, `@minLength`, `@maxLength`)
- Funzioni intrinseche (`resourceGroup().location`)

## 31.
**Risposta:**

**Che cosa rappresenta l'API version `'2023-05-01'` in un tipo di risorsa?**

Rappresenta la versione dell'API REST del Resource Provider da utilizzare per quella risorsa. Scegliere la versione corretta è importante perché:
- Determina quali proprietà sono disponibili
- Può cambiare il comportamento tra versioni
- Garantisce compatibilità con quanto stiamo configurando

È buona pratica consultare la documentazione Microsoft per usare una versione stabile e recente.

## 32.
**Risposta:**

**Perché è importante specificare correttamente `name`, `location`, `sku`, `kind` e `properties`?**

Perché ciascuno di questi campi influenza direttamente il tipo, la posizione, le prestazioni, la funzionalità e la sicurezza della risorsa creata. Un valore errato può portare a una configurazione non corretta o non conforme alle best practice. Nel nostro esempio, ad esempio, trascurare `minimumTlsVersion` o `allowBlobPublicAccess` significherebbe non applicare correttamente le impostazioni di sicurezza desiderate.

## 33.
**Risposta:**

**In che modo l'IaC supporta la collaborazione tra più persone?**

Grazie all'uso di file testuali versionati:
- **Branching:** ogni persona può lavorare su una propria copia modificando l'infrastruttura in modo isolato
- **Pull Request:** le modifiche vengono proposte, riviste e discusse prima di essere applicate
- **Code review:** si può verificare la correttezza, sicurezza e coerenza delle modifiche
- **Merge:** solo dopo approvazione le modifiche entrano nel branch principale
- **Tracciabilità:** resta la storia di chi ha approvato e applicato ogni modifica

## 34.
**Risposta:**

**Che cosa si intende per "file come unica fonte di verità" (single source of truth)?**

Significa che la definizione dell'infrastruttura presente nei file IaC deve essere considerata la rappresentazione corretta e autorizzata dello stato desiderato. Tutte le modifiche all'infrastruttura dovrebbero passare da quei file (e dal processo di revisione/approvazione), evitando modifiche dirette e non tracciate nel Portale Azure.

## 35.
**Risposta:**

**Quali sono le principali differenze tra lavorare con il Portale Azure e lavorare con Bicep?**

- **Portale Azure:** interattivo, visuale, rapido per prove singole, ma poco tracciabile e difficile da ripetere identicamente.
- **Bicep:** testuale, dichiarativo, ripetibile, versionabile, automatizzabile e adatto a gestire ambienti multipli. Richiede maggiore comprensione iniziale, ma molto più scalabile.

**Esempio:** per un singolo test il Portale può essere più veloce; per 3 ambienti (dev/test/prod) con configurazioni identiche, Bicep è nettamente più efficiente e affidabile.

## 36.
**Risposta:**

**Perché è importante comprendere il concetto prima di scrivere/comprendere comandi Bicep/Terraform?**

Perché gli strumenti sono semplici da eseguire, ma comprendere *perché* li usiamo permette di:
- Scrivere file corretti e sicuri
- Capire gli errori invece di copiarli acriticamente
- Fare scelte consapevoli (es. parametri, proprietà, sicurezza)
- Distinguere tra ciò che è "obbligatorio" per IaC e ciò che è "best practice"
- Interfacciarsi correttamente con pipeline e governance

## 37.
**Risposta:**

**Cosa vuol dire che Bicep "compila" verso ARM?**

Vuol dire che il codice Bicep viene tradotto in un template JSON compatibile con Azure Resource Manager. Questo avviene automaticamente (ad esempio da Azure CLI). Non dobbiamo scrivere noi il JSON ARM: Bicep lo genera per noi, mantenendo la compatibilità con il motore di deployment di Azure.

## 38.
**Risposta:**

**Quali informazioni ci forniscono i decoratori oltre alla validazione?**

Oltre a validare i valori (es. lunghezza minima/massima), migliorano anche la documentazione e l'usabilità del template. Quando qualcuno utilizza il template (anche tramite interfaccia), le descrizioni `@description` aiutano a capire il significato di ciascun parametro. Inoltre, in alcuni contesti, questi metadati possono essere utilizzati per generare interfacce o documentazione automatica.

## 39.
**Risposta:**

**Perché usiamo un tipo API specifico (`@2023-05-01`) anziché ometterlo?**

Perché in Bicep è obbligatorio specificare il tipo di risorsa completo con la versione API. Ometterla non è possibile. Specificarla correttamente garantisce che stiamo utilizzando lo schema di proprietà corretto per quella versione del Resource Provider. Usare una versione troppo vecchia può limitare le funzionalità; usare una versione deprecata può causare problemi in futuro.

## 40.
**Risposta:**

**Cosa rappresenta il simbolo `storage` (nome simbolico) e a cosa ci serve?**

È un identificatore logico all'interno del file Bicep. Ci permette di fare riferimento alla risorsa appena dichiarata per accedere alle sue proprietà. Ad esempio, in `output storageAccountName string = storage.name` stiamo recuperando il nome effettivo della risorsa creata da questo blocco. È simile a una variabile che punta all'istanza della risorsa.

## 41.
**Risposta:**

**Qual è la differenza tra `param` e `output`?**

- **`param` (input):** valori passati *al* template dal chiamante (utente/CLI/pipeline). Servono a personalizzare il deployment.
- **`output` (output):** valori restituiti *dal* template al chiamante al termine del deployment. Servono a comunicare informazioni utili (nomi, endpoint, ecc.).

## 42.
**Risposta:**

**Perché è importante prestare attenzione alle impostazioni di sicurezza nel file IaC (come TLS e accesso pubblico)?**

Perché le impostazioni definite nei file IaC vengono applicate automaticamente ad ogni deployment. Se le definiamo correttamente fin dall'inizio, applichiamo coerentemente le *best practice* di sicurezza su tutti gli ambienti. Al contrario, se lasciamo impostazioni meno sicure per "comodità", rischiamo di replicarle involontariamente anche in produzione.

## 43.
**Risposta:**

**In che modo l'IaC facilita il disaster recovery o la ricreazione di un ambiente?**

Se disponiamo dei file IaC versionati e della documentazione minima (gruppo di risorse/sottoscrizione), possiamo ricreare l'intera infrastruttura da zero in un'altra regione o sottoscrizione semplicemente rieseguendo i deployment. Questo riduce drasticamente i tempi di recovery rispetto alla ricostruzione manuale e garantisce maggiore coerenza.

## 44.
**Risposta:**

**Cosa significa "deployment" nel contesto Bicep/ARM?**

Un *deployment* è l'operazione di applicazione del template (file Bicep/ARM) ad una *scope* specifica (tipicamente un Resource Group, ma può essere anche sottoscrizione, gruppo di gestione o tenant). Durante il deployment, ARM crea, aggiorna o configura le risorse per portarle allo stato desiderato definito nel template.

## 45.
**Risposta:**

**Perché nel nostro esempio usiamo `resourceGroup().location` invece di scrivere direttamente `"westeurope"`?**

Per rendere il template più flessibile e riutilizzabile. Se qualcuno esegue il deployment in un Resource Group situato in un'altra regione, il template userà automaticamente quella regione senza modifiche al codice. Inoltre evita hardcoding e riduce la possibilità di errori.

## 46.
**Risposta:**

**Qual è il vantaggio di avere `storageName` come parametro obbligatorio?**

Poiché il nome dello Storage Account deve essere globalmente univoco, non possiamo usare un valore fisso nel template valido per tutti. Rendendolo parametro obbligatorio, forziamo chi effettua il deployment a scegliere un nome univoco al momento dell'esecuzione, evitando conflitti con nomi già esistenti in Azure.

## 47.
**Risposta:**

**Come possiamo verificare che ciò che Bicep ha creato corrisponda a quanto dichiarato nel file?**

Possiamo verificare in diversi modi:
- **Output del deployment:** controllare gli `output` mostrati al termine
- **Portale Azure:** visualizzare le proprietà della risorsa creata
- **Azure CLI:** ad esempio `az storage account show --name <nome> --resource-group <rg>` per ispezionare configurazione, TLS, accesso pubblico, ecc.
- **Confronto:** verificare che i valori corrispondano esattamente a quanto scritto in `properties`, `sku`, `kind`, `tags`

## 48.
**Risposta:**

**Perché si parla di "modello dichiarativo" e non "modello prescrittivo"?**

"Prescrittivo" suggerirebbe di prescrivere rigidamente ogni singolo comando. "Dichiarativo" invece indica che dichiariamo *il risultato desiderato*, lasciando al motore di orchestrazione la libertà di scegliere il modo più appropriato per realizzarlo. Il "come" è delegato ad ARM/Bicep/Terraform, il "cosa" è nostro.

## 49.
**Risposta:**

**Quali sono i rischi di gestire l'infrastruttura interamente via Portale in ambienti di team?**

I principali rischi sono:
- **Mancanza di tracciabilità:** non sappiamo chi ha modificato cosa e quando
- **Inconsistenza:** ambienti diversi possono finire con configurazioni differenti
- **Errori umani:** facilità di dimenticare impostazioni o di sbagliare configurazioni
- **Difficoltà di replicazione:** impossibile ricreare rapidamente ambienti identici
- **Scarsa governance:** difficile applicare controlli e approvazioni
- **Conoscenza dispersa:** la configurazione vive solo nella memoria di chi l'ha fatta

## 50.
**Risposta:**

**In che modo l'IaC si integra con il concetto di "DevOps"?**

L'IaC è uno dei pilastri fondamentali del DevOps applicato all'infrastruttura (*Infrastructure as Code* / *GitOps* mindset). Permette di:
- Applicare gli stessi workflow del codice (Git, branch, review, merge)
- Automatizzare il provisioning tramite pipeline CI/CD
- Garantire ambienti consistenti tra dev/test/stage/prod
- Migliorare collaborazione tra Development e Operations
- Passare da approcci manuali e lenti ad approcci automatizzati e ripetibili

## 51.
**Risposta:**

**Perché è importante leggere e comprendere un file `.bicep` anche se non lo scriviamo da zero subito?**

Perché nel corso dobbiamo essere in grado di spiegare *cosa* stiamo facendo, *perché* e *cosa accadrà*. Comprendere il file ci permette di:
- Individuare parametri, risorse, proprietà
- Capire impatti di eventuali modifiche
- Effettuare troubleshooting
- Verificare la correttezza prima del deployment
- Interagire consapevolmente con pipeline e revisioni

## 52.
**Risposta:**

**Cosa succede se proviamo a creare uno Storage Account con un nome già esistente globalmente?**

Il deployment fallirà. Azure rifiuterà la richiesta perché il nome deve essere univoco a livello globale nel namespace `blob.core.windows.net` (e relativi). È proprio per questo motivo che `storageName` è un parametro obbligatorio: dobbiamo scegliere un nome non ancora utilizzato da nessun altro utente Azure nel mondo.

## 53.
**Risposta:**

**Qual è la relazione tra `main.bicep`, Azure CLI e ARM?**

- **`main.bicep`**: definizione dichiarativa dell'infrastruttura desiderata
- **Azure CLI**: strumento che invia il file a Azure (e gestisce autenticazione/autorizzazione)
- **ARM (Azure Resource Manager)**: motore che riceve, valida e orchestra la creazione/aggiornamento delle risorse tramite i Resource Provider

In breve: `main.bicep` → (via Azure CLI/Bicep) → ARM → Resource Provider → Risorse Azure.

## 54.
**Risposta:**

**Perché Bicep è considerato un "Domain Specific Language" (DSL) per Azure?**

Perché è un linguaggio progettato specificamente per un dominio ben definito: la descrizione e il deployment di risorse Azure. A differenza di un linguaggio di programmazione generico, Bicep ha costrutti pensati proprio per ARM, conosce i tipi di risorsa Azure, supporta funzioni legate ad Azure e viene tradotto direttamente verso il modello di deployment di Azure.

## 55.
**Risposta:**

**Quali vantaggi offre l'uso dei `tags` anche in ambito IaC?**

Usandoli direttamente nel file IaC garantiamo che vengano applicati **sempre** allo stesso modo ad ogni deployment, senza dipendere dalla memoria o dalla correttezza di chi crea la risorsa manualmente. Inoltre permettono:
- Report dei costi coerenti
- Applicazione automatica di policy
- Identificazione rapida di risorse gestite da "Bicep" vs manuali
- Migliore organizzazione anche in sottoscrizioni con molte risorse

## 56.
**Risposta:**

**Cosa significa "idempotente" in relazione ad un deployment dichiarativo?**

Significa che eseguendo lo stesso template più volte nello stesso stato, il risultato finale sarà lo stesso e lo strumento non ripeterà modifiche inutili. Se le risorse sono già conformi allo stato desiderato, il deployment non apporterà cambiamenti (o apporterà solo verifiche). Questo rende gli esecuzioni sicure e prevedibili.

## 57.
**Risposta:**

**Perché preferiamo descrivere l'infrastruttura in file anziché documentarla solo in un file Word/PDF?**

Un documento descrittivo spiega *come* fare, ma non *esegue*. I file IaC, invece:
- Sono **eseguibili**: possono creare direttamente l'infrastruttura
- Sono **verificabili**: il loro contenuto corrisponde a ciò che verrà effettivamente creato
- Sono **versionabili** e **confrontabili** automaticamente
- Sono **adatti all'automazione** nelle pipeline
- Rappresentano lo stato reale desiderato, non solo una procedura

**Esempio:** una procedura PDF può essere interpretata diversamente da persone diverse; un file Bicep, se corretto, produce sempre lo stesso risultato.

## 58.
**Risposta:**

**Qual è l'importanza di studiare sia Bicep sia Terraform anziché concentrarsi solo su uno dei due?**

Perché sono i due approcci più diffusi per IaC su Azure:
- **Bicep:** mostra come funziona bene l'integrazione nativa con ARM/Azure
- **Terraform:** mostra un approccio cloud-agnostic con concetti universali (provider, state, plan/apply) molto richiesti nel mercato

Conoscere entrambi permette di capire i punti in comune, valutare i pro/contro e scegliere lo strumento più adatto al contesto lavorativo.

## 59.
**Risposta:**

**Nel file Bicep, perché alcuni valori sono hardcoded e altri sono parametri?**

È una questione di flessibilità:
- **Parametri:** valori che ragionevolmente possono cambiare tra deployment (regione, nome univoco dello Storage Account)
- **Hardcoded:** valori che rappresentano una scelta consapevole e uniforme per questo scenario/laboratorio (es. `sku.name: 'Standard_LRS'`, `kind: 'StorageV2'`, `allowBlobPublicAccess: false`, `minimumTlsVersion: 'TLS1_2'`, `tags`)

Se volessimo massima riusabilità potremmo parametrizzare anche `sku`, ma nel nostro caso sono impostazioni deliberate per il laboratorio.

## 60.
**Risposta:**

**Cosa rappresenta la frase "descrivo lo stato desiderato, non i comandi"?**

Significa che non diciamo "crea questo, poi configura quello". Diciamo invece "voglio che esista questo Storage Account con queste esatte proprietà". È compito dello strumento determinare quali azioni ARM deve intraprendere per trasformare lo stato attuale in quello desiderato. Questo è il cuore del paradigma dichiarativo.

## 61.
**Risposta:**

**Perché è fondamentale capire la differenza tra imperativo e dichiarativo per affrontare correttamente IaC?**

Perché cambia completamente il modo di pensare:
- **Con imperativo:** "pensa a sequenza di comandi"
- **Con dichiarativo:** "pensa a configurazione finale desiderata"

Se continuiamo a ragionare solo in modo imperativo, rischiamo di scrivere file poco idiomatici o di non sfruttare appieno i vantaggi di Bicep/Terraform (idempotenza, gestione dello stato desiderato, gestione automatizzata delle differenze). Comprendere questa differenza è la chiave per capire correttamente l'intero approccio IaC.

## 62.
**Risposta:**

**Quali sono gli elementi che rendono l'IaC adatta ad essere usata in una pipeline Azure DevOps?**

- **File testuali:** facilmente gestibili da Git e dagli agent di pipeline
- **Automatizzabile:** può essere eseguita con comandi CLI senza interazione umana
- **Ripetibile e idempotente:** sicura da eseguire più volte
- **Tracciabile:** ogni esecuzione può essere collegata ad un commit/branch
- **Parametrizzabile:** permette di usare valori diversi per dev/test/prod
- **Integrabile:** si integra con approval, service connection, variabili e ambienti di Azure DevOps

## 63.
**Risposta:**

**Riassumi con parole tue il percorso logico dell'UD12: dal problema alla soluzione con IaC.**

Il percorso è il seguente:
1. **Problema:** creare risorse manualmente è veloce una volta, ma diventa difficile, ripetitivo ed error-prone quando serve farlo più volte e in ambienti diversi.
2. **Soluzione concettuale:** adottare **Infrastructure as Code**, descrivendo l'infrastruttura in file testuali versionabili e automatizzabili.
3. **Cambio di paradigma:** passare da approccio **imperativo** (azioni) ad approccio **dichiarativo** (stato desiderato).
4. **Strumenti:** prima **Bicep** (nativo Azure, semplice, integrato con ARM) per capire il modello, poi **Terraform** (multi-cloud, con concetti di provider e state).
5. **Pratica:** analizzare un file Bicep reale (`main.bicep`) con `param`, `resource`, `tags`, `output` per creare uno Storage Account configurato secondo best practice di sicurezza.
6. **Obiettivo finale:** comprendere come rendere l'infrastruttura **ripetibile, tracciabile, revisionabile e automatizzabile**, integrabile nei processi DevOps.
