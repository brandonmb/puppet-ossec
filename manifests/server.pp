# == Class: ossec::server
#
# This class is for installing and configuring the ossec server.
#
# === Parameters
#
# package_ensure - optional - whether to install or remove package
# hidsserverservice - optional - name of ossec server service
# hidsserverpackage - optional - name of ossec server package (if installing from repo)
# mailserver_ip - 
# ossec_emailto
# ossec_emailfrom
# ossec_active_responsetrue,
# ossec_global_host_information_level
# ossec_global_stat_level
# ossec_email_alert_level
# ossec_checkpaths - optional - additional paths to check
# ossec_ignorepaths - optional - additional list of paths to ignore
# ossec_active_response - optional - enable or disable active response
# ossec_server_ip - REQUIRED - needed to communicate with server
# restart - optional - if a restart is required after configuring application
# service_ensure - optional - whether or not service is enabled
#
# === Examples
#
#  class { 'ossec::server':
#      mailserver_ip         => '127.1.0.1',
#      ossec_active_response => false;
#  }

class ossec::server (
  $package_ensure               = $ossec::params::server_package_ensure,
  $hidsserverpackage            = $ossec::params::hidsserverpackage,
  $hidsserverservice            = $ossec::params::hidsserverservice,
  $mailserver_ip,
  $ossec_emailto,
  $ossec_emailfrom              = "ossec@${::domain}",
  $ossec_active_response        = true,
  $ossec_global_host_info_level = 8,
  $ossec_global_stat_level      = 8,
  $ossec_email_alert_level      = 7,
  $ossec_newrules               = [],
  $ossec_checkpaths             = [],
  $ossec_ignorepaths            = [],
  $new_global                   = [],
  $restart                      = $ossec::params::restart,
  $service_ensure               = $ossec::params::service_ensure,
  $syscheck_frequency           = '79200'
) inherits ossec::params {

  include '::ossec'  
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
