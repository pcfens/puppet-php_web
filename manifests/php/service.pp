class php_web::php::service {
  service { $php_web::php_service:
    enable => true,
    ensure => running,
  }
}
