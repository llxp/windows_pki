class windows_pki::config {

  $cert_path = 'C:\\Windows\\System32\\certsrv\\CertEnroll'

  Class { 'windows_pki::cdp_config':
    cert_path => $cert_path
  }
  contain 'windows_pki::iis_config'

  if $windows_pki::sub_ca_list.size() > 0 {

    contain 'windows_pki::ca_config'
    contain 'windows_pki::wait_for_ca_list'

    Class['windows_pki::cdp_config']
    -> Class['windows_pki::iis_config']
    -> Class['windows_pki::ca_config']
    -> Class['windows_pki::wait_for_ca_list']

  } else {

    contain 'windows_pki::ca_config'

    Class['windows_pki::cdp_config']
    -> Class['windows_pki::iis_config']
    -> Class['windows_pki::ca_config']

  }

}
