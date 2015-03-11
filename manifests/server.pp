# == Class: ossec::server
#
# This class sets up the ossec server
#  - It installs from source or repo
#  - sets up configs
#  - verifies service is enabled and running
#

class ossec::server (
  $package_ensure                      = $ossec::params::server_package_ensure,
  $hidsserverpackage                   = $ossec::params::hidsserverpackage,
  $hidsserverservice                   = $ossec::params::hidsserverservice,
  $mailserver_ip,
  $ossec_emailto,
  $ossec_emailfrom                     = "ossec@${::domain}",
  $ossec_active_response               = true,
  $ossec_global_host_information_level = 8,
  $ossec_global_stat_level             = 8,
  $ossec_email_alert_level             = 7,
  $ossec_ignorepaths                   = [],
  $restart                             = $ossec::params::restart,
  $service_ensure                      = $ossec::params::service_ensure
) inherits ossec::params {
  
  include '::ossec::server::install'
  include '::ossec::server::config'
  include '::ossec::server::key'
  include '::ossec::server::service'

  anchor { 'ossec::server::start': }
  anchor { 'ossec::server::end': }
  
  if $restart {
    Anchor['ossec::server::start'] ->
    Class['ossec::server::install'] ->
    # Only difference between the blocks is that we use ~> to restart if
    # restart is set to true.
    Class['ossec::server::config'] ->
    Class['ossec::server::key'] ~>
    Class['ossec::server::service'] ->
    Anchor['ossec::server::end']
  } else {
    Anchor['ossec::server::start'] ->
    Class['ossec::server::install'] ->
    Class['ossec::server::config'] ->
    Class['ossec::server::key'] ->
    Class['ossec::server::service'] ->
    Anchor['ossec::server::end']
  }
}
