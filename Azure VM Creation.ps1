#param($vmName,$location,$OS,$vmsize)


function AzureVMspin{
#WarningAction
$WarningPreference='silentlycontinue'

#Azure RM Login
#$usernameRM = 
#$passwordRM = 
#$secstrRM = New-Object -TypeName System.Security.SecureString
#$passwordRM.ToCharArray() | ForEach-Object {$secstrRM.AppendChar($_)}
#$credRM = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameRM, $secstrRM
#$LoginInfo = Login-AzureRmAccount -Credential $credRM

# Variables for common values
$resourceGroup = "TestResourceGroup"
$location = "East Asia"
$vmName = "TestVM1"
$subnetname = "testvmSubnet"
$vnetname = "testvmvNET"
$vmsize = "Standard_D1"
$OS = "Windows Server 2016"

#OS Decision
$Publisher = switch ( $OS )
    {
        "Windows Server 2012 R2" { 'MicrosoftWindowsServer'}
        "Windows Server 2016" { 'MicrosoftWindowsServer'}
    }

$Offer = switch ( $OS )
    {
        "Windows Server 2012 R2" { 'WindowsServer'}
        "Windows Server 2016" { 'WindowsServer'}
    }

$Sku = switch ( $OS )
    {
        "Windows Server 2012 R2" { '2012-R2-Datacenter'}
        "Windows Server 2016" { '2016-Datacenter'}
    }

# Create user object
$username = "pstestuser"
$password = "Newuser@123" 
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
#$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create a resource group
$Resourcegroupinfo = New-AzureRmResourceGroup -Name $resourceGroup -Location $location

# Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
  -Name $vnetname -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "mypublicdns$(Get-Random)" -AllocationMethod dynamic -IdleTimeoutInMinutes 4

$PublicIP = $pip.Id

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleRDP  -Protocol Tcp `
  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 3389 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
  -Name myNetworkSecurityGroup -SecurityRules $nsgRuleRDP

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name myNic -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmsize | `
Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName $Publisher -Offer $Offer -Skus $Sku -Version latest | `
Add-AzureRmVMNetworkInterface -Id $nic.Id

# Create a virtual machine
$NewVMinfo = New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

write-host "The VM $vmName have been successully provisioned as per the request`nThe details are as follows,`nHostname = $vmName`nDynamic Pubilc IP = $PublicIP`nOS = $OS`nRegion = $location`nThe Login details will be sent on a seperate mail"

#For Cleanup
#Remove-AzureRmResourceGroup -Name $resourceGroup
}
AzureVMspin
