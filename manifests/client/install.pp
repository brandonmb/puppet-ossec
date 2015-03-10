# This class installs ossec for the ossec agent

class ossec::client::install (
) {

  case $::osfamily {
    'Debian' : {
      package { $ossec::client::hidsagentpackage:
        ensure  => $ossec::client::package_ensure,
      }
    }
    'RedHat' : {
      package { $ossec::client::hidsagentpackage:
        ensure  => $ossec::client::package_ensure,
        require => Package['ossec-hids'],
      }
    }
    default: { fail('OS family not supported') }
  }  
}