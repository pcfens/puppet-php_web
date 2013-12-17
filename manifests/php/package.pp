class php_web::php::package {

  package { $php_web::php_service:
    ensure => installed,
  }

  $suhosin_package = $::osfamily ? {
    'Debian' => 'php5-suhosin',
    default  => 'php-suhosin',
  }
 
  if !$php_web::extra_php_packages and $php_web::suhosin {
    $php_pkgs = ['php-pear', $suhosin_package]
  } elsif $php_web::suhosin {
    $php_pkgs = concat($php_web::extra_php_packages, ['php-pear', $suhosin_package])
  } else {
    validate_array($php_web::extra_php_packages)
    $php_pkgs = concat($php_web::extra_php_packages, ['php-pear'])
  }

  if $require_mariadb {
    package { $php_pkgs:
      ensure  => installed,
      require => [ Package[$php_web::php_service], Package['mariadb-server'] ],
      before  => [ Exec['install-phpcas'] ],
    }
  } else {
    package { $php_pkgs:
      ensure  => installed,
      require => [ Package[$php_web::php_service], Package['mariadb-server'] ],
      #require => Package[$php_web::php_service],
      before  => [ Exec['install-phpcas'] ],
    }
  }

  php_web::php::pear_package { $php_web::pear_libs: 
    require => [ Package[$php_web::php_service], Package['php-pear'] ],
  }

  if $php_web::php_cas {
    $phpcas = $::osfamily ? {
      'Debian' => '/usr/share/php/CAS.php',
      default  => '/usr/share/pear/CAS.php',
    }

    exec { 'install-phpcas':
      command => 'pear install http://downloads.jasig.org/cas-clients/php/current.tgz',
      path    => ['/usr/local/bin', '/usr/bin'],
      creates => $phpcas,
      require => Package['php-pear'],
    }
  }

  if $::osfamily == 'Debian' {
    package { 'libapache2-mod-php5':
      ensure => absent,
    }
  }

}
