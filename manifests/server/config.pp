# This class configures the the ossec client 

class ossec::server::config(
  $mailserver_ip                = $ossec::server::mailserver_ip,
  $ossec_emailto                = $ossec::server::ossec_emailto,
  $ossec_emailfrom              = $ossec::server::ossec_emailfrom,
  $ossec_active_response        = $ossec::server::ossec_active_response,
  $ossec_global_host_info_level = $ossec::server::ossec_global_host_info_level,
  $ossec_global_stat_level      = $ossec::server::ossec_global_stat_level,
  $ossec_email_alert_level      = $ossec::server::ossec_email_alert_level,
  $ossec_newrules               = $ossec::server::ossec_newrules,
  $ossec_checkpaths             = $ossec::server::ossec_checkpaths,
  $ossec_ignorepaths            = $ossec::server::ossec_ignorepaths,
  $syscheck_frequency           = $ossec::server::syscheck_frequency,
  $new_global                   = $ossec::server::new_global
) {
  # configure ossec
  concat { '/var/ossec/etc/ossec.conf':
    owner   => 'root',
    group   => 'ossec',
    mode    => '0440',
    notify  => Service[$ossec::server::hidsserverservice]
  }
  concat::fragment { 'ossec.conf_10' :
    target  => '/var/ossec/etc/ossec.conf',
    content => template('ossec/10_ossec.conf.erb'),
    order   => 10,
    notify  => Service[$ossec::server::hidsserverservice]
  }
  concat::fragment { 'ossec.conf_90' :
    target  => '/var/ossec/etc/ossec.conf',
    content => template('ossec/90_ossec.conf.erb'),
    order   => 90,
    notify  => Service[$ossec::server::hidsserverservice]
  }
}