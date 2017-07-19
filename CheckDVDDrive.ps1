$VMDvdDriveStatus = Get-VMDvdDrive -VMName $VMName
if ([boolean]$VMDvdDriveStatus -match 'TRUE'){
Write-Host "True"
}
if ([boolean]$VMDvdDriveStatus -match 'FALSE') {
Write-Host "False"
}

