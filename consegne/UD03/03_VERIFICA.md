# Consegna UD03 — Verifica

## Parte A — Scelta singola

Per le domande 1–8 riporta risposta e motivazione.

1. B — L'autenticazione è riuscita (accesso al portale), ma manca un'autorizzazione applicabile su quello scope.
2. D — La password non è parte della role assignment (principal, ruolo, scope).
3. C — Reader sul resource group: ruolo minimo sullo scope minimo per soli consumi.
4. B — I ruoli assegnati al padre sono ereditati dai figli per gerarchia RBAC.
5. B — Contributor gestisce risorse ma non crea/rimuove assegnazioni RBAC (lo fa Owner).
6. C — CanNotDelete impedisce l'eliminazione finché è applicato; non blocca le letture.
7. B — Il budget genera notifiche, non costituisce un tetto automatico sulla spesa.
8. B — La creazione di utenti cloud avviene in Microsoft Entra ID con ruolo appropriato (es. User Administrator).

## Parte B — Risposte brevi

9. Assegnare ruoli a un gruppo centralizza la gestione: si aggiunge/rimuove un membro senza toccare le role assignment, si applica least privilege in modo scalabile e si riducono errori e debito di permessi sulle identità individuali.
10. Ruolo Entra (es. User Administrator): governa la directory (creare utenti). Ruolo Azure (es. Reader): governa le risorse Azure su uno scope (leggere un RG).
11. L'accesso effettivo è Contributor ereditato dalla sottoscrizione: le assegnazioni si combinano e non sono riduttive; Reader aggiunto sul RG non rimuove i permessi più ampi già ereditati.
12. (1) `az account show` per verificare autenticazione/abbonamento; (2) verificare principal e role assignment sullo scope con `az role assignment list --include-inherited`; (3) controllare scope di origine e ruoli ereditati; (4) verificare lock/policy e proprietà di risorsa che possano bloccare l'azione.
13. `deleteAfter` è solo un tag informativo (nessun effetto automatico); un lock `CanNotDelete` blocca operazioni di eliminazione sulla risorsa; un budget invia notifiche soglia ma non limita né ferma la spesa.

## Parte C — Caso situazionale

14. Scelte errate: (a) ricevere Contributor sull'intera sottoscrizione per consultare una sola VNet (eccesso di privilegi); (b) tentare di assegnare Reader a un collega senza disporre dei permessi di scrittura sulle role assignment; (c) tentare cleanup che elimina lo scope senza aver prima rimosso il lock.
15. Ruolo Reader sul resource group `rg-network-prod` (o sulla sola VNet se serve limitare ulteriormente): principal il tecnico, scope il RG di rete, non la sottoscrizione.
16. Non riesce ad assegnare il ruolo perché Contributor non include `Microsoft.Authorization/roleAssignments/write` (serve Owner o RBAC Administrator). Non riesce a eliminare lo scope perché un lock `CanNotDelete` (o simile) impedisce l'eliminazione indipendentemente dai ruoli posseduti.
