class windows_pki::wait_for_ca_list {

  notify { 'wait_for_sub_ca_list': message => 'waiting for sub ca list' }
 
  $windows_pki::sub_ca_list.each |$sub_ca| {

    notify { "wait_for_${sub_ca['name']}": message => "waiting for sub ca ${sub_ca['fqdn']}" }

    #dsc_waitforcertificateservices { "wait_for_sub_ca_${sub_ca['name']}":
    #  dsc_retrycount => 2,
    #  dsc_carootname => $sub_ca['name'],
    #  dsc_retryintervalseconds => 10,
    #  dsc_caserverfqdn => $sub_ca['fqdn'],
    #  dsc_psdscrunascredential => {
    #    user => $windows_pki::domain_username,
    #    password => $windows_pki::domain_password
    #  }
    #}

    windows_pki::http_waiter { "waiting_for_url: http://${sub_ca['fqdn']}/CertEnroll/${sub_ca['fqdn']}.req":
      url => "http://${sub_ca['fqdn']}/CertEnroll/${sub_ca['fqdn']}.req",
      onlyif => "if (Test-Path -path \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.req\") { exit 0; } else { exit 1; }",
      #port    => 80,
      #use_ssl => false
    }

    file { "C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.req":
      source => "http://${sub_ca['fqdn']}/CertEnroll/${sub_ca['fqdn']}.req",
      ensure => 'file'
    }

    dsc_script { "sign_sub_ca_cert_by_root_ca_${sub_ca['name']}":
      dsc_setscript => " \
        Write-Verbose \"Submitting C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.req to ${windows_pki::ca_common_name}\"; \
        [String]\$RequestResult = certreq.exe -Config \".\\${windows_pki::ca_common_name}\" -Submit \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.req\"; \
        \$Matches = [Regex]::Match(\$RequestResult, \"RequestId:\\s([0-9]*)\"); \
        If (\$Matches.Groups.Count -lt 2) { \
          Write-Verbose \"Error getting Request ID from SubCA certificate submission.\"; \
          Throw \"Error getting Request ID from SubCA certificate submission.\"; \
        } \
        [int]\$RequestId = \$Matches.Groups[1].Value; \
        Write-Verbose \"Issuing \$RequestId in ${windows_pki::ca_common_name}\"; \
        [String]\$SubmitResult = certUtil.exe -Resubmit \$RequestId; \
        If (\$SubmitResult -notlike 'Certificate issued.*') { \
          Write-Verbose \"Unexpected result issuing SubCA request.\"; \
          Throw \"Unexpected result issuing SubCA request.\"; \
        } \
        Write-Verbose \"Retrieving C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.req from ${windows_pki::ca_common_name}\"; \
        [String]\$RetrieveResult =  certreq.exe -Config \".\\${windows_pki::ca_common_name}\" -Retrieve \$RequestId \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.crt\"; \
      ",
      dsc_getscript => " \
        Return @{ \
          'Generated' = (Test-Path -Path \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.crt\"); \
        } \
      ",
      dsc_testscript => " \
        If (-not (Test-Path -Path \"C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.crt\")) { \
          Return \$False; \
        } \
        Return \$True; \
      "
    }

    Windows_pki::Http_waiter["waiting_for_url: http://${sub_ca['fqdn']}/CertEnroll/${sub_ca['fqdn']}.req"]
    -> File["C:\\Windows\\System32\\CertSrv\\CertEnroll\\${sub_ca['fqdn']}.req"]
    -> Dsc_script["sign_sub_ca_cert_by_root_ca_${sub_ca['name']}"]

  }

}
