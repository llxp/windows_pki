define windows_pki::dns_record (
  String $record_name = $title,
  String $ipv4_address = '',
  String $dns_server = '',
  String $zone_name = ''
) {

  notify { "dns_entry_${record_name}": }

  exec { "add_dns_entry_${record_name}":
    command => "Add-DNSServerResourceRecordA -ZoneName ${zone_name} -Name ${record_name} -IPv4Address ${ipv4_address} -ComputerName ${dns_server}",
    unless => "(Get-DnsServerResourceRecord -ComputerName ${dns_server} -ZoneName ${zone_name} -RRType A -Name ${record_name}).RecordData.IPv4Address.IPAddressToString -eq \"${ipv4_address}\"",
    provider => 'powershell',
    logoutput => true
  }

  Notify["dns_entry_${record_name}"]
  -> Exec["add_dns_entry_${record_name}"]

}
