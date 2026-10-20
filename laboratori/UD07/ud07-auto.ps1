$ErrorActionPreference = "Stop"

$rgName = "rg-ud07-auto-ps"
$location = "westeurope"

$rg = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue

if (-not $rg) {
    Write-Output "Il Resource Group non esiste: lo creo."
    New-AzResourceGroup -Name $rgName -Location $location -Tag @{ ManagedBy = "PowerShell"; UD = "07" } | Out-Null
}
else {
    Write-Output "Il Resource Group esiste già: lo riutilizzo."
}

Write-Output ""
Write-Output "Aggiorno i tag..."
Set-AzResourceGroup -Name $rgName -Tag @{ ManagedBy = "PowerShell"; UD = "07" } | Out-Null

Write-Output ""
Write-Output "Proprietà essenziali:"
Get-AzResourceGroup -Name $rgName |
    Select-Object ResourceGroupName, Location, ProvisioningState |
    Format-Table -AutoSize
