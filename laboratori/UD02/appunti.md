Località: italynorth
RG: rg-cea-ud02-d5e472dd
VNet: vnet-cea-ud02
Subnet: snet-app
Storage: stcead5e472dd
Cleanup entro: 2026-10-15


az storage account create \
  --resource-group "$LAB_RG" \
  --name "&LAB_STORAGE" \
  --location "$LAB_LOCATION" \
  --kind StorageV2 \
  --sku Standard_LRS \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags course=cloud-engineer-lab-autonomo unit=UD02 enviromment=lab-autonomo -o jsonc