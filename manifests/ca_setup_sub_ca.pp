class windows_pki::ca_setup_sub_ca {

  file { "C:\\Windows\\CAPolicy.inf":
    content => "[Version]\r\n Signature= \"\$Windows NT\$\"\r\n[Certsrv_Server]\r\n RenewalKeyLength=4096\r\n RenewalValidityPeriod=Years\r\n RenewalValidityPeriodUnits=10\r\n AlternateSignatureAlgorithm=1\r\n CNGHashAlgorithm=SHA256\r\n LoadDefaultTemplates=0\r\n",
    ensure => 'file'
  }

  file { 'C:\\Windows\\System32\\CertSrv\\CertEnroll':
    ensure => 'directory'
  }

  notify { "wait_for_url: http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt": }

  windows_pki::http_waiter { "waiting for url: http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca_fqdn}_${windows_pki::parent_ca_common_name}.crt":
    url => "http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt",
    timeout => 360,
  }

  notify { "create_file: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt": }

  file { "C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt":
    source => "http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt",
    ensure => 'file'
  }

  windows_pki::http_waiter { "waiting for url: http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca_common_name}.crl":
    url => "http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca_common_name}.crl",
    timeout => 360
  }

  notify { "create file: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl": }

  file { "C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl":
    source => "http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca_common_name}.crl",
    ensure => 'file'
  }

  notify { "register_root_ca_certificate_crt: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt": }

  exec { 'register_root_ca_certificate_crt':
    command => "certutil.exe -f -dspublish \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt\"",
    onlyif => "if ((Get-ChildItem -Path Cert:\\LocalMachine\\Root | Where-Object -FilterScript { (\$_.Subject -Like \"CN=${windows_pki::parent_ca_common_name},*\") -and (\$_.Issuer -Like \"CN=${windows_pki::parent_ca_common_name},*\") } ).Count -eq 0) { return 0; } else { return 1; }",
    provider => 'powershell',
    logoutput => true
  }

  notify { "register_root_ca_certificate_crl: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl": }

  exec { 'register_root_ca_certificate_crl':
    command => "certutil.exe -f -dspublish \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl\"",
    onlyif => "if ((Get-ChildItem -Path Cert:\\LocalMachine\\Root | Where-Object -FilterScript { (\$_.Subject -Like \"CN=${windows_pki::parent_ca_common_name},*\") -and (\$_.Issuer -Like \"CN=${windows_pki::parent_ca_common_name},*\") } ).Count -eq 0) { return 0; } else { return 1; }",
    provider => 'powershell',
    logoutput => true
  }

  notify { "install_root_ca_certificate_crt: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt": }

  exec { 'install_root_ca_certificate_crt':
    command => "certutil.exe -addstore -f root \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt\"",
    onlyif => "if ((Get-ChildItem -Path Cert:\\LocalMachine\\Root | Where-Object -FilterScript { (\$_.Subject -Like \"CN=${windows_pki::parent_ca_common_name},*\") -and (\$_.Issuer -Like \"CN=${windows_pki::parent_ca_common_name},*\") } ).Count -eq 0) { return 0; } else { return 1; }",
    provider => 'powershell',
    logoutput => true
  }

  notify { "install_root_ca_certificate_crl: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl": }

  exec { 'install_root_ca_certificate_crl':
    command => "certutil.exe -addstore -f root \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl\"",
    onlyif => "if ((Get-ChildItem -Path Cert:\\LocalMachine\\Root | Where-Object -FilterScript { (\$_.Subject -Like \"CN=${windows_pki::parent_ca_common_name},*\") -and (\$_.Issuer -Like \"CN=${windows_pki::parent_ca_common_name},*\") } ).Count -eq 0) { return 0; } else { return 1; }",
    provider => 'powershell',
    logoutput => true
  }

  notify { "config_ca: ${windows_pki::ca_common_name}": message => "${$windows_pki::parent_ca}, ${windows_pki::ca_type}, ${windows_pki::ca_suffix}, ${windows_pki::ca_validity_period}" }

  pspackageprovider {'Nuget':
    ensure   => 'present',
    provider => 'windowspowershell',
  }

  psrepository { 'PSGallery':
    ensure              => present,
    source_location     => 'https://www.powershellgallery.com/api/v2/',
    installation_policy => 'trusted',
  }

  package { 'ActiveDirectoryCSDsc':
    ensure   => latest,
    provider => 'windowspowershell',
    source   => 'PSGallery',
  }

  package { 'xPSDesiredStateConfiguration':
    ensure   => latest,
    provider => 'windowspowershell',
    source   => 'PSGallery',
  }

  package { 'xADCSDeployment':
    ensure   => latest,
    provider => 'windowspowershell',
    source   => 'PSGallery',
  }

  dsc_adcscertificationauthority { 'config_ca':
    dsc_ensure => 'present',
    dsc_credential => {
      user => $windows_pki::ca_username,
      password => $windows_pki::ca_password
    },
    #dsc_parentca => $windows_pki::parent_ca_fqdn,
    dsc_catype => $windows_pki::ca_type,
    dsc_cacommonname => $windows_pki::ca_common_name,
    dsc_cadistinguishednamesuffix => $windows_pki::ca_suffix,
    dsc_issingleinstance => 'Yes',
    dsc_outputcertrequestfile => "C:\\Windows\\System32\\CertSrv\\CertEnroll\\${facts['networking']['fqdn']}.req",
    dsc_psdscrunascredential => {
      user => $windows_pki::ca_username,
      password => $windows_pki::ca_password
    }
  }

  windows_pki::http_waiter { "waiting for url: http://${windows_pki::parent_ca_fqdn}/CertEnroll/${facts['networking']['fqdn']}.crt":
    url => "http://${windows_pki::parent_ca_fqdn}/CertEnroll/${facts['networking']['fqdn']}.crt",
    timeout => 360
  }

  file { "C:\\Windows\\System32\\CertSrv\\CertEnroll\\${facts['networking']['fqdn']}.crt":
    source => "http://${windows_pki::parent_ca_fqdn}/CertEnroll/${facts['networking']['fqdn']}.crt",
    ensure => 'file'
  }

  exec { 'register_sub_ca':
    onlyif => "If (-not (Get-ChildItem \"HKLM:\\System\\CurrentControlSet\\Services\\CertSvc\\Configuration\").GetValue(\"CACertHash\")) { exit 0; } else { exit 1; }",
    command => "certutil.exe -installCert \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${facts['networking']['fqdn']}.crt\"",
    provider => "powershell",
    logoutput => true
  }

  File["C:\\Windows\\CAPolicy.inf"]
  -> File['C:\\Windows\\System32\\CertSrv\\CertEnroll']
  -> Notify["wait_for_url: http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt"]
  -> Windows_pki::Http_waiter["waiting for url: http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt"]
  -> Notify["create_file: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt"]
  -> File["C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt"]
  -> Windows_pki::Http_waiter["waiting for url: http://${windows_pki::parent_ca_fqdn}/CertEnroll/${windows_pki::parent_ca_common_name}.crl"]
  -> Notify["create file: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl"]
  -> File["C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl"]
  -> Notify["register_root_ca_certificate_crt: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt"]
  -> Exec['register_root_ca_certificate_crt']
  -> Notify["register_root_ca_certificate_crl: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl"]
  -> Exec['register_root_ca_certificate_crl']
  -> Notify["install_root_ca_certificate_crt: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca}_${windows_pki::parent_ca_common_name}.crt"]
  -> Exec['install_root_ca_certificate_crt']
  -> Notify["install_root_ca_certificate_crl: C:\\Windows\\System32\\CertSrv\\CertEnroll\\${windows_pki::parent_ca_common_name}.crl"]
  -> Exec['install_root_ca_certificate_crl']
  -> Notify["config_ca: ${windows_pki::ca_common_name}"]
  -> Dsc_adcscertificationauthority['config_ca']
  -> Exec['register_sub_ca']

}
