class php_web::apache::service {
  service { $php_web::web_service:
    enable => true,
    ensure => running,
  }
}
