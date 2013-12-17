class php_web::php::config {
  if $php_web::suhosin {
    $suhosin_config = $::osfamily ? {
      'Debian' => '/etc/php5/conf.d/suhosin.ini',
      default  => '/etc/php/conf.d/suhosin.ini',
    }

    file { $suhosin_config:
      ensure => present,
      source => 'puppet:///modules/php_web/suhosin.ini',
      owner  => 'root',
      group  => 'root',
      notify => Service[$php_web::php_service],
    }
  }

  $php_fpm_config = $::osfamily ? {
    'Debian' => '/etc/php5/fpm/php.ini',
    default  => '/etc/php-fpm/php.ini',
  }

  # TODO: Make this a template
  file { $php_fpm_config:
    ensure => present,
    source => 'puppet:///modules/php_web/php.ini',
    owner  => 'root',
    group  => 'root',
    notify => Service[$php_web::php_service],
  }

  file { "${php_web::php_pool}/www.conf":
    ensure => absent,
    notify => Service[$php_web::php_service],
  }

  file { '/var/log/php-fpm':
    ensure => directory,
  }
}
