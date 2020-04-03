class windows_pki::cdp_share (
  String $cert_path = 'C:\\Windows\\System32\\certsrv\\CertEnroll'
) {

  fileshare { 'CertEnroll':
    ensure  => present,
    path    => $cert_path
  }

  class { 'windows_pki::cdp_config':
    cert_path => $cert_path
  }

  Class['windows_pki::cdp_config']
  -> Fileshare['CertEnroll']

}
