$inputXML = @"
<Window x:Class="Azure.Window1"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Azure"
        mc:Ignorable="d"
        Title="Virtual Machine Creator (Linux)" Height="400" Width="525">        
<Grid>
        <Label x:Name="label_NewVM" Content="New Virtual Machine Setup" HorizontalAlignment="Left" Margin="165,10,0,0" VerticalAlignment="Top"/>
        <Label x:Name="label_VMName" Content="VM Name:" HorizontalAlignment="Left" Margin="68,67,0,0" VerticalAlignment="Top" Width="67" Height="25"/>
        <Label x:Name="label_VMMemory" Content="VM RAM:" HorizontalAlignment="Left" Margin="68,97,0,0" VerticalAlignment="Top" Width="67" Height="25"/>
        <Label x:Name="label_VMCpuCount" Content="VM CPU Count:" HorizontalAlignment="Left" Margin="68,127,0,0" VerticalAlignment="Top" Width="108" Height="25"/>
        <Label x:Name="label_VMNetworking" Content="VM Networking:" HorizontalAlignment="Left" Margin="68,157,0,0" VerticalAlignment="Top" Width="108" Height="27"/>
        <Label x:Name="label_HddSize" Content="HDD Size:" HorizontalAlignment="Left" Margin="68,187,0,0" VerticalAlignment="Top" Width="108" Height="25"/>
        <Label x:Name="label_VMHost" Content="Host:" HorizontalAlignment="Left" Margin="68,217,0,0" VerticalAlignment="Top" Width="108" Height="25"/>
        <Label x:Name="label_VMVlan" Content="Final Vlan:" HorizontalAlignment="Left" Margin="68,247,0,0" VerticalAlignment="Top" Width="108" Height="25"/>
        <TextBox x:Name="textBox_VMName" HorizontalAlignment="Left" Height="23" Margin="272,67,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <ComboBox x:Name="comboBox_VMMemory" HorizontalAlignment="Left" Margin="272,101,0,0" VerticalAlignment="Top" Width="120">
            <ComboBoxItem Content="1GB"/>
            <ComboBoxItem Content="2GB"/>
            <ComboBoxItem Content="4GB"/> 
            <ComboBoxItem Content="8GB"/>
        </ComboBox>
        <ComboBox x:Name="comboBox_VMCpuCount" HorizontalAlignment="Left" Margin="272,131,0,0" VerticalAlignment="Top" Width="120">
            <ComboBoxItem Content="1"/>
            <ComboBoxItem Content="2"/>
            <ComboBoxItem Content="4"/> 
            <ComboBoxItem Content="8"/> 
        </ComboBox>
        <ComboBox x:Name="comboBox_VMNetworking" HorizontalAlignment="Left" Margin="272,161,0,0" VerticalAlignment="Top" Width="120">
            <ComboBoxItem Content="ExNet"/>
        </ComboBox>
        <ComboBox x:Name="comboBox_VMHddSize" HorizontalAlignment="Left" Margin="272,191,0,0" VerticalAlignment="Top" Width="120">
            <ComboBoxItem Content="20GB"/>
            <ComboBoxItem Content="40GB"/>
            <ComboBoxItem Content="60GB"/>
            <ComboBoxItem Content="80GB"/>
            <ComboBoxItem Content="100GB"/>
            <ComboBoxItem Content="120GB"/>  
        </ComboBox>
        <ComboBox x:Name="comboBox_VMHost" HorizontalAlignment="Left" Margin="272,221,0,0" VerticalAlignment="Top" Width="120">
            <ComboBoxItem Content="HV-16-1"/>
            <ComboBoxItem Content="HV-16-2"/>
        </ComboBox>
        <ComboBox x:Name="comboBox_VMVlan" HorizontalAlignment="Left" Margin="272,251,0,0" VerticalAlignment="Top" Width="120">
            <ComboBoxItem Content="60 (DMZ)"/>
            <ComboBoxItem Content="70 (Servers)"/>
        </ComboBox>
        <Button x:Name="button_create" Content="Create" HorizontalAlignment="Left" Margin="272,281,0,0" VerticalAlignment="Top" Width="120" />
        <Button x:Name="button_exit" Content="Exit" HorizontalAlignment="Left" Margin="272,311,0,0" VerticalAlignment="Top" Width="120" />
    </Grid>
</Window>
"@       
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}

#Environment Variables
$Path_to_Install = 'C:\Preseed\custom-ubuntu-http-ryan.iso'
 
Get-FormVariables 
#Pulls Data from form into variables
$WPFbutton_create.Add_Click({
$script:VMName = $WPFtextbox_VMName.Text.ToString()
$script:VMMemory = $WPFcombobox_VMMemory.Text.ToString()
$script:VMCpuCount = $WPFcombobox_VMCpuCount.Text.ToString()
$script:VMNetworking = $WPFcombobox_VMNetworking.Text.ToString()
$script:VMHddSize = $WPFcombobox_VMHddSize.Text.ToString()
$script:VMHost = $WPFcombobox_VMHost.Text.ToString()
$script:VMVlan = $WPFcombobox_VMVlan.Text.ToString()
$Form.Close()
})
$WPFbutton_exit.Add_Click({
$Form.Close()
exit
})

#Displays Form
$Form.ShowDialog() | out-null

#Starting Message
Write-Host "Deployment started!"

#Starts Timer
$StartTime = $(get-date)

#Fixes Integer Issue
if ($VMMemory -match "1GB") {
$VMMemory = 1GB }
if ($VMMemory -match "2GB") {
$VMMemory = 2GB }
if ($VMMemory -match "4GB") {
$VMMemory = 4GB }
if ($VMMemory -match "8GB") {
$VMMemory = 8GB }

#Fixes Integer Issue
if ($VMHddSize -match "20GB") {
$VMHddSize = 20GB }
if ($VMHddSize -match "40GB") {
$VMHddSize = 40GB }
if ($VMHddSize -match "60GB") {
$VMHddSize = 60GB }
if ($VMHddSize -match "80GB") {
$VMHddSize = 80GB }

#Converts VLAN to Number
if ($VMVlan -like "60*") {
$VMVlan = 60 }
if ($VMVlan -like "70*") {
$VMVlan = 70 }

#Create VM
Write-Host "Creating VM" 
Invoke-Command -ComputerName $VMHost -ScriptBlock {New-VM -Name $using:VMName -MemoryStartupBytes $using:VMMemory -Generation 2 -SwitchName $using:VMNetworking -NewVHDPath H:\Lab\VHD\$using:VMName\$using:VMName.vhdx -NewVHDSizeBytes $using:VMHddSize}

#Modify CPU Cores
Write-Host "Setting CPU cores"
Invoke-Command -ComputerName $VMHost -ScriptBlock {Set-VMProcessor –VMName $using:VMName –count $using:VMCpuCount}

#Disable Dynamic Memory
Write-Host "Disabling Dynamic Memory"
Invoke-Command -ComputerName $VMHost -ScriptBlock {Set-VMMemory -VMName $using:VMName -DynamicMemoryEnabled $false}

#Modify DVD Drive for PreseedISO
Write-Host "Adding Preseed Disk"
Invoke-Command -ComputerName $VMHost -ScriptBlock {Add-VMScsiController -VMName $using:VMName}
Invoke-Command -ComputerName $VMHost -ScriptBlock {Add-VMDvdDrive -VMName $using:VMName -ControllerNumber 0 -Path $using:Path_to_Install}
Invoke-Command -ComputerName $VMHost -ScriptBlock {$VMDvd = Get-VMDvdDrive -VMName $using:VMName; Set-VMFirmware -VMName $using:VMName -FirstBootDevice $VMDvd}

#Disable Secure Boot
Write-Host "Disabling Secure Boot"
Invoke-Command -ComputerName $VMHost -ScriptBlock {Set-VMFirmware -VMName $using:VMName -EnableSecureBoot Off}

#Networking Settings Change
Write-Host "Changing to deployment VLAN ready for kicking"
Invoke-Command -ComputerName $VMHost -ScriptBlock {Set-VMNetworkAdapterVlan -VMName $using:VMName -Access -VlanId 4010}

#Start VM for Deployment
Write-Host "Starting VM"
Invoke-Command -ComputerName $VMHost -ScriptBlock {Start-VM -VMName $using:VMName}

#Check for DVD
Write-Host "Waiting for ISO to be ejected"
do {
$VMDvdDriveStatus = Invoke-Command -ComputerName $VMHost -ScriptBlock {Get-VMDvdDrive -VMName $using:VMName | Select-Object DvdMediaType}
$VMDvdDriveConnected = $VMDvdDriveStatus.DvdMediaType
if ($VMDvdDriveConnected.Value -eq 'ISO'){
Write-Host "ISO still mounted! Pausing for 1 minute."
Start-Sleep 60
}
if ($VMDvdDriveConnected.Value -eq 'None'){
Write-Host "ISO removed! Resuming script!"
}
}
until($VMDvdDriveConnected.Value -eq 'None')

#Networking Settings Reverted
Write-Host "Changing to standard VLAN for connectivity tests"
Invoke-Command -ComputerName $VMHost -ScriptBlock {Set-VMNetworkAdapterVlan -VMName $using:VMName -Access -VlanID $using:VMVlan}

#Works out how long deployment took
$elapsedTime = $(get-date) - $StartTime
$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)

#Final Ouput
Write-Host "Deployment completed after $totalTime. Please test connectivity to virtual machine $VMName on VLAN $VMVlan."

#Logic to implement in time

#Remove dvd drive after deployment? Will this be needed?
#Pull MAC of VM and add this to the final output for layer 2 troubleshooting.
#Add more output to the final message, such as VM name, host, etc.
#Add more verbose logging. ie, vm hardware built, starting and installing OS now.

#Debug Output - move to line 102 if needed.
#clear
#Write-Host $VMName
#Write-Host $VMMemory
#Write-Host $VMCpuCount
#Write-Host $VMNetworking
#Write-Host $VMHDDSize
#Write-Host $VMHost
#Write-Host $VMVlan
#Write-Host $Path_to_Install