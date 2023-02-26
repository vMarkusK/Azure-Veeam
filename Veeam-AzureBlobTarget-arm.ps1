#Install-Module -Name Az -Scope CurrentUser
Import-Module -Name Az
Connect-AzAccount

$resourceGroupName = "veeamautomation"

# Create Ressources
## Resource Group
$AzResourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location
## Storage Account
$AzResourceGroupDeployment = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
    -TemplateFile ./arm/Veeam-AzureBlobtarget.json `
    -TemplateParameterFile ./arm/Veeam-AzureBlobtarget.parameters.json

$AzStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $AzResourceGroupDeployment.Parameters.storageAccountName.Value ).Value[0]
$AzStorageAccountName = $AzResourceGroupDeployment.Parameters.storageAccountName.Value

# Remove-AzResourceGroup -Name $resourceGroup