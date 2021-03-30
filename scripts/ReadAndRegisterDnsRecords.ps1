param(
    [string]$guid,
    [string]$DnsZoneName = 'test.zone'
)

# Auth to Azure
#Install-Module Az
#Connect-AzAccount -DeviceCode
#Get-AzContext


function read-Azure-records{

param([string] $guid)

$pendp_Resources = Get-AzResource -Tag @{ "env" = $guid} -ResourceType "Microsoft.Network/privateEndpoints" 

# array of hashtables with vm & IP information to be added to DNS, one hastable object per DNS record
$arrayDnsRecords = @()

foreach ($pendp_Resource in $pendp_Resources){
    $pendp_Nic = (Get-AzPrivateEndpoint -Name $pendp_Resource.Name).NetworkInterfaces[0]
    $nicObj = Get-AzNetworkInterface -ResourceId $pendp_Nic.Id
    $arrayDnsRecords +=(@{"vm" = $nicObj.Tag.vm; "IP" = $nicObj.IpConfigurations[0].PrivateIpAddress})
    }
return $arrayDnsRecords
}


$DnsRecords = read-Azure-records($guid)

foreach ($DnsRecord in $DnsRecords){
    $ARecord = $DnsRecord.vm + "." + $guid
    Add-DnsServerResourceRecordA -ZoneName $ZoneName -Name $ARecord -IPv4Address $DnsRecord.IP -computername localhost -CreatePtr
    #Get-DnsServerResourceRecord -ZoneName $ZoneName | fl hostname
}

Get-DnsServerZone