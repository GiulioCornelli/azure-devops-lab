# UD13 — Verifica

## 1.
**Domanda:** Perché lo state locale non è ideale in un team?
**Risposta:** Perché copie locali indipendenti possono divergere e una pipeline non può basarsi sull'unica copia aggiornata sul PC di un collega: serve uno state condiviso su backend remoto.

## 2.
**Domanda:** Che differenza c'è tra stage, job e step?
**Risposta:** Lo stage è una fase logica (es. Validate/Deploy), il job è una sequenza di step assegnata a un agent, lo step è una singola operazione (checkout, script, task).

## 3.
**Domanda:** Che cosa rappresenta `checkout: self`?
**Risposta:** Il repository associato alla pipeline: ne rende disponibile all'agent la versione del commit scelta per l'esecuzione (nel nostro caso include anche i file YAML).

## 4.
**Domanda:** Perché la service connection è limitata a `rg-ud13-15-delivery`?
**Risposta:** Per applicare il minimo privilegio: il ruolo `Contributor` vale solo su quel Resource Group, non sull'intera subscription.

## 5.
**Domanda:** Perché usiamo Workload Identity Federation?
**Risposta:** Per autenticarsi con token temporanei tramite una relazione di fiducia, senza conservare un client secret statico (e con l'admin user dell'ACR disabilitato).

## 6.
**Domanda:** Perché in pipeline Terraform viene validato ma non applicato?
**Risposta:** La pipeline esegue solo `fmt -check`, `init -backend=false` e `validate`; non assume la gestione dello state/infrastruttura condivisa, quindi non esegue `plan`/`apply`.

## 7.
**Domanda:** Quale risorsa deve sopravvivere a UD13 e perché?
**Risposta:** L'ACR (insieme a `rg-ud13-15-delivery`, service connection e agent), perché l'immagine pubblicata dalla CI è l'input della Continuous Delivery in UD14.

## 8.
**Domanda:** Se `az bicep lint` fallisce per un file inesistente, quale classe di problema stiamo diagnosticando?
**Risposta:** Un problema di percorso/file (checkout incompleto o directory di lavoro errata), non di sintassi Bicep né di autorizzazioni Azure.

## 9.
**Domanda:** Perché la prima pipeline UD13 usa il self-hosted Agent?
**Risposta:** Per mostrare concretamente che i comandi girano sull'agent WSL2 preparato nelle UD precedenti (`pool-ud09-wsl`), non sul terminale interattivo del partecipante.

## 10.
**Domanda:** A che cosa serve `workspace: clean: all`?
**Risposta:** A pulire l'intero `Pipeline.Workspace` prima del job, evitando che file rimasti da esecuzioni precedenti sul self-hosted influenzino la run.

## 11.
**Domanda:** Distingui la GitHub App dalla Azure Resource Manager service connection.
**Risposta:** La GitHub App autorizza Azure Pipelines a leggere il repository; la service connection ARM fornisce l'identità con cui i task operano sulle risorse Azure. Sono due autorizzazioni distinte.

## 12.
**Domanda:** Perché non usiamo `~/workspace/azure-devops-lab` dentro il YAML?
**Risposta:** Perché è un percorso personale che non esisterebbe su altri agent; si usa `$(Build.SourcesDirectory)` per rendere il YAML portabile.

## 13.
**Domanda:** Che cosa cambierà quando nella preparazione CI useremo `vmImage: ubuntu-latest`?
**Risposta:** Ogni job riceverà una VM Microsoft temporanea ed eliminata a fine job: gli strumenti dipendono dall'immagine, i file non persistono e ogni job deve fare il proprio checkout.
