class php_web::apache::service {
  service { $php_web::web_service:
    ensure => running,
    enable => true,
  }
}
