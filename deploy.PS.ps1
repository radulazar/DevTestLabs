Connect-AzAccount
Get-AzContext
Get-AzSubscription

# where endpoints are created. Each VM receive a NAT-ed IP in this subnet  
$endpointVirtualNetwork = "OnPremConnect-vNet"
$endpointVirtualNetworkSubnet = "192.168.1.0_24"
$subnetId = (Get-AzVirtualNetwork -name $endpointVirtualNetwork | Get-AzVirtualNetworkSubnetConfig -name $endpointVirtualNetworkSubnet).Id

$imageGallery = "BoxImages" 
$location = "West Europe"
$vmfile = ".\vmlist.csv"

# BUILD LAB

# create Resource Group and guid to identify the lab. output: rgName and guid
$rgDeployResult = New-AzSubscriptionDeployment -Location $location -TemplateFile .\arm\rg.json

$rg = $rgDeployResult.Outputs.rgname.Value
$guid = $rgDeployResult.Outputs.guid.Value

# Create Virtual Network
New-AzResourceGroupDeployment -ResourceGroupName $rg -guid $guid -TemplateFile .\arm\virtualnetwork.json

$VMs = Import-Csv $vmfile -Delimiter ","

foreach ($vm in $VMs) {

    # Create VM
    New-AzResourceGroupDeployment -ResourceGroupName $rg -guid $guid -vmName $vm.Name -vmIndex $vm.Index -imageGallery $imageGallery -TemplateFile .\arm\vm.json

    # Create Private Endpoint in existing vnet. 
    # Note: Private Endpoint Network Policies must be disabled for that vnet. You can create a Private Endpoint in the portal to auto-disable the policy
    New-AzResourceGroupDeployment -ResourceGroupName $rg -guid $guid -vmName $vm.Name -vmIndex $vm.Index -subnetId $subnetId -TemplateFile .\arm\privatelink.json

}




