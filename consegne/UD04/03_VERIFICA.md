# Consegna UD04 — Verifica

## Parte A — Scelta singola

Per le domande 1–8 riporta risposta e motivazione.

1. A
2. B
3. B
4. C
5. B
6. A
7. B
8. A

## Parte B — Risposte brevi

9. la ridondanza serve a matenere il servizio/dati sempre disponibili, i backup invece serve per conservare una copia del dato in caso di rotture delle macchine o di curruzioni del dato stesso.

10.  menagement plan `az storage account show -n nomeAccount -o jsonc` 

11.  solo lettura; solo blob o container; scadenza breve; trasporto via https

12. Perche' sono offline e ci mettono del tempo per essere recuperati

13. per evitare fuge di dati e mal intezionati che accedono ai tuoi dati



## Parte C — Caso situazionale

14. Probelmi: accesso allo storage account a tutti, SAS con privilegi non minimi e Scadenza non impostata su un periodo breve 

15.  assegnerei allo storage account il  Storage Blob Data Reader, restringerei lo scope solo al container a dove l'applicazione deve accedere e infine assegnerei il ruolo al pricipal dell'applicazione, cosi' da non condividere chiavi.

16. per gli accessi aggiungerei il flag `--auth-mode login`

