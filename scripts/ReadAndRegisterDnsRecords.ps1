param(
    [string]$guid,
    [string]$DnsZoneName = 'test.zone'
)

$guidDNSZoneName = $guid + "." + $DnsZoneName

# Auth to Azure
#Install-Module Az
#Connect-AzAccount -DeviceCode
#Get-AzContext

# file is required for stand-alone DNS server, not AD integrated
$guidDNSZoneFile = $guid + ".dns"
$rg = $guid + '.rg'
$VmPublicIpAddress = @{}   
$pend = Get-AzPrivateEndpoint -ResourceGroupName $rg
$nicIds = $pend.NetworkInterfaces.id
ForEach ($nicId in $nicIds){
  $nic = Get-AzNetworkInterface -ResourceId $nicId
  $VmPublicIpAddress.Add($nic.Tag.vm,$nic.IpConfigurations.PrivateIPAddress) 
  }
Write-Output 'DNS Records to be created:'
Write-Output $VmPublicIpAddress

# Get DNS Zones in local DNS Server
$Zones = Get-DnsServerZone
$ZoneNames = $Zones.ZoneName
if ($ZoneNames.Contains($guidDNSZoneName) -eq $false){
  Write-Output 'Creating DNS Zone'
  Add-DnsServerPrimaryZone -Name $guidDNSZoneName -zonefile $guidDNSZoneFile
  Write-Output 'Creating DNS Records'
  $VmPublicIpAddress.keys | ForEach-Object{
    Add-DnsServerResourceRecordA -ZoneName $guidDNSZoneName -Name $_ -IPv4Address $VmPublicIpAddress[$_] -computername localhost -CreatePtr
    }
  }
else {
  Write-Output "Zone $guidDNSZoneName exists. Zone and records will not be created"    
  }

Start-Sleep -s 10
Write-Output 'Listing DNS records in zone Type:A'
Get-DnsServerResourceRecord -ZoneName $guidDNSZoneName -RRType A | format-Table
