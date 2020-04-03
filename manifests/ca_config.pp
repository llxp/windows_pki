class windows_pki::ca_config inherits windows_pki::crl_params {

  notify { 'registry_key_set_ca_dsconfigdn': message => "HKLM\\SYSTEM\\CurrentControlSet\\Services\\CertSvc\\Configuration\\${windows_pki::ca_common_name}\\DSConfigDN"}

  registry_value { 'set_ca_dsconfigdn':
    path => "HKLM\\SYSTEM\\CurrentControlSet\\Services\\CertSvc\\Configuration\\${windows_pki::ca_common_name}\\DSConfigDN",
    ensure => 'present',
    type => 'string',
    data => "CN=Configuration,${windows_pki::ca_suffix}"
  }

  registry_value { 'set_ca_dsdomaindn':
    path => "HKLM\\SYSTEM\\CurrentControlSet\\Services\\CertSvc\\Configuration\\${windows_pki::ca_common_name}\\DSDomainDN",
    ensure => 'present',
    type => 'string',
    data => "${windows_pki::ca_suffix}"
  }

  registry_value { 'set_ca_crl_publication_urls':
    path => "HKLM\\SYSTEM\\CurrentControlSet\\Services\\CertSvc\\Configuration\\${windows_pki::ca_common_name}\\CRLPublicationURLs",
    ensure => 'present',
    type => array,
    data => any2array($crl_urls)
  }

  registry_value { 'set_ca_cert_publication_urls':
    path => "HKLM\\SYSTEM\\CurrentControlSet\\Services\\CertSvc\\Configuration\\${windows_pki::ca_common_name}\\CACertPublicationURLs",
    ensure => 'present',
    type => 'array',
    data => any2array($ca_urls)
  }

  registry_value { 'set_ca_crl_period':
    path => "HKLM\\SYSTEM\\CurrentControlSet\\Services\\CertSvc\\Configuration\\${windows_pki::ca_common_name}\\CACRLPeriod",
    ensure => 'present',
    type => 'string',
    data => "Weeks"
  }

  registry_value { 'set_ca_crl_period_units':
    path => "HKLM\\SYSTEM\\CurrentControlSet\\Services\\CertSvc\\Configuration\\${windows_pki::ca_common_name}\\CACRLPeriodUnits",
    ensure => 'present',
    type => 'dword',
    data => "${windows_pki::ca_crl_period}"
  }

  service { 'CertSVC':
    ensure => 'running',
    enable => true
  }

  Registry_value['set_ca_dsconfigdn']
  -> Registry_value['set_ca_dsdomaindn']
  -> Registry_value['set_ca_crl_publication_urls']
  -> Registry_value['set_ca_cert_publication_urls']
  -> Registry_value['set_ca_crl_period']
  -> Registry_value['set_ca_crl_period_units']
  ~> Service['CertSVC']

}
