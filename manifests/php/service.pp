class php_web::php::service {
  service { $php_web::php_service:
    ensure => running,
    enable => true,
  }
}
