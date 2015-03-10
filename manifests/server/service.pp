# Class to configure server service

class ossec::server::service {
  service { $ossec::server::hidsserverservice:
    ensure    => $ossec::server::service_ensure,
    enable    => true,
    hasstatus => true,
    pattern   => $ossec::server::hidsserverservice,
    require   => Package[$ossec::server::hidsserverpackage],
  }
}