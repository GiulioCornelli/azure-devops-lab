# UD14 — Consegna LAB autonomo

## LAB autonomo CD (target port)

- branch errore: `fix/ud15-target-port`
- target port errato: `9999` (l'applicazione ascolta su `8000`)
- differenza nel Terraform plan: `~ target_port = 8000 -> 9999` su `azurerm_container_app.api` (`0 to add, 1 to change, 0 to destroy`)
- IaC: riuscito (`fmt -check`, `validate`, `plan` con modifica prevista)
- Test: riuscito
- BuildPush: riuscito (immagine `catalog-backend:119`)
- Deploy: riuscito (`apply` con 1 modifica; Container App aggiornata a target port `9999`)
- Smoke: fallito (`curl --fail` su `https://<FQDN>/health` senza risposta utile)
- evidenza ingress: `External=True`, `TargetPort=9999`, FQDN `catalog-api-ud15.mangohill-7c4e5a91.northeurope.azurecontainerapps.io`
- evidenza log: `Catalog backend 119 listening on 0.0.0.0:8000`; nessuna richiesta ricevuta sulla porta `9999`
- causa: mismatch tra la target port dell'ingress (`9999`) e la porta su cui l'applicazione ascolta (`8000`)
- correzione minima: ripristinare `targetPort: '8000'` in `pipelines/azure-pipelines-delivery.yml` e distribuire una nuova revision
- branch correzione: `fix/ud15-target-port-correct`
- run finale: Build ID `120`, stage `IaC`/`Test`/`BuildPush`/`Deploy`/`Smoke` tutti riusciti (`Deploy`: 1 modifica)
- smoke finale: `{"status":"ok","service":"catalog-backend","version":"120"}`

## LAB autonomo CI (versione ci-v2)

- branch: `feature/ud14-ci-v2`
- modifica app: `APP_VERSION` di default da `ci-v1` a `ci-v2` in `app/catalog-backend-ci/server.py`
- test fallito: `test_health_version` (atteso `ci-v1`, ottenuto `ci-v2`)
- causa: il test non era stato aggiornato alla nuova versione attesa
- modifica test: `assertEqual(payload["version"], "ci-v1")` → `"ci-v2"` in `tests/test_backend.py`
- test finale: 3 test eseguiti, `OK`
- PR: aperta e mergiata su `main`
- merge: sì
- run CI: riuscita (`Test` → `BuildPush`)
- nuovo tag ACR: `117`
- cleanup eseguito: NO
