# This class configures the the ossec client 

class ossec::client::config(
  $ossec_active_response = $ossec::client::ossec_active_response,
  $ossec_server_ip       = $ossec::client::ossec_server_ip
) {
  concat { '/var/ossec/etc/ossec.conf':
    owner   => 'root',
    group   => 'ossec',
    mode    => '0440',
    notify  => Service[$ossec::client::hidsagentservice]
  }
  concat::fragment { 'ossec.conf_10' :
    target  => '/var/ossec/etc/ossec.conf',
    content => template('ossec/10_ossec_agent.conf.erb'),
    order   => 10,
    notify  => Service[$ossec::client::hidsagentservice]
  }
  concat::fragment { 'ossec.conf_99' :
    target  => '/var/ossec/etc/ossec.conf',
    content => template('ossec/99_ossec_agent.conf.erb'),
    order   => 99,
    notify  => Service[$ossec::client::hidsagentservice]
  }
}