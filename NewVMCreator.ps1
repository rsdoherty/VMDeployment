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
        <Label x:Name="label_VMHost" Content="Host" HorizontalAlignment="Left" Margin="68,217,0,0" VerticalAlignment="Top" Width="108" Height="25"/>
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
            <ComboBoxItem Content="LAN Uplink"/>
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
            <ComboBoxItem Content="HC0"/>
            <ComboBoxItem Content="HC1"/>
            <ComboBoxItem Content="HC2"/> 
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
$Path_to_Install = 'C:\Users\ryan\Downloads\Preseed\custom-ubuntu-http-ryan.iso'
 
Get-FormVariables 
#Pulls Data to from form into variables
$WPFbutton_create.Add_Click({
$script:VMName = $WPFtextbox_VMName.Text.ToString()
$script:VMMemory = $WPFcombobox_VMMemory.Text.ToString()
$script:VMCpuCount = $WPFcombobox_VMCpuCount.Text.ToString()
$script:VMNetworking = $WPFcombobox_VMNetworking.Text.ToString()
$script:VMHddSize = $WPFcombobox_VMHddSize.Text.ToString()
$script:VMHost = $WPFcombobox_VMHost.Text.ToString()
$Form.Close()
})
$WPFbutton_exit.Add_Click({
$Form.Close()
exit
})

#Displays Form
$Form.ShowDialog() | out-null

#Debug Output
clear
Write-Host $VMName
Write-Host $VMMemory
Write-Host $VMCpuCount
Write-Host $VMNetworking
Write-Host $VMHDDSize
Write-Host $VMHost
Write-Host $Path_to_Install

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

#Create VM
Write-Host "Creating VM" 
New-VM -Name $VMName -MemoryStartupBytes $VMMemory -Generation 2 -SwitchName $VMNetworking -NewVHDPath C:\Lab\VHD\$VMName\$VMName.vhdx -NewVHDSizeBytes $VMHddSize

#Modify CPU Cores
Write-Host "Setting CPU cores:"
Set-VMProcessor –VMName $VMName –count $VMCpuCount

#Modify DVD Drive for PreseedISO
Write-Host "Adding Preseed Disk"
Add-VMScsiController -VMName $VMName
Add-VMDvdDrive -VMName $VMName -ControllerNumber 0 -Path $Path_to_Install
$VMDvd = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $VMDvd

#Disable Secure Boot
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

#Networking Settings Change
Write-Host "Changing to deployment VLAN ready for kicking"
Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanId 4010

#Start VM for Kicking
Write-Host "Starting VM!"
Start-VM -VMName $VMName

#Manual Pause (Testing only)
Read-Host -Prompt "Press Enter to continue"

#Patience (Add in a loop to check for when the DVD media is ejected)
#Write-Host "Waiting for VM to deploy... sleeping for 5 seconds."
#Start-Sleep -s 120

#Networking Settings Reverted
Write-Host "Changing to standard VLAN for connectivity tests following a reboot"
Set-VMNetworkAdapterVlan -VMName $VMName -Untagged

#Forcefully Restart Host
Write-Host "Server forcefully going down ready for connectivity check!"
Restart-VM $VMName -Force

#Debug Code
#Write-Host "Debugging:"
#Get-VM -Name $VMName | Format-Table

#Logic below to identify when 'kick' has completed. This will run in a loop, every 30 seconds, before waiting to run connectivity checks.

#$VMDvdDriveStatus = Get-VMDvdDrive -VMName $VMName
#if ([boolean]$VMDvdDriveStatus -match 'TRUE'){
#Write-Host "True"
#}
#if ([boolean]$VMDvdDriveStatus -match 'FALSE') {
#Write-Host "False"
#}

