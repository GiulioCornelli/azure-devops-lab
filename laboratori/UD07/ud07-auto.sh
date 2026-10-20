#!/usr/bin/env bash

RG="rg-ud07-auto"
LOCATION="westeurope"

EXISTS=$(az group exists --name "$RG")

if [ "$EXISTS" = "false" ]; then
  echo "Il Resource Group non esiste: lo creo."
  az group create \
    --name "$RG" \
    --location "$LOCATION" \
    --tags ManagedBy=Autonomo UD=07 \
    --output table
else
  echo "Il Resource Group esiste già: lo riutilizzo."
fi

echo
echo "Aggiorno i tag..."
az group update \
  --name "$RG" \
  --set tags.ManagedBy=Autonomo tags.UD=07 \
  --output none

echo
echo "Stato finale:"
az group show \
  --name "$RG" \
  --query "{Name:name,Location:location,State:properties.provisioningState}" \
  --output table
