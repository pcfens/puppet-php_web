class php_web::nginx::config {
  file { "${php_web::enabled_sites}/default":
    ensure => absent,
    notify => Service[$php_web::web_service],
  }
}
