# Class to configure server service
#
# When compiled from source, the service name is "ossec"
#  - this can be overwritten when calling the ossec::server class

class ossec::server::service {
  service { $ossec::server::hidsserverservice:
    ensure    => $ossec::server::service_ensure,
    enable    => true,
    hasstatus => true,
    pattern   => $ossec::server::hidsserverservice,
    require   => Package[$ossec::server::hidsserverpackage],
  }
}