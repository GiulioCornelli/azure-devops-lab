# Consegna UD03 — Domande sui concetti

Per ciascuna domanda 1–8 riporta una risposta motivata.

1. L'autenticazione risponde "chi sei?" (credenziali valide), l'autenticazione non dice "cosa puoi fare?". L'autorizzazione è una decisione separata che il piano di controllo Azure esamina su ogni richiesta: anche con token valido, senza una role assignment che copra lo scope e l'azione, la richiesta viene rifiutata con `AuthorizationFailed`.

2. Un ruolo Microsoft Entra definisce permessi sulla directory Entra stessa (creare utenti, gestire gruppi, assegnare licenze) ed è valutato dai servizi di Entra. Un ruolo Azure (come Reader, Contributor, Owner) definisce permessi sulle risorse Azure (resource group, VM, storage) ed è valutato dal Resource Manager tramite role assignment su scope di sottoscrizione, RG o risorsa. Hanno scoping e piano di controllo diversi.

3. Una role assignment è formata da: (1) principal (utente, gruppo o servizio), (2) ruolo (definizione delle azioni consentite), (3) scope (sottoscrizione, resource group o risorsa specifica su cui il ruolo vale).

4. Reader sul solo resource group concede esattamente il necessario (consultazione) e solo dove serve: least privilege. Contributor sulla sottoscrizione consentirebbe invece di creare, modificare ed eliminare risorse su ogni RG della sottoscrizione, ampliando enormemente l'impatto di un eventuale abuso o errore senza alcun bisogno didattico o operativo.

5. Un ruolo ereditato si applica perché il modello RBAC di Azure è gerarchico: le assegnazioni su un livello padre valgono su tutti i figli. Sul figlio non esiste una copia separata da cancellare: la rimozione va fatta sullo scope di origine (es. la sottoscrizione), altrimenti la lettura sul figlio continuerà comunque a mostrare il ruolo per ereditarietà.

6. No. `deleteAfter` è solo un tag: metadato informativo usabile da script, policy o processi di governance esterni per programmare il cleanup. Il Resource Manager non lo interpreta e non elimina nulla da solo; senza un'automation o una policy dedicata che lo legga, il gruppo resta.

7. Un lock `CanNotDelete` blocca operazioni di elimina anzi o spostamento della risorsa anche a chi ha Owner: è un controllo sulla risorsa stessa. Reader invece limita il principal: concede solo lettura e non protegge la risorsa da altri principal che hanno permessi di scrittura. Il lock protegge l'oggetto, il ruolo limita il soggetto.

8. Un budget genera notifiche soglia ed è solo uno strumento di osservazione/alerting: non applica limiti automatici né arresta le risorse quando la soglia è superata. La spesa può crescere liberamente finché non interviene un intervento umano o un policy/hard limit (es. spending limit della sottoscrizione, dove disponibile, o policy di governance).
