# Ossec class
#
## Variables
# comment - set a comment for custom_apt_source
# custom_apt_ppa - set this to an actual string
#    ex. 'ppa:nicolas-zin/ossec-ubuntu'
# custom_apt_source - this is a boolean, set to true or leave default
# include_src - include source for custom_apt_source
# install_from_source - boolean, set to true or false
# key - key for custom_apt_source
# key_server - key server for custom_apt_source
# location - http location for custom_apt_source repo
# name - just sets the name for staging target directory
# pin - ping for custom_apt_source
# release - the relase of custom_apt_source
# repos - repos for custom_apt_source
# required_packages - packages required for custom_apt_source
# source_url - source to pull ossec source files from
#    (see staging module for source options)
# target - target directory for extracted files

class ossec (
  $comment             = undef,
  $custom_apt_ppa      = undef,
  $custom_apt_source   = undef,
  $include_src         = undef,
  $install_from_source = false,
  $key                 = undef,
  $key_server          = undef,
  $location            = undef,
  $name                = $ossec::params::name,
  $pin                 = undef,
  $release             = undef,
  $repos               = undef,
  $required_packages   = undef,
  $source_url          = $ossec::params::source_url,
  $target              = $ossec::params::target
) { 
  
  if $install_from_source {
    validate_bool($install_from_source)
  }
  
  if ! $custom_apt_ppa {
    $apt_ppa = $::ossec::params::default_ppa
  } else {
    $apt_ppa = $custom_apt_ppa
  }

  if $custom_apt_repo and ! $remote_repo {
    warning('Custom_apt_repo set to true but remote_repo not set. Using default repo.')
  }

  if $custom_apt_source and ! $location {
    fail('If custom_apt_source is set then $location must be specified')
  }
  
  if $custom_apt_source and $::osfamily != 'Debian' {
    warning('custom_apt_source only verified on debian. Defaulting back to default')
    $custom_apt_source = undef
  }
  
  if $install_from_source {
    ossec::source { $name:
      source_url  => $source_url,
      target      => $target,
    }    
  } else {
      if $custom_apt_source {
        apt::source { $name:
          comment           => $comment,
          location          => $location,
          release           => $release,
          repos             => $repos,
          required_packages => $required_packages,
          key               => $key,
          key_server        => $key_server,
          pin               => $pin,
          include_src       => $include_src,
          include_deb       => true
        }
      } else {
        case $::osfamily {
          'Debian' : {
            case $::lsbdistcodename {
              /(lucid|precise|trusty)/: {
                apt::ppa { $apt_ppa: }
              }
              /^(jessie|wheezy)$/: {
                apt::source { 'alienvault':
                  ensure      => present,
                  comment     => 'This is the AlienVault Debian repository for Ossec',
                  location    => 'http://ossec.alienvault.com/repos/apt/debian',
                  release     => $::lsbdistcodename,
                  repos       => 'main',
                  include_src => false,
                  include_deb => true,
                  key         => '9A1B1C65',
                  key_source  => 'http://ossec.alienvault.com/repos/apt/conf/ossec-key.gpg.key',
                }
                ~>
                exec { 'update-apt-alienvault-repo':
                  command     => '/usr/bin/apt-get update',
                  refreshonly => true
                }  
              }
            }
          }
          'Redhat' : {
            # Set up Atomic rpm repo
            class { '::atomic':
              includepkgs => 'ossec-hids*',
            }
            package { 'ossec-hids':
              ensure  => installed,
              require => Class['atomic'],
            }
            package { 'inotify-tools': ensure => present }
          } 
        }
      }
  }
}
