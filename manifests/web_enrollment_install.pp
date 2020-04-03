class windows_pki::web_enrollment_install {

  notify { 'install_adcs_web_enrollment_roles': message => 'installing the active directory certificate authority web enrollment roles' }

  windowsfeature {'ADCS-Web-Enrollment':
    ensure => 'present',
  }

  reboot {'after_ADCS-Web-Enrollment':
    when  => pending,
    subscribe => Windowsfeature['ADCS-Web-Enrollment']
  }

  Notify['install_adcs_web_enrollment_roles']
  -> Windowsfeature['ADCS-Web-Enrollment']
  -> Reboot['after_ADCS-Web-Enrollment']

}
