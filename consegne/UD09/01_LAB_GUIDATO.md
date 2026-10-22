# UD09 — Consegna laboratorio guidato

## Organization

- nome: `azdo-giuliocornelli-1`
- geography: `Europe`
- Azure subscription collegata: sì

## Project

- nome: `az900-az104-devops`
- visibility: `Private`
- version control: `Git`
- process: `Agile`

## Gruppi

| Gruppo                 | Funzione essenziale                                                           |
| ---------------------- | ----------------------------------------------------------------------------- |
| Project Administrators | persona o gruppo che gestisce l'intero progetto                               |
| Contributors           | persone che possono aggiungere, leggere e modificare gli oggetti nel progetto |
| Readers                | persone che possono esclusivamente leggere gli oggetti di un progetto         |
| Build Administrators   | utenti con privilegi aggiuntivi relativi a build e pipeline                    |

## GitHub

- repository: `GiulioCornelli/azure-devops-lab`
- repository privato: sì
- `gh auth status`:
```
✓ Logged in to github.com account GiulioCornelli (keyring)
  - Active account: true
  - Git operations protocol: ssh
  - Token: gho_************************************
  - Token scopes: ********************************
```
- `git fetch`: eseguito senza errori
- connessione OAuth/PAT creata in UD09: NO
- metodo raccomandato per CI futura: Azure Pipelines GitHub App

## Parallel jobs

- Microsoft-hosted: `1` job concorrente (free tier)
- esito hosted: `MICROSOFT_HOSTED_READY`
- self-hosted: `1` job concorrente
- billing verificato: sì

## Agent Pool

- creato da Project settings: sì
- nome: `pool-ud09-wsl`
- tipo: `Self-hosted`
- accesso automatico a tutte le pipeline: disabilitato

## Autenticazione registrazione agent

- metodo usato: `PAT`
- PAT name, se usato: `ud09-agent-registration`
- PAT scope, se usato: `Agent Pools (Read & manage)`
- expiration: 30 giorni
- inserito in file/repository: NO
- PAT revocato, se usato: sì

## Agent

- nome: `Legno`
- pool: `pool-ud09-wsl`
- OS: `Linux (Debian)`
- version: `5.280`
- status: Online
- modalità: `Listening for Jobs`
- credenziale di registrazione chiusa e agent ancora Online: sì

## Capability

- Agent.OS: `Linux`
- Agent.Version: `5.280.0`
- git: `/usr/bin/git`
- python: python3 -> `/usr/bin/python3`
- PATH verificato: `/home/giulio/.nvm/versions/node/v24.21.0/...`

## Readiness

- Organization: `azdo-giuliocornelli-1`
- Project: `az900-az104-devops` (Private, Agile, Git)
- GitHub: `GiulioCornelli/azure-devops-lab` (privato), integrazione futura via Azure Pipelines GitHub App
- hosted: `MICROSOFT_HOSTED_READY`
- self-hosted: `pool-ud09-wsl`, 1 parallel job
- agent: `Legno` — Online
- security: PAT `ud09-agent-registration` revocato, nessun segreto nel repository
