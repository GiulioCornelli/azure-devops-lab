# Consegna UD05 — Laboratorio guidato

## Piano di indirizzamento

| Elemento    | CIDR            | Scopo | Sovrapposizioni |
| ----------- | --------------- | ----- | --------------- |
| VNet        | `10.50.0.0/16`  | Spazio di indirizzamento complessivo della rete (primi due ottetti fissi: `10.50`) | Nessuna: `/16` contiene entrambe le subnet |
| subnet web  | `10.50.10.0/24` | Segmento per le risorse web (NIC `nic-web-01`, `10.50.10.4`) | Nessuna: `10.50.10.255` precede `10.50.20.0` |
| subnet data | `10.50.20.0/24` | Segmento per le risorse data (NIC `nic-data-01`, `10.50.20.4`) | Nessuna: interamente dentro `10.50.0.0/16`, non sovrappone a web |

Verifica dei confini: entrambe le subnet sono interamente contenute in `10.50.0.0/16` (primo indirizzo ≥ `10.50.0.0`, ultimo ≤ `10.50.255.255`) e non condividono alcun indirizzo IP.

## NSG e associazioni

| NSG | Scope associato | Regola | Priorità | Origine | Porta | Esito |
|---|---|---|---:|---|---|---|
| `nsg-data-ff1178` | subnet `snet-web` (`10.50.10.0/24`) | Allow-Web-Postgres | 300 | `10.50.10.0/24` | TCP 5432 (inbound) | Allow |

Regole predefinite presenti (non eliminabili, priorità più alte): AllowVnetInBound, AllowAzureLoadBalancerInBound, DenyAllInBound, AllowVnetOutBound, AllowInternetOutBound, DenyAllOutBound. La regola custom a priorità 300 viene quindi valutata prima di tutte.

## Verifica della configurazione

- NIC create e subnet: `nic-web-01` (`10.50.10.4`) in `snet-web`, `nic-data-01` (`10.50.20.4`) in `snet-data`
- NSG associato alla subnet e regole osservate: `nsg-data-ff1178` associato a `snet-web` (non a `snet-data` nonostante il nome); una sola regola custom, `Allow-Web-Postgres` (Allow, inbound, TCP 5432, source `10.50.10.0/24`, priorità 300)
- Route table associata alla subnet (o assente): assente su entrambe le subnet (route di sistema Azure)
- ciò che è stato verificato: piano di indirizzamento (containment e separazione delle subnet), associazione NSG→subnet, regole e priorità tramite `az network nsg rule list`, assenza di route table custom, assenza di public IP
- report effettivi e test di flusso rinviati alla UD06: `Effective security rules` e `Effective routes` richiedono una VM collegata e in esecuzione, così come IP Flow Verify e Connection Troubleshoot

## Costi e cleanup

Risorse create: 1 VNet, 2 subnet, 1 NSG, 2 NIC, 1 regola NSG custom. Nessuna VM e nessun public IP, quindi costi trascurabili (VNet, NSG e NIC non associati a VM non generano addebiti significativi). Per il cleanup:

```bash
az network nic delete --resource-group rg-cea-network-ff1178 --name nic-web-01
az network nic delete --resource-group rg-cea-network-ff1178 --name nic-data-01
az network nsg delete --resource-group rg-cea-network-ff1178 --name nsg-data-ff1178
az network vnet delete --resource-group rg-cea-network-ff1178 --name vnet-cea-ff1178
az group delete --name rg-cea-network-ff1178 --yes --no-wait
```

Verifica finale: `az network vnet list` e `az network nsg list` devono risultare vuoti dopo l'eliminazione del resource group.

## Rilevanza professionale

La progettazione CIDR e il controllo delle regole devono precedere il deployment dei workload perché:

1. **Risolvere un conflitto di indirizzamento a runtime è costoso**: se due VNet da peering o due subnet si sovrappongono, il deployment va in errore o, peggio, il routing diventa ambiguo. Il piano di indirizzamento va validato su carta prima di creare risorse.
2. **Le dimensioni delle subnet non sono reversibili senza impatto**: ridimensionare una subnet attiva può invalidare indirizzi assegnati alle risorse.
3. **Le regole NSG sono la superficie esposta**: una porta aperta per errore (es. `Any` da `Internet`) espone i workload prima ancora che esistano. Definire regole minime e coerenti col ruolo della subnet (es. TCP 5432 solo da `snet-web` verso `snet-data`) è parte della progettazione, non un ripensamento a posteriori.
4. **Diagnostica più semplice**: con segmentazione e regole definite a priori, il troubleshooting (`risoluzione nome → route → NSG → endpoint → servizio`) ha un riferimento documentato contro cui confrontare lo stato effettivo.

