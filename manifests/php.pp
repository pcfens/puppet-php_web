class php_web::php {
  class { 'php_web::php::package': }
  class { 'php_web::php::config': }
  class { 'php_web::php::service': }

  Class['php_web::php::package']
  -> Class['php_web::php::config']
  -> Class['php_web::php::service']
}
