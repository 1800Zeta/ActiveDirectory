# Check for AzureRM modules, if not install
$PackageProviders = Get-PackageProvider
if($PackageProviders.Name -notcontains 'nuget')
{
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
}

if($PackageProviders.Name -contains 'nuget')
{
    $NuGetVersion = Get-PackageProvider NuGet
    if($NuGetVersion.Version -lt [Version]"2.8.5.208")
    {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
    }
}

$AzureModule = Get-Module AzureRM.storage -List
if($AzureModule.Count -eq 0)
{
    Install-Module AzureRM.storage -Confirm:$false -Force
    Enable-AzureDataCollection
}

# Define Variables
$storageAccName = ""
$containerName = ""
$storageAccKey = ""
$domainname = (Get-ADDomain).DNSRoot

# Set an Azure Blob context to upload
$blobContext = New-AzureStorageContext -StorageAccountName $storageAccName -StorageAccountKey $storageAccKey

# Find the security logs and loop through them
$files = Get-ChildItem 'C:\Windows\System32\Winevt\Logs\' -filter 'Archive-Security-*'

foreach($file in $files)
{
    # Time to upload the files tehn delete from the disk
    $filename = "C:\Windows\System32\Winevt\Logs\$file"
    $destFileName = "$domainname/$env:COMPUTERNAME/$file"
    $destFileName = $destFileName.ToLower()
    $fileupload = Set-AzureStorageBlobContent -File $filename -container $containerName -Blob $destFileName -context $blobContext -Force
    $dstsize = $fileupload.Length
    $filesize = $file.Length
    if($dstsize -eq $filesize)
    {
        Remove-Item $filename
    }
}