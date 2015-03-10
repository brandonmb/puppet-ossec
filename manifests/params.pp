class ossec::params {
  $server_package_ensure  = 'present'
  $client_package_ensure  = 'present'
  $default_ppa            = 'ppa:nicolas-zin/ossec-ubuntu'
  $restart                = true
  $service_ensure         = 'running'
  $source_url             = 'http://www.ossec.net/files/ossec-hids-2.8.1.tar.gz'
  $target                 = '/tmp/ossec'
  $name                   = 'ossec'

  case $::osfamily {
    'Debian' : {
      $hidsagentservice  = 'ossec-hids-agent'
      $hidsagentpackage  = 'ossec-hids-agent'

      case $::lsbdistcodename {
        /(lucid|precise|trusty)/: {
          $hidsserverservice = 'ossec-hids-server'
          $hidsserverpackage = 'ossec-hids-server'
        }
        /^(jessie|wheezy)$/: {
          $hidsserverservice = 'ossec'
          $hidsserverpackage = 'ossec-hids'
        }
        default: { fail('This ossec module has not been tested on your distribution (or lsb package not installed)') }
      }
    }
    'Redhat' : {
      $hidsagentservice  = 'ossec-hids'
      $hidsagentpackage  = 'ossec-hids-client'
      $hidsserverservice = 'ossec-hids'
      $hidsserverpackage = 'ossec-hids-server'
      case $::operatingsystemrelease {
        /^5/:    {$redhatversion='el5'}
        /^6/:    {$redhatversion='el6'}
        /^7/:    {$redhatversion='el7'}
        default: { }
      }
    }
    default: { fail('This ossec module has not been tested on your distribution') }
  }
}