# Class to setup server agent keys

class ossec::server::key {
  concat { '/var/ossec/etc/client.keys':
    owner   => 'root',
    group   => 'ossec',
    mode    => '0640',
  }
  concat::fragment { 'var_ossec_etc_client.keys_end' :
    target  => '/var/ossec/etc/client.keys',
    order   => 99,
    content => "\n",
  }
  Ossec::Agentkey<<| |>>
}