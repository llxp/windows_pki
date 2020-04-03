define windows_pki::http_waiter (
  String $url = '',
  Integer $timeout = 60,
  Integer $sleep_timeout = 10,
  String $onlyif = ''
) {

  exec { "wait_for_url_${url}":
    command => " \
      \$counter = 0; \
      while (\$true) { \
        try { \
          if ( (wget ${url} -UseBasicParsing -TimeoutSec 3600 -Method Get).StatusCode -eq 200) { \
            return 0; \
          } \
        } catch [System.Net.WebException] { \
        } \
        if (\$counter -ge ${timeout}) { \
          return 1; \
        } else { \
          Write-Host \"Url not reachable\"; \
          [Console]::Out.Flush(); \
          Start-Sleep ${sleep_timeout}; \
          \$counter = \$counter + 1; \
        } \
      } \
    ",
    onlyif => $onlyif,
    provider => "powershell",
    logoutput => true
  }

}
