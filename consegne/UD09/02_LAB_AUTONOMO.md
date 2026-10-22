# UD09 — Consegna laboratorio autonomo

## 1. Organization e Project

- Organization: `azdo-giuliocornelli-1`
- Project: `az900-az104-devops`
- Visibility: `Private`
- Source repository: `GiulioCornelli/azure-devops-lab` (GitHub)

1. Il Project è privato per non esporre codice, configurazioni e pipeline a utenti non autorizzati: solo i membri dell'Organization possono accedervi. È coerente con il principio del least privilege e con un ambiente didattico che non deve essere pubblico.
2. Il source repository rimane GitHub perché è l'unica fonte di verità del codice e delle Pull Request: duplicarlo in Azure Repos creerebbe due copie da sincronizzare, con rischio di divergenza. Azure DevOps viene usato per Pipelines e Agent, non come secondo repository.

## 2. Gruppi

| Gruppo | Scopo | Tutti? |
|---|---|---|
| Project Administrators | Gestione ampia del Project: impostazioni, permessi, sicurezza, servizi. | No. È un privilegio troppo ampio: va assegnato solo a chi amministra davvero il Project. |
| Contributors | Utenti che contribuiscono normalmente al lavoro: creano e modificano work item, codice, pipeline. | Sì ai membri del team che devono lavorare, no a utenti esterni o di sola consultazione. |
| Readers | Accesso prevalentemente in lettura agli oggetti del Project. | Tendenzialmente sì a osservatori e stakeholder, perché il rischio è limitato; non a utenti anonimi. |
| Build Administrators | Privilegi aggiuntivi relativi a build e pipeline (gestione agent, code, permessi di build). | No. Solo a chi amministra le pipeline e l'infrastruttura di build. |

## 3. GitHub integration readiness

- repository: `GiulioCornelli/azure-devops-lab`
- private: sì
- gh auth: autenticato come `GiulioCornelli` (protocollo Git: SSH)
- git fetch: eseguito senza errori
1. In UD09 non abbiamo creato una service connection GitHub OAuth/PAT perché non serve ancora: Microsoft raccomanda di stabilire l'integrazione tramite **Azure Pipelines GitHub App** quando si crea la prima pipeline GitHub. Creare oggi una connessione personale OAuth/PAT produrrebbe una credenziale che poi non useremmo e che andrebbe gestita/revocata inutilmente.
2. Quando creeremo la prima pipeline GitHub useremo l'integrazione **Azure Pipelines GitHub App**, selezionando il repository del corso durante la creazione della pipeline.
3. Duplicare il repository in Azure Repos creerebbe confusione, sincronizzazione inutile e rischio di divergenza tra due copie. GitHub resta l'unica fonte autorevole del codice e delle Pull Request.

## 4. Parallel jobs

- hosted: `1` job concorrente (free tier) — stato `MICROSOFT_HOSTED_READY`
- self-hosted: `1` job concorrente
1. No, il corso non è bloccato: anche con Microsoft-hosted = 0 il self-hosted Agent è configurato e funzionante, quindi le pipeline possono essere eseguite.
2. Con un solo parallel job self-hosted può essere eseguito **un Job alla volta**; gli altri restano in coda.
3. No. Registrare 3 agent non aumenta automaticamente la concorrenza: il numero di job simultanei dipende dalla capacità di **Parallel Jobs** dell'Organization, non dal numero di agent. Servono più agent **e** sufficiente capacità di parallel jobs.

## 5. Agent audit

- pool: `pool-ud09-wsl`
- agent: `Legno`
- status: Online
- version: `5.280` (`5.280.0`)
- Agent.OS: `Linux`
- Agent.Version: `5.280.0`
- git: `/usr/bin/git`
- python: python3 -> `/usr/bin/python3`

## 6. Registration authentication audit

- metodo: `PAT`
- status PAT, se applicabile: `ud09-agent-registration` — `Revoked` (scope usato: `Agent Pools (Read & manage)`, expiration 30 giorni)
1. L'agent resta Online dopo la revoca del PAT perché il PAT è servito **solo alla registrazione** (`config.sh`): una volta registrato, l'agent usa le proprie credenziali/identità per comunicare con Azure DevOps e ricevere i Job.
2. Non serve un PAT Full access perché per registrare un agent basta lo scope minimo `Agent Pools (Read & manage)`. Un token più ampio aumenterebbe solo la superficie di rischio, violando il least privilege.
3. Il Device Code Flow è un fallback migliore perché usa l'autenticazione AAD nel browser, non crea un token da conservare e revocare e non richiede di indebolire una policy di sicurezza dell'Organization.

## 7. Offline/Online

- stop: `Ctrl+C` nel terminale dell'agent
- stato: `Offline`
- restart: `./run.sh` dalla directory `$AGENT_DIR`
- stato: `Online`

## 8. Troubleshooting

Scenario: agent configurato ma `Offline`. Checklist in ordine:

1. **Processo `run.sh`**: verificare che il processo dell'agent sia in esecuzione nel terminale dedicato (o con `ps`); se non lo è, avviarlo con `./run.sh`.
2. **Rete/HTTPS**: verificare connettività verso `https://dev.azure.com` (DNS, proxy, firewall, certificati); un blocco di rete impedisce all'agent di risultare Online.
3. **Organization URL**: controllare che l'URL configurato sia `https://dev.azure.com/<ORG_NAME>` corretto, senza errori di battitura o Organization sbagliata.
4. **Pool**: verificare che l'agent sia registrato nel pool atteso (`pool-ud09-wsl`), che il pool esista ancora e che l'account abbia i permessi necessari.
5. **Directory agent/configurazione**: assicurarsi di eseguire `run.sh` dalla directory corretta (`$AGENT_DIR`), che la configurazione (`.agent`, credenziali) sia presente e non danneggiata.
6. **Diagnostica**: eseguire `./run.sh --diagnostics` e leggere i log in `_diag` per individuare la causa. Non eseguire rimozione/re-registrazione come prima azione.

## 9. Readiness

| Controllo | PASS/FAIL | Nota |
|---|---|---|
| Organization | PASS | `azdo-giuliocornelli-1`, collegata alla sottoscrizione Azure |
| Project | PASS | `az900-az104-devops`, Private, Git, processo Agile |
| GitHub readiness | PASS | `GiulioCornelli/azure-devops-lab`, privato, `git fetch` OK, GitHub App prevista |
| Hosted | PASS | `MICROSOFT_HOSTED_READY`, 1 job concorrente |
| Pool | PASS | `pool-ud09-wsl` self-hosted, accesso automatico disabilitato |
| Agent | PASS | `Legno` Online |
| PAT / Device Code Flow | PASS | PAT `ud09-agent-registration` revocato, agent ancora Online |
| Capability | PASS | `Agent.OS` Linux, git e python3 rilevati |
| Restart | PASS | Offline dopo `Ctrl+C`, Online dopo `./run.sh` |
| Secrets | PASS | Nessun PAT/token nei file di consegna o nel repository |
