class windows_pki::crl_params {

  #if $windows_pki::domain_name.length() > 0 {
  #  $crl_urls_temp = [
  #    "1:C:\\Windows\\system32\\CertSrv\\CertEnroll\\%3%8%9.crl",
  #    "10:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10",
  #    "2:http://${windows_pki::cdp_server}.${windows_pki::domain_name}/CertEnroll/%3%8%9.crl"
  #  ]
  #  $ca_urls_temp = [
  #    "1:C:\\Windows\\system32\\CertSrv\\CertEnroll\\%1_%3%4.crt",
  #    "2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11",
  #    "2:http://${windows_pki::cdp_server}.${windows_pki::domain_name}/CertEnroll/%1_%3%4.crt"
  #  ]
  #} else {
    if $windows_pki::publish_delta_clrs {
      $crl_urls_temp = [
        "65:C:\\Windows\\system32\\CertSrv\\CertEnroll\\%3%8%9.crl",
        "14:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10",
        "6:http://${windows_pki::cdp_server}/CertEnroll/%3%8%9.crl"
      ]
      $crl_urls_temp2 = $windows_pki::cdp_shares.map |$value| {
        "65:\\\\${value}\\CertEnroll\\%3%8%9.crl"
      }
      $crl_urls = $crl_urls_temp + $crl_urls_temp2
    } else {
      $crl_urls_temp = [
        "1:C:\\Windows\\system32\\CertSrv\\CertEnroll\\%3%8%9.crl",
        "10:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10",
        "2:http://${windows_pki::cdp_server}/CertEnroll/%3%8%9.crl"
      ]
      $crl_urls_temp2 = $windows_pki::cdp_shares.map |$value| {
        "1:\\\\${value}\\CertEnroll\\%3%8%9.crl"
      }
      $crl_urls = $crl_urls_temp + $crl_urls_temp2
    }

    $ca_urls_temp = [
      "1:C:\\Windows\\system32\\CertSrv\\CertEnroll\\%1_%3%4.crt",
      "2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11",
      "2:http://${windows_pki::cdp_server}/CertEnroll/%1_%3%4.crt"
    ]
    $ca_urls_temp2 = $windows_pki::cdp_shares.map |$value| {
      "1:\\\\${value}\\CertEnroll\\%1_%3%4.crt"
    }
    $ca_urls = $ca_urls_temp + $ca_urls_temp2
  #}

}
