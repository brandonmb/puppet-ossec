# Class to configure ossec agent service
#
# When compiled from source, the service name is "ossec"
#  - this can be overwritten when calling the ossec::client class

class ossec::client::service {
  service { "${ossec::client::hidsagentservice}":
    ensure    => $ossec::client::service_ensure,
    enable    => true,
    hasstatus => true,
    pattern   => $ossec::client::hidsagentservice,
  }  
}
