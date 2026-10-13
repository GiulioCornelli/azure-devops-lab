# Consegna UD02 — Verifica

## Parte A — Scelte operative

Per le domande 1–8 riporta risposta e motivazione.

1. B
2. C
3. C
4. B
5. B
6. C
7. B
8. C

## Parte B — Risposte brevi

9. Un esempio nel cloud pubblico e' l'azienda che vuole hostare il proprio sito web sul Azure, mentre sul privato mantine i dati "segreti internamente" tipo repository privati per le code base. Metre ibrido e' un mix tra i deu dove appunto magari hosti il sito web su un cloud publico, metre i dati degli utenti li archivi nel tuo datacenter.


10. E' la suddivisione in di come azure gescice le cartelle e si parte dalla sottoscrizione.

11. Perche' in una region ci possono essere piu' availability zone


12. che con la cli si e' molto piu' orecisi e si mantine una history dei comandi utilizzati

13. cosi' che si possano effettuare query piu' dettagliate e aumentare i filtri.

## Parte C — Interpretazione tecnica

1. sottoscrizione: "/subscriptions/<omitted>/" ; RESOUCE GROUP: rg-cea-test ; TIPO: "Microsoft.Storage/storageAccounts" ;  NOME: stceatest01
2. LOCALITA: "italynorth" ; TAG: {"environment": "lab","unit": "UD02"},
3. `az resource list -g "$LAB_RG" --query "[].{Name:name,Type:type}"` e guardo se e' presente il nome della risorsa
4. `az group delete --name "$LAB_RG" --yes --no-wait`
5. `az group exists --name "$LAB_RG"`

