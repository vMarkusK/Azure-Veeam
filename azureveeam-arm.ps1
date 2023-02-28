#Install-Module -Name Az -Scope CurrentUser
Import-Module -Name Az
Connect-AzAccount


$resourceGroupName = "veeamazure_group"
$location = "germanywestcentral"

# Create Ressources
## Resource Group
$AzResourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location
## Storage Account
$AzResourceGroupDeployment = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
    -TemplateFile ./arm/azureveeam.json `
    -TemplateParameterFile ./arm/azureveeam.parameters.json

# Remove-AzResourceGroup -Name $resourceGroupName