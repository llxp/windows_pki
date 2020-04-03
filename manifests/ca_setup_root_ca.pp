class windows_pki::ca_setup_root_ca {

  file { 'C:\Windows\CAPolicy.inf':
    content => "[Version]\r\n Signature= \"\$Windows NT\$\"\r\n[Certsrv_Server]\r\n RenewalKeyLength=${windows_pki::ca_renewal_key_length}\r\n RenewalValidityPeriod=Years\r\n RenewalValidityPeriodUnits=20\r\n CRLDeltaPeriod=Days\r\n CRLDeltaPeriodUnits=0\r\n[CRLDistributionPoint]\r\n[AuthorityInformationAccess]\r\n",
    ensure => 'file'
  }

  dsc_adcscertificationauthority { 'config_ca':
    dsc_ensure => 'present',
    dsc_credential => {
       user => $windows_pki::ca_username,
        password => $windows_pki::ca_password
    },
    dsc_catype => $windows_pki::ca_type,
    dsc_cacommonname => $windows_pki::ca_common_name,
    dsc_cadistinguishednamesuffix => $windows_pki::ca_suffix,
    dsc_validityperiod => 'Months',
    dsc_validityperiodunits => $windows_pki::ca_validity_period,
    dsc_issingleinstance => 'Yes'
  }

  notify {'root_ca_installed': message => 'Root CA has been installed' }

  File['C:\\Windows\\CAPolicy.inf']
  -> Dsc_adcscertificationauthority['config_ca']
  -> Notify['root_ca_installed']

}
