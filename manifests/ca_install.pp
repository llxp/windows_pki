class windows_pki::ca_install {

  notify { 'installing the active directory certificate authority roles': }

  windowsfeature {'RSAT-DNS-Server':
    ensure => 'present'
  }

  windowsfeature {'ADCS-Cert-Authority':
    ensure => 'present'
  }

  #reboot {'after_ADCS-Cert-Authority':
  #  when  => pending,
  #  subscribe => Windowsfeature['ADCS-Cert-Authority']
  #}

  Windowsfeature['RSAT-DNS-Server']
  -> Windowsfeature['ADCS-Cert-Authority']

}
