# Setup for ossec client

class ossec::client(
  $hidsagentservice      = $ossec::params::hidsagentservice,
  $hidsagentpackage      = $ossec::params::hidsagentpackage,
  $package_ensure        = $ossec::params::client_package_ensure,
  $ossec_active_response = true,
  $ossec_server_ip,
  $restart               = $ossec::params::restart,
  $service_ensure        = $ossec::params::service_ensure
) inherits ossec::params {
  
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


