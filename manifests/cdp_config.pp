class windows_pki::cdp_config (
  String $cert_path = ''
) {

  iis_feature { 'Web-WebServer':
    ensure => 'present'
  }

  windowsfeature { 'Web-Mgmt-Service':
    ensure => 'present'
  }

  notify { $cert_path: message => '' }

  file { "${cert_path}":
    ensure => 'directory'
  }

  file { "c:\\inetpub":
    ensure => 'directory'
  }

  # Set Permissions

  acl { $cert_path:
    permissions => [
      {'identity' => 'IIS_IUSRS', 'rights' => ['read', 'write', 'execute']},
      {'identity' => 'Cert Publishers', 'rights' => ['read', 'write', 'execute']}
    ]
  }

  # Configure IIS

  iis_site {'Default Web Site':
    ensure  => absent,
    require => Iis_feature['Web-WebServer'],
  }

  iis_site { 'cdp':
    ensure           => 'started',
    physicalpath     => 'c:\\inetpub',
    applicationpool  => 'DefaultAppPool',
    enabledprotocols => 'http',
    bindings         => [
      {
        'bindinginformation'   => '*:80:',
        'protocol'             => 'http',
      }
    ],
    require => File['c:\\inetpub']
  }

  iis_virtual_directory { 'CertEnroll':
    ensure       => 'present',
    sitename     => 'cdp',
    physicalpath => $cert_path,
    require      => File[$cert_path],
  }

  exec { 'enable_directory_browsing':
    command => "Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath 'IIS:\\Sites\\cdp\\CertEnroll' -Value True",
    provider => 'powershell',
    logoutput => true
  }

  exec { 'set_mimetype_for_req_files':
    command => " \
      if ( -not ((Get-WebConfigurationProperty -Filter \"//staticContent/mimeMap\" -PSPath \"IIS:\\\" -Name \"*\").fileExtension -contains \".req\")) { \
        Add-WebConfigurationProperty -PSPath IIS:\\ -Filter \"//staticContent\" -Name \".\" -Value @{fileExtension='.req';mimeType='application/pkcs10'} \
      } \
    ",
    onlyif => " \
      if ( -not ((Get-WebConfigurationProperty -Filter \"//staticContent/mimeMap\" -PSPath \"IIS:\\Sites\\cdp\\CertEnroll\" -Name \"*\").fileExtension -contains \".req\")) { \
        exit 0; \
      } else { \
        exit 1; \
      } \
    ",
    provider => 'powershell',
    logoutput => true
  }

  exec { 'set_mimetype_for_crt_files':
    command => " \
      if ( -not ((Get-WebConfigurationProperty -Filter \"//staticContent/mimeMap\" -PSPath \"IIS:\\\" -Name \"*\").fileExtension -contains \".crt\")) { \
        Add-WebConfigurationProperty -PSPath IIS:\\ -Filter \"//staticContent\" -Name \".\" -Value @{fileExtension='.crt';mimeType='application/pkcs10'} \
      } \
    ",
    onlyif => " \
      if ( -not ((Get-WebConfigurationProperty -Filter \"//staticContent/mimeMap\" -PSPath \"IIS:\\Sites\\cdp\\CertEnroll\" -Name \"*\").fileExtension -contains \".crt\")) { \
        exit 0; \
      } else { \
        exit 1; \
      } \
    ",
    provider => 'powershell',
    logoutput => true
  }

  exec { 'set_mimetype_for_crl_files':
    command => " \
      if ( -not ((Get-WebConfigurationProperty -Filter \"//staticContent/mimeMap\" -PSPath \"IIS:\\\" -Name \"*\").fileExtension -contains \".crl\")) { \
        Add-WebConfigurationProperty -PSPath IIS:\\ -Filter \"//staticContent\" -Name \".\" -Value @{fileExtension='.crl';mimeType='application/pkcs10'} \
      } \
    ",
    onlyif => " \
      if ( -not ((Get-WebConfigurationProperty -Filter \"//staticContent/mimeMap\" -PSPath \"IIS:\\Sites\\cdp\\CertEnroll\" -Name \"*\").fileExtension -contains \".crl\")) { \
        exit 0; \
      } else { \
        exit 1; \
      } \
    ",
    provider => 'powershell',
    logoutput => true
  }

  exec { 'stop_iis':
    command => 'iisreset /STOP',
    provider => 'powershell',
    logoutput => true
  }

  exec { 'start_iis':
    command => 'iisreset /START',
    provider => 'powershell',
    logoutput => true
  }

  Iis_feature['Web-WebServer']
  -> Windowsfeature['Web-Mgmt-Service']
  -> Notify[$cert_path]
  -> File["c:\\inetpub"]
  -> Acl[$cert_path]
  -> Iis_site['Default Web Site']
  -> Iis_site['cdp']
  -> Iis_virtual_directory['CertEnroll']
  -> Exec['enable_directory_browsing']
  -> Exec['set_mimetype_for_req_files']
  -> Exec['set_mimetype_for_crt_files']
  -> Exec['set_mimetype_for_crl_files']
  -> Exec['stop_iis']
  -> Exec['start_iis']

}
