class php_web::nginx::package {

  package { 'nginx':
    ensure => installed,
  }

  if $php_web::firewall_ports {
    firewall { "050 allow ${php_web::web_service}":
      proto  => 'tcp',
      action => 'accept',
      dport  => $php_web::firewall_ports,
    }
  }


}
