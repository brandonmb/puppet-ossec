# == Class: ossec
#
# This is the base ossec module. To actually do anything with ossec you'll need to 
# also specify the ossec::client or ossec::server classes 
#
# === Parameters
#
# agent_seed - optional - creates seed for agentkey file
# comment - optional - set a comment for custom_apt_source
# custom_apt_ppa - optional - set this to an actual string
#    ex. 'ppa:nicolas-zin/ossec-ubuntu'
# custom_apt_source - optional - this is a boolean, set to true or leave default
# include_src - optional - include source for custom_apt_source
# install_from_source - optional - boolean, set to true or false
# key - optional - key for custom_apt_source
# key_server - optional - key server for custom_apt_source
# location - optional - http location for custom_apt_source repo
# pin - optional - pin for custom_apt_source
# release - optional - the relase of custom_apt_source
# repos - optional - repos for custom_apt_source
# required_packages - optional - packages required for custom_apt_source
####
# The following parameters are only used when building from source
# source_url - optional - source to pull ossec source files from
#    (see staging module for source options)
# ossec_version - optional - set the ossec version for building from source only
# ossec_extension - optional - extension of source file (has only been test with tar.gz)
# target - optional - target directory for extracted files
# make_package - optional - package(s) a distribution needs to run make for building source
# user_language, user_no_stop, user_install_type, user_dir, user_enable_ar,
# user_enable_syscheck, user_enable_rootcheck, user_update_rules, user_agent_server
# **user_install_type - optional - this needs to be changed to server if you are installing ossec
#    from source on an ossec server, otherwise it will build the installation as a client.
####
#
# === Examples
#
#  class {
#    'ossec':
#      install_from_source   => true,
#      source_url            => '/home/local/ossec-hids-2.8.1.tar.gz';
#    'ossec::client':
#      hidsagentservice      => 'ossec',
#      ossec_server_ip       => '127.0.0.1',
#      ossec_active_response => false;

class ossec (
  $agent_seed          = 'xaeS7ahf',
  $comment             = undef,
  $custom_apt_ppa      = undef,
  $custom_apt_source   = undef,
  $include_src         = undef,
  $install_from_source = false,
  $key                 = undef,
  $key_server          = undef,
  $location            = undef,
  $make_package        = $ossec::params::make_package,
  $pin                 = undef,
  $release             = undef,
  $repos               = undef,
  $required_packages   = undef,
  $source_url          = $ossec::params::source_url,
  $ossec_version       = 'ossec-hids-2.8.1',
  $ossec_extension     = 'tar.gz',
  $target              = "/opt/staging/${name}",
  $user_language         = $ossec::params::user_language,
  $user_no_stop          = $ossec::params::user_no_stop,
  $user_install_type     = $ossec::params::user_install_type,
  $user_dir              = $ossec::params::user_dir,
  $user_enable_ar        = $ossec::params::user_enable_ar,
  $user_enable_syscheck  = $ossec::params::user_enable_syscheck,
  $user_enable_rootcheck = $ossec::params::user_enable_rootcheck,
  $user_update_rules     = $ossec::params::user_update_rules,
  $user_agent_server     = $ossec::params::user_agent_server
) inherits ossec::params { 

  $staging_name        = "${ossec_version}.${ossec_extension}"

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
    package { "${make_package}": ensure => 'installed'; }
    ossec::source { "${staging_name}":
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
