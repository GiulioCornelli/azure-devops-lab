# Consegna UD03 — Laboratorio guidato

## Contesto anonimizzato

- sottoscrizione e tenant verificati: sì (Azure subscription 1, account personale, stato Enabled)
- percorso Entra eseguito: A
- resource group temporaneo: `rg-cea-identity-8e24ce` (italynorth, tag course=cloud-engineer-academy unit=UD03 environment=lab)

## Identità e assegnazione RBAC

| Principal anonimizzato | Ruolo | Scope | Diretta/ereditata | Motivo |
|---|---|---|---|---|
| `grp-cea-readers-8e24ce` (Group) | Reader | resource group `rg-cea-identity-8e24ce` | Diretta | Assegnazione creata dal portale in Access control (IAM) per concedere consultazione dello scope al gruppo di sicurezza |
| account corrente (User) | Owner | sottoscrizione | Ereditata | Ruolo preesistente sull'intera sottoscrizione; non creato dal laboratorio |

Oggetti creati nel portale (percorso A):

- Utente cloud temporaneo `cea-lab-8e24ce` (alias non personale, password temporanea non registrata)
- Gruppo di sicurezza `grp-cea-readers-8e24ce`, membership Assigned, con l'utente di test come membro verificato in **Members**

Autorizzazione necessaria: creazione di utenti e gruppi di sicurezza richiede un ruolo amministrativo appropriato in Entra (es. User Administrator).

Evidenza CLI della role assignment (anonimizzata):

```json
[
  {
    "PrincipalType": "User",
    "Role": "Owner",
    "Scope": "/subscriptions/<omitted>"
  },
  {
    "PrincipalType": "Group",
    "Role": "Reader",
    "Scope": "/subscriptions/<omitted>/resourceGroups/rg-cea-identity-8e24ce"
  }
]
```

Accesso effettivo osservato (Check access):

- Assegnazione Reader creata: diretta sul resource group `rg-cea-identity-8e24ce`, applicata al gruppo `grp-cea-readers-8e24ce` (principalType Group).
- Ruolo ereditato: Owner dell'account corrente sulla sottoscrizione, che estende lo stesso accesso al resource group per ereditarietà.
- Tipo di principal: Group per l'assegnazione del laboratorio; User per il ruolo ereditato.
- Scope di origine: RG per Reader; sottoscrizione per Owner.
- Le assegnazioni consentite si combinano: l'Owner ereditato non viene ridotto dal Reader; l'effetto didattico del ruolo Reader su un'identità priva di altri ruoli si osserva sul gruppo, non sull'account corrente.

## Governance e costi

- tag e significato: non ancora configurati nel dettaglio oltre ai tag di default del resource group (course, unit, environment, deleteAfter)
- lock e operazione impedita: non ancora creato (sezione 7 del lab)
- stato di Cost Analysis: non ancora osservato (sezione 6 del lab)
- budget creato o limitazione documentata: non ancora creato (sezione 6 del lab)
- motivo per cui il budget non blocca la spesa: non applicabile finché non creato

## Cleanup

Non ancora eseguito: il resource group `rg-cea-identity-8e24ce` è ancora presente. Il cleanup finale (budget, role assignment, lock, utente/gruppo, eliminazione RG) è previsto nella sezione 9 del lab guidato dopo laboratorio autonomo e verifica.

## Rilevanza professionale

- Autenticazione: verifica chi sei (account Microsoft Entra, credenziali).
- Autorizzazione RBAC: verifica cosa puoi fare su uno scope Azure (role assignment su principal, ruolo, scope); le assegnazioni consentite si combinano e non sono riduttive.
- Blocco di governance (lock): impedisce operazioni di cancellazione/modifica anche a chi ha già i permessi RBAC, proteggendo risorse critiche da azioni accidentali.

