# user_agent_server can be set to USER_AGENT_SERVER_IP=*ip* or USER_AGENT_SERVER_NAME=*hostname*

class ossec::params {
  $server_package_ensure  = 'present'
  $client_package_ensure  = 'present'
  $default_ppa            = 'ppa:nicolas-zin/ossec-ubuntu'
  $restart                = true
  $service_ensure         = 'running'
  $source_url             = 'http://www.ossec.net/files/ossec-hids-2.8.1.tar.gz'
  $user_language          = 'USER_LANGUAGE="en"'
  $user_no_stop           = 'USER_NO_STOP="y"'
  $user_install_type      = 'USER_INSTALL_TYPE="agent"'
  $user_dir               = 'USER_DIR="/var/ossec"'
  $user_enable_ar         = 'USER_ENABLE_ACTIVE_RESPONSE="y"'
  $user_enable_syscheck   = 'USER_ENABLE_SYSCHECK="y"'
  $user_enable_rootcheck  = 'USER_ENABLE_ROOTCHECK="y"'
  $user_update_rules      = 'USER_UPDATE_RULES="y"'
  $user_agent_server      = 'USER_AGENT_SERVER_IP="1.2.3.4"'

  case $::osfamily {
    'Debian' : {
      $hidsagentservice  = 'ossec-hids-agent'
      $hidsagentpackage  = 'ossec-hids-agent'
      $make_package      = 'build-essential'

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
      $make_package      = 'make'
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