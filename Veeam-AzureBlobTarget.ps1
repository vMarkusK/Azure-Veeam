#Install-Module -Name Az -Scope CurrentUser
Import-Module -Name Az
Connect-AzAccount

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