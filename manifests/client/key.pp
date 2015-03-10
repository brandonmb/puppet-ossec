# Class to setup client agent keys

class ossec::client::key {
  concat { '/var/ossec/etc/client.keys':
    owner   => 'root',
    group   => 'ossec',
    mode    => '0640',
  }
  ossec::agentkey{ "ossec_agent_${::fqdn}_client":
    agent_id         => $::uniqueid,
    agent_name       => $::fqdn,
    agent_ip_address => $::ipaddress,
  }
  @@ossec::agentkey{ "ossec_agent_${::fqdn}_server":
    agent_id         => $::uniqueid,
    agent_name       => $::fqdn,
    agent_ip_address => $::ipaddress
  }
}