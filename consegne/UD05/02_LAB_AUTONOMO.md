# Consegna UD05 — Laboratorio autonomo

## Inventario iniziale

Risorse lette via CLI (Nomi e RG anonimizzati; suffisso lab `***`):

| Elemento | Valore osservato |
|---|---|
| Resource group | `rg-cea-network-***` |
| VNet | `vnet-cea-***`, `10.50.0.0/16` |
| subnet web | `snet-web`, `10.50.10.0/24`, NSG associato: `nsg-data-***` |
| subnet data | `snet-data`, `10.50.20.0/24`, NSG associato: nessuno |
| NIC web | `nic-web-01`, IP privato `10.50.10.4`, in `snet-web`, nessun NSG alla NIC |
| NIC data | `nic-data-01`, IP privato `10.50.20.4`, in `snet-data`, nessun NSG alla NIC |
| Route table | assente su entrambe le subnet (route di sistema Azure) |
| Public IP / VM | nessuno |

Regole NSG custom su `nsg-data-***` prima del guasto:

| Priorità | Access | Direzione | Nome | Origine | Porta |
|---:|---|---|---|---|---|
| 300 | Allow | Inbound | Allow-Web-Postgres | `10.50.10.0/24` | TCP 5432 |

**Fatto rilevante:** l'NSG si chiama `nsg-data` ma è associato alla subnet **web**, non a `snet-data`; la NIC `nic-data-01` non ha NSG e la subnet data non ha NSG: il traffico verso la porta 5432 su `nic-data-01` non è toccato dalla regola Allow-Web-Postgres (che filtra l'ingresso della subnet web), ma solo dalle regole di sistema (`AllowVnetInBound`, `DenyAllInBound`).

## Guasto e diagnosi

- regola introdotta: `Deny-Web-Postgres-Auto` (Inbound, Deny, Tcp, source `10.50.10.0/24`, dest `*`, porta 5432, priorità 250)
- ordine di priorità osservato:

  | Priorità | Access | Nome |
  |---:|---|---|
  | 250 | Deny | Deny-Web-Postgres-Auto |
  | 300 | Allow | Allow-Web-Postgres |
  | 65000 | Allow | AllowVnetInBound (default) |
  | 65001 | Allow | AllowAzureLoadBalancerInBound (default) |
  | 65500 | Deny | DenyAllInBound (default) |

  Corrisponde per prima la regola a 250 (numero più basso valutato per primo): il flusso TCP 5432 da `10.50.10.0/24` viene negato prima di arrivare alla regola Allow a 300.
- sintomo: il livello web non riesce a collegarsi al database su TCP 5432
- ipotesi: conflitto di priorità tra due regole sulla stessa stessa origine/porta/direzione, oppure associazione NSG errata
- controllo: `az network nsg rule list` ordinato per priorità (250 Deny prima di 300 Allow); verifica associazione: NSG su `snet-web`, nessun NSG su `snet-data` né su `nic-data-01`; route table assente
- correzione minima: rimuovere la sola regola autonoma (restano le associazioni e le regole preesistenti invariate)
- verifica dopo la correzione: `Allow-Web-Postgres` (priorità 300) torna a essere l'unica regola custom e la prima corrispondente per il traffico TCP 5432 da `10.50.10.0/24`

Nota sullo scenario: il conflitto di priorità è stato indotto e risolto come esercizio. La vera incoerenza osservata nell'inventario è l'associazione dell'NSG: la regola Allow-Web-Postgres filtra l'ingresso della subnet **web**, non quello della subnet data dove risiede il database — quindi anche senza la regola Deny, la connessione web→data su 5432 non è governata da questa regola.

## Casi ulteriori

Diagnosi separate dei quattro sintomi, separando fatti osservati e prove non ancora eseguibili (nessuna VM in esecuzione: i report effettivi e i test di flusso sono rinviati alla UD06):

| Sintomo | Livello | Controllo | Correzione minima |
|---|---|---|---|
| `InvalidAddressPrefix` | Pianificazione / control plane (validazione ARM alla creazione o modifica della subnet/NSG) | Verificare il prefisso CIDR: non sovrapposto alla VNet, dentro lo spazio della VNet, notazione corretta (es. `10.50.10.0/24`, non `10.50.10.0/255.255.255.0`) | Correggere il valore del prefisso con un CIDR valido e contenuto nella VNet |
| `SecurityRuleConflict` | Definizione regole NSG (control plane) | Confrontare due regole sulla stessa collezione con sovrapposizione di direzione, accesso, protocollo, origine, destinazione e porta | Modificare origine/porta/protocollo per renderle distinte, oppure unificare in una sola regola |
| Un nome DNS non viene risolto | Name resolution (DNS) | `nslookup`/`dig` dal client; verificare DNS della VNet o DNS personalizzati; il DNS non autorizza il traffico | Correggere server/suffix DNS o record; non tocca NSG né route |
| La porta risulta filtrata da un NSG | Data plane / filtro L4 | Leggere regole in ordine di priorità su NSG di subnet e NIC (tutti devono consentire); `Effective security rules` sulla NIC (UD06, richiede VM) | Aggiungere o riposizionare una regola Allow con priorità più bassa del Deny corrispondente, o rimuovere il Deny |

Fatti osservati in questo lab: conflitto di priorità (Deny 250 vs Allow 300) e associazione NSG incoerente (NSG "data" su subnet web). Prove non ancora eseguibili: IP Flow Verify, Effective security rules/routes, Connection Troubleshoot — richiedono una VM collegata e in esecuzione (UD06). L'assenza di VM impedisce il test di flusso completo (nessun indirizzo sorgente/destinazione reale da simulare), ma non impedisce di individuare il conflitto: basta la lettura delle regole ordinate per priorità, che è un controllo di configurazione, non di data plane.

## Cleanup e risultato finale

- regola autonoma rimossa: sì (`az network nsg rule delete`); restano solo `Allow-Web-Postgres` a priorità 300
- cleanup verificato: elenco regole dopo la rimozione conferma una sola regola custom; il cleanup completo del laboratorio guidato (NIC, NSG, VNet, RG) è previsto nella sezione finale della consegna 01 e non eseguito qui
- hash abbreviato e messaggio del commit:

  ```text
  commit (proposto): UD05 — laboratorio autonomo: diagnosi regola incoerente
  ```

  (Il file è stato preparato e staged con `git add consegne/UD05/02_LAB_AUTONOMO.md`; il commit non è stato eseguito in questa sessione.)
