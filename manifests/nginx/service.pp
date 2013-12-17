class php_web::nginx::service {
  service { 'nginx':
    ensure => running,
    enable => true,
  }
}
