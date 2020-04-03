class windows_pki::install {

  if $windows_pki::should_join_domain {
    class { 'windows_pki::domain_join':
      domain_fqdn => $windows_pki::domain_name,
      domain_username => $windows_pki::ca_username,
      domain_password => $windows_pki::ca_password,
      ldap_port => $windows_pki::ldap_port
    }
  }

  contain 'windows_pki::ca_install'
  contain 'windows_pki::web_enrollment_install'
  contain 'windows_pki::ca_setup'
  contain 'windows_pki::web_enrollment_setup'

  if $windows_pki::should_join_domain {
    Class['windows_pki::domain_join']
    -> Class['windows_pki::ca_install']
    -> Class['windows_pki::web_enrollment_install']
    -> Class['windows_pki::ca_setup']
    -> Class['windows_pki::web_enrollment_setup']
  } else {
    Class['windows_pki::ca_install']
    -> Class['windows_pki::web_enrollment_install']
    -> Class['windows_pki::ca_setup']
    -> Class['windows_pki::web_enrollment_setup']
  }

}
