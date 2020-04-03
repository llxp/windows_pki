# == Class: windows_pki
#
# Installs, configures and manages a windows based public key infrastructure
#
# === Parameters
#
# [*ca_type*]
#   The type of certificate authorition to install and configure
#
# [*parent_ca*]
#  The name of the parent certification authority if the parent ca type is either StandaloneSubordinateCA or EnterpriseSubordinateCA
#
# [*parent_ca_fqdn*]
#  The fully quallified domain name of the parent certification authority if the parent ca type is either StandaloneSubordinateCA or EnterpriseSubordinateCA
#
# [*parent_ca_common_name*]
#  The common name of the parent certification authority if the parent ca type is either StandaloneSubordinateCA or EnterpriseSubordinateCA
#
# [*ca_suffix*]
#  the ca suffix of the certification authority e.g. "DC=domain,DC=local"
#
# [*ca_validity_period*]
#  the validity period of the certification autority in month
#
# [*local_username*]
#  the local admin username to install a standalone certification authority
#
# [*local_password*]
#  the local admin password to install a standalone certification authority
#
# [*domain_username*]
#  the domain admin username to install a enterprise certification authority or to join a standalone certification autority to the domain
#
# [*domain_password*]
#  the domain admin password to install a enterprise certification authority or to join a standalone certification autority to the domain
#
# [*domain_name*]
#  the fully quallified domain name of the active directory domain to join the server to the domain or to install an enterprise certification authority
#
# [*ca_crl_period*]
#  The period, in which the crl should be publishd by the certification autority
#
# [*cdp_server*]
#  The cdp dns record, where the crl and aia will be reachable from e.g. pki.domain.local
#
# [*cdp_shares*]
#  A list of fully quallified domain names to where the pki will be publishing the crl and aia, a share with the name CertEnroll needs to exist and the 'Cert Publishers' group need to have access to it
#
# [*ca_renewal_key_length*]
#  The keylength of the certification authority's issued certificates
#
# [*sub_ca_list*]
#  A list of structs to specify the subordinate cas to wait for after installing a root ca, currently only supported on a root certification authority type
#
# [*join_domain*]
#  A parameter to indicate and to override, if a standalone certification authority should be joined to the domain
#
# [*publish_delta_clrs*]
#  A parameter to indicate, if the delta crls should be published
#
# [*ldap_port*]
#  The port to perform the tcp healthcheck against, to check if the domain controller is already available, defaults to port 389 for ldap and to 636 for ldaps
#
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
