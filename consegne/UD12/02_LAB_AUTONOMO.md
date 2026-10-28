# UD12 — Laboratorio autonomo

## 1. Ripristinare il contesto
- Repository: /home/giulio/Corsi/Corso-Azure/azure-devops-lab
- Directory Terraform: infra/terraform
- Azure: giulio.cornelli05@gmail.com / Azure subscription 1
- ARM_SUBSCRIPTION_ID impostato
- Storage Account dal state: stt3183440

## 2. Controllare la baseline
- `terraform plan`: No changes. (stato coerente tra codice/state/Azure)

## 3. Modificare un tag
Aggiunto `Environment = "Training"` ai tag dello Storage Account in `main.tf`.

## 4. Formattare e validare
- `terraform fmt`: eseguito
- `terraform validate`: Success!

## 5. Leggere il piano di modifica
- `terraform plan -out=ud12-change.tfplan`: 0 to add, 1 to change, 0 to destroy
- Motivo: i tag sono una proprietà aggiornabile; Terraform applica una modifica in-place senza ricreare lo Storage Account.

## 6. Applicare la modifica
- `terraform apply ud12-change.tfplan`: completato
- Verifica Azure CLI: tags mostrano Course, UD, ManagedBy, Environment = Training

## 7. Introdurre un errore controllato
- Modificato temporaneamente `location = azurerm_resource_group.lab.location` in `azurerm_resource_group.training.location`
- `terraform validate`: errore "Reference to undeclared resource" (risorsa non dichiarata)
- Corretto riportando al valore corretto e rieseguito `validate`/`plan` - nessuna modifica inattesa

## 8. Correzione e verifica
- Configurazione corretta, `terraform validate` OK, `terraform plan` senza modifiche inattese

## 9. Commit dei file IaC prima del destroy
- Aggiunte regole `.gitignore`: .terraform/, *.tfstate, *.tfstate.*, *.tfplan
- Commit: "feat: add Bicep and Terraform infrastructure baseline" (inclusi infra/bicep, infra/terraform/*.tf, .terraform.lock.hcl)
- Push su origin/main

## 10. Distruggere le risorse Terraform
- `terraform plan -destroy`: mostra eliminazione azurerm_storage_account.lab e azurerm_resource_group.lab
- Risorse verificate con `az resource list` (solo stt3183440 nel rg)
- `terraform destroy -auto-approve` eseguito confermando le due risorse

## 11. Verifica cleanup Terraform
- `az group exists --name rg-ud12-tf`: false
- `terraform state list`: vuoto/nessuna risorsa gestita
- File IaC conservati (.tf, .terraform.lock.hcl)

## 12. Prepararsi al Gate 2
- Terraform e Bicep disponibili, agent mantenuto per UD13-UD14
