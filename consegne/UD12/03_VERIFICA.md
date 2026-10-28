# UD12 — Verifica individuale

## Parte A

1. **B.** Lo stato desiderato
2. **A.** Azure Resource Manager
3. **B.** Prevedere le modifiche di un deployment
4. **B.** Prepara la directory e i provider
5. **B.** Controlla la configurazione senza applicare risorse
6. **B.** Collega gli oggetti Terraform alle risorse gestite
7. **B.** Rimuove le risorse gestite dalla configurazione/state
8. **B.** Codice IaC, strumenti e agent configurato

## Parte B

9. **Imperativo:** descrive le azioni passo passo (*come* farlo). **Dichiarativo:** descrive lo stato desiderato (*cosa* ottenere), lasciando allo strumento decidere *come* raggiungerlo.

10. Separare parametri e risorse rende il template riutilizzabile: posso cambiare valori (nome, regione) senza modificare la logica di definizione delle risorse.

11. **Bicep What-If:** mostra le modifiche previste per un deployment Bicep verso ARM. **Terraform Plan:** mostra il confronto tra configurazione, stato e realtà, indicando add/change/destroy.

12. Lo state mappa gli oggetti Terraform alle risorse reali. Può contenere dati sensibili e va gestito centralmente; committarlo rischia conflitti e esposizione di informazioni.

13. **validate:** verifica sintassi/correttezza. **plan:** mostra le modifiche previste. **apply:** applica effettivamente le modifiche per raggiungere lo stato desiderato.

14. I file IaC sono versionabili e riutilizzabili nelle prossime UD; le risorse Azure sono temporanee e andrebbero eliminate, ma i file vanno conservati.

## Parte C

15. **No.** `validate` controlla solo la configurazione. Con `1 to add, 0 to change, 2 to destroy` il piano prevede eliminazioni imprevise; va analizzato prima di applicare.

16. Verificare il `terraform plan`, confrontarlo con le modifiche fatte (`git diff`), capire perché elimina 2 risorse, e solo se corretto procedere con `terraform apply`.

17. Installare i tool in WSL2 prepara l'ambiente del self-hosted agent (usa quel sistema). Un Microsoft-hosted agent parte da un'immagine pulita e non vede file/tool installati sulla nostra macchina.

18. Ogni job Microsoft-hosted è isolato: file creati in un job precedente non esistono nel successivo. Serve quindi reinstallare/verificare tool o usare artefatti.

19. Per assicurarsi che l'ambiente del job abbia le versioni corrette di Terraform/Azure CLI/Bicep necessarie all'esecuzione dei comandi IaC.

20. **Vantaggio:** `ubuntu-latest` riceve aggiornamenti e patch. **Rischio:** può cambiare versione tool in modo imprevisto, rendendo il build meno riproducibile rispetto a un'immagine versionata.

## Gate 2

- agent Online: da verificare in Azure DevOps (pool-ud09-wsl)
- Terraform disponibile: sì (v1.17.0)
- Azure CLI/Bicep disponibile: sì (az + Bicep 0.48.1)
- Git/Python/Docker disponibili: sì

## 17.
Vedi Parte C 17.

## 18.
Vedi Parte C 18.

## 19.
Vedi Parte C 19.

## 20.
Vedi Parte C 20.

## Gate 2A — self-hosted

- Agent Online: da verificare (pool-ud09-wsl / agent UD09)
- Terraform: v1.17.0
- Azure CLI: disponibile
- Bicep: 0.48.1
- Git: 2.47.3
- Python: 3.13.5
- Docker: 29.9.2

## Gate 2B — Microsoft-hosted

- stato: da verificare (UD09) - se non READY non blocca UD13
