param(
    [string]$guid,
    [string]$DnsZoneName = 'test.zone'
)
# DNS zone to be created inside $DnsZoneName
Write-Output $DnsZoneName
$DnsZoneName = 'test.zone'
$guidDNSZoneName = $guid + "." + $DnsZoneName
# for stand-alone DNS server
$guidDNSZoneFile = $boxZone + ".dns"


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

## Get info from Azure and register in onprem DNS
$DnsRecords = read-Azure-records($guid)

# create DNS zone for the environment
Add-DnsServerPrimaryZone -Name $guidDNSZoneName -zonefile $guidDNSZoneFile

foreach ($DnsRecord in $DnsRecords){
    Add-DnsServerResourceRecordA -ZoneName $guidDNSZoneName -Name $DnsRecord.vm -IPv4Address $DnsRecord.IP -computername localhost -CreatePtr   
}
# list created records
Get-DnsServerResourceRecord -ZoneName $guidDNSZoneName -RRType A
