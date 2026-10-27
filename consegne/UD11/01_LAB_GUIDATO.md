# UD11 — Consegna laboratorio guidato

## Preflight

- Azure: OK
- Docker: OK
- containerapp extension: OK
- Microsoft.App: registrato
- Microsoft.OperationalInsights: registrato

## ACR

- nome: acr1793100129ud11
- SKU: Basic
- login server: acr1793100129ud11.azurecr.io
- repository: catalog-backend
- tag v1: presente
- tag v2: presente
- admin user abilitato: NO

## v1

- local test: OK (curl/http su localhost)
- push: eseguito con `az acr login` + `docker push`
- ACR tag: catalog-backend:v1
- ACA environment: acaenv-ud11 (North Europe)
- Container App: catalog-api-ud11
- managed identity: SystemAssigned (principalId b8439677-04c4-4eec-9382-f6f5cb274fad)
- registry identity: SystemAssigned con ruolo AcrPull su ACR
- ingress: external (HTTPS)
- target port: 8000
- FQDN: catalog-api-ud11.bravemeadow-3a797805.northeurope.azurecontainerapps.io
- health: OK
- version: v1 (poi aggiornato a v2)
- revision: catalog-api-ud11--v2 (attiva, Healthy, 1 replica)
- logs: verificati con `az containerapp logs show`

## v2

- Dockerfile version:
- local test:
- push:
- ACR tag:
- update:
- revision:
- health:
- version:

## Scaling

- minReplicas:
- maxReplicas:
- scale-to-zero possibile:
