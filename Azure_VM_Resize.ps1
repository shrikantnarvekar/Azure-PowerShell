param($resourceGroup,$vmName,$vmsize)
function AzResize($resourceGroup,$vmName,$vmsize){
$usernameRM = "YourAzureAccountEmail"
$passwordRM = 'Azurepassword' 
$secstrRM = New-Object -TypeName System.Security.SecureString
$passwordRM.ToCharArray() | ForEach-Object {$secstrRM.AppendChar($_)}
$credRM = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameRM, $secstrRM
$LoginInfo = Connect-AzAccount -Credential $credRM

$vm = Get-AzVM -ResourceGroupName $resourceGroup -VMName $vmName
$vm.HardwareProfile.VmSize = $vmsize
$Result=Update-AzVM -VM $vm -ResourceGroupName $resourceGroup -InformationAction SilentlyContinue
if($Result.IsSuccessStatusCode -eq $true){
    Write-Host "VM $vmName is successfully resized to $vmsize"
}

}
AzResize "$resourceGroup" "$vmName" "$vmsize"

