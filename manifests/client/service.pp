# Class to configure ossec agent service

class ossec::client::service {
  service { $ossec::client::hidsagentservice:
    ensure    => $ossec::client::service_ensure,
    enable    => true,
    hasstatus => true,
    pattern   => $ossec::client::hidsagentservice,
  }  
}
