class windows_pki::ca_setup {
  
  if $windows_pki::ca_type == 'StandaloneRootCA' or $windows_pki::ca_type == 'EnterpriseRootCa' {

    contain 'windows_pki::ca_setup_root_ca'

  } else {

    contain 'windows_pki::ca_setup_sub_ca'

    reboot {'after_ca_setup_sub_ca':
      when  => pending,
      subscribe => Class['windows_pki::ca_setup_sub_ca']
    }

    Class['windows_pki::ca_setup_sub_ca']
    -> Reboot['after_ca_setup_sub_ca']

  }

}
