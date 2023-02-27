#Install-Module -Name Az -Scope CurrentUser
Import-Module -Name Az
Connect-AzAccount

Import-Module -Name Veeam.Backup.PowerShell 
$VBRCredentials = Get-Credential -Message "VBR Credentials"
Connect-VBRServer -Server 192.168.70.146 -Credential $VBRCredentials

$resourceGroup = "veeamautomation"
$location = "germanywestcentral"
$accountName = "veeamautomationstorage"
$storageContainer = "veeamautomationstorageblob"

$AzResourceGroup = New-AzResourceGroup -Name $resourceGroup -Location $location
$AzStorageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup `
                    -Name $accountName `
                    -Location $location `
                    -SkuName Standard_LRS `
                    -Kind StorageV2 `
                    -AccessTier Hot 
$AzStorageAccount | Set-AzStorageAccount -AllowBlobPublicAccess $false
$AzStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $accountName ).Value[0]
Start-Sleep 5
$AzStorageContainer = $AzStorageAccount | New-AzStorageContainer -Name $storageContainer
# Disable Soft Delete
$ctx = New-AzStorageContext -StorageAccountName $accountName -StorageAccountKey $AzStorageAccountKey
Disable-AzStorageDeleteRetentionPolicy -Context $ctx
Disable-AzStorageContainerDeleteRetentionPolicy -ResourceGroupName $resourceGroup `
    -StorageAccountName $accountName
Disable-AzStorageBlobDeleteRetentionPolicy -ResourceGroupName $resourceGroup `
    -StorageAccountName $accountName
Update-AzStorageFileServiceProperty -ResourceGroupName $resourceGroup `
    -StorageAccountName $accountName `
    -EnableShareDeleteRetentionPolicy $false 
# Disable Versioning
Update-AzStorageBlobServiceProperty -ResourceGroupName $resourceGroup `
    -StorageAccountName $accountName `
    -IsVersioningEnabled $false
# Set TLS Version
Set-AzStorageAccount -ResourceGroupName $resourceGroup `
    -StorageAccountName $accountName `
    -MinimumTlsVersion TLS1_2
<#
$AzStorageContainer | Remove-AzStorageContainer
$AzStorageAccount | Remove-AzStorageAccount -Confirm:$false -Force
$AzResourceGroup | Remove-AzResourceGroup -Confirm:$false -Force
#>

# Connect to VBR
## Credentials
$VBRAzureBlobAccount = Add-VBRAzureBlobAccount -Name $AzStorageAccountName -SharedKey $AzStorageAccountKey
## Create Folder
$VBRAzureBlobService = Connect-VBRAzureBlobService -Account $VBRAzureBlobAccount -RegionType Global -ServiceType CapacityTier
$VBRAzureBlobContainer = Get-VBRAzureBlobContainer -Connection $VBRAzureBlobService
$VBRAzureBlobFolder = New-VBRAzureBlobFolder -Container $VBRAzureBlobContainer -Connection $VBRAzureBlobService -Name "veeamautomation"
## Add Repo
$VBRAzureBlobRepository = Add-VBRAzureBlobRepository -AzureBlobFolder $VBRAzureBlobFolder[0] -Connection $VBRAzureBlobService -Name "veeamautomation"
## Disconect
Disconnect-VBRAzureBlobService -Connection $VBRAzureBlobService
Get-VBRBackupRepository -Name "veeamautomationarm"