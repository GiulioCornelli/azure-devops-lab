# UD17 — Domande sui concetti

Per ciascuna delle dieci domande conclusive di `00_CONCETTI.md`, riporta la risposta con parole tue e un esempio quando serve. Non inserire una lista di comandi al posto del ragionamento.

1. Perché un Pod Running può non essere Ready?

   Running dice che il Pod è in una fase in cui i container sono stati avviati; Ready dice che l'istanza può ricevere traffico dai Service. Il Catalogo può avere il processo attivo ma essere ancora impegnato a caricare configurazione e dati, oppure avere una readiness probe che fallisce. In quel caso il Pod resta Running, viene tolto dagli endpoint del Service, ma non viene riavviato.

2. Che cosa distingue startup, readiness e liveness?

   Sono tre controlli del kubelet con scopi diversi. La startup verifica che l'avvio iniziale sia finito e, finché non riesce, ritarda le altre due. La readiness decide se il Pod riceve traffico adesso: se fallisce, esce dagli endpoint ma non viene riavviato. La liveness decide se il container è compromesso: ripetuti fallimenti portano a un restart. Una liveness troppo severa può quindi peggiorare un rallentamento temporaneo.

3. Che differenza c'è fra 20m di CPU richiesti e 200m come limite?

   La request (20m, cioè 0,02 core) è il fabbisogno dichiarato e serve allo Scheduler per scegliere il nodo. Il limit (200m) è il massimo che il container può usare: oltre quella soglia la CPU viene rallentata (throttling). Per la memoria, superare il limit può causare la terminazione per OOM. Con request minori dei limit il Pod è `Burstable`.

4. Perché il target HPA CPU dipende dalla request?

   Con `averageUtilization` l'HPA calcola consumo osservato diviso CPU richiesta. Un uso di 10m con request 20m vale il 50%, con request 40m varrebbe il 25%. Il limit non entra nella formula. Per questo, senza request sulla CPU, l'HPA non può calcolare la percentuale e non scala; cambiare la request cambia anche il comportamento dello scaling.

5. Quale osservazione proverebbe che sono aumentate le repliche?

   Non basta vedere un HPA o il valore delle repliche desiderate. Servono più Pod effettivamente creati e Ready nel Deployment, con più endpoint nell'EndpointSlice del Service. La prova è confrontare tre istanti (prima, durante e dopo il carico), insieme alle metriche CPU e agli eventi dell'HPA. Se il carico non produce un aumento, si documenta la causa senza descrivere uno scaling che non è avvenuto.

6. Perché uno scaling backend con PVC richiede prudenza sui dati?

   Il contatore del Catalogo vive su un volume `ReadWriteOnce` condiviso sul nodo Minikube. Quel volume non è un database multiwriter e non garantisce coerenza se più repliche scrivono in parallelo. Per questo nell'esperimento si inviano solo richieste di lettura a `/api/products`. In produzione il dato condiviso andrebbe gestito in modo esplicito, mantenendo stateless la parte che scala.

7. Quali oggetti collegano una ServiceAccount al permesso di leggere i Pod?

   La ServiceAccount è il chi, la Role dice quali verbi (`get`, `list`) sono ammessi su quali risorse (i Pod) nel namespace, e la RoleBinding collega i due. Servono tutti e tre: la ServiceAccount da sola non ha permessi, e una Role senza binding non si applica a nessuno. Non serve una ClusterRole per leggere i Pod del solo namespace.

8. Come distinguere un rifiuto RBAC da un rifiuto PSA?

   Il rifiuto RBAC è un errore di autorizzazione (`Forbidden`) che dice che l'identità non può eseguire quel verbo su quella risorsa, ad esempio `create pods` o `get secrets`. Il rifiuto PSA arriva dall'admission quando il Pod viene creato: il messaggio indica la violazione della policy, ad esempio il livello `restricted`, e cita il campo non ammesso del securityContext. Il primo riguarda chi può chiedere, il secondo cosa può essere ammesso.

9. Perché un Secret non diventa pubblico solo perché il Pod lo usa?

   Un Secret è accessibile via API solo a chi ha i permessi RBAC per leggerlo. Il Pod lo riceve come variabile o file, ma una ServiceAccount con solo `get` e `list` sui Pod non può leggere i Secret e il test `can-i` risulta `no`, cosa corretta per il minimo privilegio. Il rischio resta che Base64 non è cifratura e che chi ha accesso al Pod o all'API possa vederlo.

10. Perché un Pod conforme alle policy può comunque non partire?

    Superare l'admission vuol dire solo che la specifica è accettata. Il Pod può restare `Pending` per mancanza di risorse sul nodo rispetto alle request, oppure fallire in `ImagePullBackOff` o con un errore di avvio. Con `runAsNonRoot` il processo deve anche poter leggere e scrivere dove serve, ad esempio in una directory temporanea scrivibile, altrimenti il container si ferma.
