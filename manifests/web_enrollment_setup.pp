class windows_pki::web_enrollment_setup {

  dsc_adcswebenrollment { 'ConfigWebEnrollment':
    dsc_ensure => 'present',
    name => 'ConfigWebEnrollment',
    dsc_credential => {
        user => $windows_pki::ca_username,
        password => $windows_pki::ca_password
    },
    dsc_issingleinstance => 'Yes'
  }
  
}
