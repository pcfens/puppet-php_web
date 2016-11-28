class php_web (
  $service_ensure        = 'running',
  $webserver             = $::php_web::params::webserver,
  $vhost_root            = '/var/www',
  $apache_mods           = $::php_web::params::apache_mods,
  $php_mods              = $::php_web::params::php_mods,
  $apache_params         = {},
  $php_ini_params        = {},
) inherits ::php_web::params {

  validate_string($service_ensure, $webserver)
  validate_array($apache_mods)
  validate_hash($apache_params, $php_ini_params)

  include ::php_web::php

  if $webserver == 'apache' {
    include ::php_web::apache
  } elsif $webserver == 'nginx' {
    fail('nginx is not supported yet')
  }


}
