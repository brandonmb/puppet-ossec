# This class installs ossec for the ossec server
class ossec::server::install {
  # install package
  case $::osfamily {
    'Debian' : {
      package { $ossec::server::hidsserverpackage:
        ensure  => $ossec::server::package_ensure,
      }
    }
    'RedHat' : {
      package { 'mysql': ensure => present }
      package { $ossec::server::hidsserverpackage:
        ensure  => $ossec::server::package_ensure,
        require => Package['mysql'],
      }
    }
    default: { fail('OS family not supported') }

  }
}