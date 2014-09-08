class php_web::php {

  php::fpm::conf { 'www':
    ensure => absent,
  }

  $php_ini_bottom = {
    template => 'php_web/php.ini.erb',
  }

  $php_ini_super = {
    ensure               => present,
  }

  $php_ini = { '/etc/php5/fpm/php.ini' =>
    deep_merge($php_ini_bottom, $::php_web::php_ini_params, $php_ini_super)
  }

  if $php_ini['/etc/php5/fpm/php.ini']['session_save_handler'] == 'memcache' {
    $final_php_mods = concat($::php_web::php_mods, 'memcache')
  } else {
    $final_php_mods = $::php_web::php_mods
  }

  $prefix = $::osfamily ? {
    'Debian' => 'php5-',
    default  => 'php-',
  }

  $php_packages = prefix($final_php_mods, $prefix)
  package { $php_packages:
    ensure  => present,
    require => Class['php::fpm::daemon'],
  }

  class { 'php::fpm::daemon':
    ensure    => present,
    log_level => 'warn',
  }

  create_resources('php::ini', $php_ini)

}
