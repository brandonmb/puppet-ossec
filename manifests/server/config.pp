# This class configures the the ossec client 

#### This class needs anchored after install and common

class ossec::server::config {
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