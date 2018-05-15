class php_web::php {

  if $php_web::php_ini_params['Session/session.save_handler'] != undef and $php_web::php_ini_params['Session/session.save_handler'] == 'memcache' {
    $final_php_mods = concat($::php_web::php_mods, 'memcache')
  } else {
    $final_php_mods = $::php_web::php_mods
  }

  $prefix = $::osfamily ? {
    'Debian' => $::lsbdistrelease ? {
      '14.04' => 'php5-',
      default => 'php-',
    },
    default  => 'php-',
  }

  $php_packages = unique(prefix($final_php_mods, $prefix))
  package { $php_packages:
    ensure  => present,
  }

  class { '::php':
    manage_repos => false,
    composer     => false,
    dev          => false,
    fpm          => true,
    pear         => true,
    settings     => $php_web::php_ini_params,
  }
}
