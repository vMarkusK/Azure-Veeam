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

$AzStorageContainer = $AzStorageAccount | New-AzStorageContainer -Name $storageContainer

$AzStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $accountName ).Value[0]


<#
$AzStorageContainer | Remove-AzStorageContainer
$AzStorageAccount | Remove-AzStorageAccount -Confirm:$false
$AzResourceGroup | Remove-AzResourceGroup -Confirm:$false
#>