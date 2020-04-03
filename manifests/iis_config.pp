class windows_pki::iis_config {

  notify { 'enable iis remote management': }

  registry_value { 'EnableRemoteManagement':
    path => 'HKLM\\Software\\Microsoft\\WebManagement\\Server\\EnableRemoteManagement',
    ensure => 'present',
    type => dword,
    data => '00000001'
  }
  ~> service { 'WMSVC':
    ensure => 'running',
    enable => true
  }

}
