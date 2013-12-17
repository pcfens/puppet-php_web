class php_web::nginx::package {

  package { 'nginx':
    ensure => installed,
  }

}
