# == Class: ossec::client
#
# This class is for installing and configuring the ossec client.
#
# === Parameters
#
# hidsagentservice - optional - name of ossec agent service
# hidsagentpackage - optional - name of ossec agent package (if installing from repo)
# package_ensure - optional - whether to install or remove package
# ossec_active_response - optional - enable or disable active response
# ossec_server_ip - REQUIRED - needed to communicate with server
# restart - optional - if a restart is required after configuring application
# service_ensure - optional - whether or not service is enabled
#
# === Examples
#
#  class { 'ossec::client':
#      ossec_server_ip       => '127.0.0.1',
#      ossec_active_response => false;
#  }

class ossec::client(
  $hidsagentservice      = $ossec::params::hidsagentservice,
  $hidsagentpackage      = $ossec::params::hidsagentpackage,
  $package_ensure        = $ossec::params::client_package_ensure,
  $ossec_active_response = true,
  $ossec_server_ip,
  $ossec_checkpaths      = [],
  $ossec_ignorepaths     = [],
  $restart               = $ossec::params::restart,
  $service_ensure        = $ossec::params::service_ensure,
  $syscheck_frequency    = '79200'
) inherits ossec::params {

  include '::ossec'
  include '::ossec::client::install'
  include '::ossec::client::config'
  include '::ossec::client::key'
  include '::ossec::client::service'

  anchor { 'ossec::client::start': }
  anchor { 'ossec::client::end': }
  
  if $restart {
    Anchor['ossec::client::start'] ->
    Class['ossec::client::install'] ->
    # Only difference between the blocks is that we use ~> to restart if
    # restart is set to true.
    Class['ossec::client::config'] ->
    Class['ossec::client::key'] ~>
    Class['ossec::client::service'] ->
    Anchor['ossec::client::end']
  } else {
    Anchor['ossec::client::start'] ->
    Class['ossec::client::install'] ->
    Class['ossec::client::config'] ->
    Class['ossec::client::key'] ->
    Class['ossec::client::service'] ->
    Anchor['ossec::client::end']
  }




}


