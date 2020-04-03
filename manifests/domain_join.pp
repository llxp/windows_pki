class windows_pki::domain_join (
  String $domain_fqdn = '',
  String $domain_username = '',
  Sensitive $domain_password = Sensitive(''),
  Integer $ldap_port = 389
) {

  notify { 'waiting for the active directory domain to be available': }

  #dsc_xwaitforaddomain { 'waitforadddomain':
  #  dsc_domainname => $domain_fqdn,
  #  dsc_domainusercredential => {
  #    user => $domain_username,
  #    password => $domain_password
  #  },
  #  dsc_retrycount => 200,
  #  dsc_retryintervalsec => 10
  #}

  tcp_conn_validator { "waitforadddomain":
    host => $domain_fqdn,
    port => $ldap_port
  }

  notify { 'joining the computer to active directory': }

  $code = " \
    \$secStr=ConvertTo-SecureString '${domain_password.unwrap}' -AsPlainText -Force; \
    if (-not \$?) { \
      write-error 'Error: Unable to convert password string to a secure string'; \
      exit 10; \
    } \
    \$creds=New-Object System.Management.Automation.PSCredential( '${domain_username}', \$secStr ); \
    if (-not \$?) { \
      write-error 'Error: Unable to create PSCredential object'; \
      exit 20; \
    } \
    Add-Computer -DomainName ${domain_fqdn} -Restart -Force -Cred \$creds; \
    if (-not \$?) { \
      write-error 'Error: Unable to join domain'; \
      exit 30; \
    } \
    exit 0 \
  "

  #
  # Use the Josh Cooper PowerShell provider
  #
  exec { 'execute_domain_join':
    command => $code,
    provider => powershell,
    logoutput => true,
    unless => "if ((Get-WMIObject Win32_ComputerSystem).Domain -ne '${domain_fqdn}') { exit 1 }",
  }

  #class { 'domain_membership':
  #  domain       => $domain_fqdn,
  #  username     => $domain_username,
  #  password     => $domain_password.unwrap,
  #  join_options => '3',
  #}

  #Dsc_xwaitforaddomain['waitforadddomain']
  #-> Dsc_xadcomputer['join_domain']
  #-> Class['domain_membership']
  Tcp_conn_validator['waitforadddomain']
  -> Exec['execute_domain_join']

}
