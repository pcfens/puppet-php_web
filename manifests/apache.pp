class php_web::apache {
  class { 'php_web::apache::package': }
  class { 'php_web::apache::config': }
  class { 'php_web::apache::service': }

  Class['php_web::apache::package']
  -> Class['php_web::apache::config']
  -> Class['php_web::apache::service']
}
