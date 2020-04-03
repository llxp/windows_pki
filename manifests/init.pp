# == Class: windows_pki
#
# Installs, configures and manages a windows based public key infrastructure
#
# === Parameters
#
# [*ca_type*]
#   The type of certificate authority to install and configure
#
# [*parent_ca*]
#   Hash of consul_token resources to create.
class windows_pki(
  Enum['StandaloneRootCA', 'EnterpriseRootCA', 'StandaloneSubordinateCA', 'EnterpriseSubordinateCA'] $ca_type = 'RootCA',
  String $parent_ca = '',
  String $parent_ca_fqdn = '',
  String $parent_ca_common_name = '',
  String $ca_common_name = '',
  String $ca_suffix = '',
  Integer $ca_validity_period = 240, # Month
  String $local_username = '',
  Sensitive $local_password = Sensitive(''),
  String $domain_username = '',
  Sensitive $domain_password = Sensitive(''),
  String $domain_name = '',
  Integer $ca_crl_period = 6,
  String $cdp_server = '',
  Array[String] $cdp_shares = [],
  Integer $ca_renewal_key_length = 4096,
  Array[Struct[{name => String, fqdn => String, common_name => String}]] $sub_ca_list = [],
  Boolean $join_domain = false,
  Boolean $publish_delta_clrs = true,
  Integer $ldap_port = 389
) {

  $ca_username = $ca_type ? {
    'StandaloneRootCA' => $local_username,
    'EnterpriseRootCA' => $domain_username,
    'StandaloneSubordinateCA' => $local_username,
    'EnterpriseSubordinateCA' => $domain_username,
    default => '.\Administrator'
  }	
  $ca_password = $ca_type ? {
    'StandaloneRootCA' => $local_password,
    'EnterpriseRootCA' => $domain_password,
    'StandaloneSubordinateCA' => $local_password,
    'EnterpriseSubordinateCA' => $domain_password,
    default => Sensitive('Start123')
  }
  $should_join_domain = $ca_type ? {
    'StandaloneRootCA' => $join_domain,
    'EnterpriseRootCA' => true,
    'StandaloneSubordinateCA' => $join_domain,
    'EnterpriseSubordinateCA' => true,
    default => false
  }

  contain 'windows_pki::install'
  contain 'windows_pki::config'

  Class['windows_pki::install']
  -> Class['windows_pki::config']
}
