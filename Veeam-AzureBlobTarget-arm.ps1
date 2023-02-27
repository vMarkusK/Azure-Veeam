#Install-Module -Name Az -Scope CurrentUser
Import-Module -Name Az
Connect-AzAccount

Import-Module -Name Veeam.Backup.PowerShell 
$VBRCredentials = Get-Credential -Message "VBR Credentials"
Connect-VBRServer -Server 192.168.70.146 -Credential $VBRCredentials

$resourceGroupName = "veeamautomation"
$location = "germanywestcentral"

# Create Ressources
## Resource Group
$AzResourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location
## Storage Account
$AzResourceGroupDeployment = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
    -TemplateFile ./arm/Veeam-AzureBlobtarget.json `
    -TemplateParameterFile ./arm/Veeam-AzureBlobtarget.parameters.json

$AzStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $AzResourceGroupDeployment.Parameters.storageAccountName.Value ).Value[0]
$AzStorageAccountName = $AzResourceGroupDeployment.Parameters.storageAccountName.Value

# Remove-AzResourceGroup -Name $resourceGroupName

# Connect to VBR
## Credentials
$VBRAzureBlobAccount = Add-VBRAzureBlobAccount -Name $AzStorageAccountName -SharedKey $AzStorageAccountKey
## Create Folder
$VBRAzureBlobService = Connect-VBRAzureBlobService -Account $VBRAzureBlobAccount -RegionType Global -ServiceType CapacityTier
$VBRAzureBlobContainer = Get-VBRAzureBlobContainer -Connection $VBRAzureBlobService
$VBRAzureBlobFolder = New-VBRAzureBlobFolder -Container $VBRAzureBlobContainer -Connection $VBRAzureBlobService -Name "veeamautomationarm"
## Add Repo
$VBRAzureBlobRepository = Add-VBRAzureBlobRepository -AzureBlobFolder $VBRAzureBlobFolder[0] -Connection $VBRAzureBlobService -Name "veeamautomationarm"
## Disconect
Disconnect-VBRAzureBlobService -Connection $VBRAzureBlobService
Get-VBRBackupRepository -Name "veeamautomationarm"