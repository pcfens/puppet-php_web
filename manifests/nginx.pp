class php_web::nginx {
  class { 'php_web::nginx::package': }
  class { 'php_web::nginx::config': }
  class { 'php_web::nginx::service': }

  Class['php_web::nginx::package']
  -> Class['php_web::nginx::config']
  -> Class['php_web::nginx::service']
}
