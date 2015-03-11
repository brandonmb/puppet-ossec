# This class installs ossec for the ossec server
# It checks to see if ossec::install_from_source has been set
#  - if so then it builds from source, otherwise it installs
#    from repo

class ossec::server::install {

  if ! $ossec::install_from_source {
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
  } else {
    exec {
      "install_ossec_source":
        command  => "${ossec::target}/${ossec::ossec_version}/install.sh",
        path     => '/bin:/usr/bin:/usr/sbin',
        creates  => "/var/ossec/bin",
        require  => [ File["${ossec::target}/${ossec::ossec_version}/etc/preloaded-vars.conf"], Package["${ossec::make_package}"] ];
    }
  }
}