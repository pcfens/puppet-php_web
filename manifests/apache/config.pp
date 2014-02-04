class php_web::apache::config {
  # TODO: Manage mod_security

  augeas { 'apache2.conf-serversignature':
    require => Package[$php_web::web_service],
    context => "/files${php_web::config_dir}",
    changes => [
      "set ${php_web::apache_config}/directive[last()+1] ServerSignature",
      "set ${php_web::apache_config}/*[self::directive='ServerSignature']/arg Off",
    ],
    onlyif  => "get ${php_web::apache_config}/*[self::directive='ServerSignature']/arg != Off",
    notify  => Service[$php_web::web_service],
  }

  if $php_web::admin_email {
    augeas { 'apache2.conf-serveradmin':
      context => "/files${php_web::config_dir}",
      changes => [
        "set ${php_web::apache_config}/directive[last()+1] ServerAdmin",
        "set ${php_web::apache_config}/*[self::directive='ServerAdmin']/arg ${php_web::admin_email}",
      ],
      onlyif  => "get ${php_web::apache_config}/*[self::directive='ServerAdmin']/arg != ${php_web::admin_email}",
      notify  => Service[$php_web::web_service],
    }
  }

  if $php_web::apache_cas {
    $cas_config = $::osfamily ? {
      'Debian' => "${php_web::config_dir}/mods-available/auth_cas.conf",
      default  => "${php_web::config_dir}/config.d/auth_cas.conf",
    }
    file { $cas_config:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      notify  => Service[$php_web::web_service],
      content => template('php_web/apache/auth_cas.conf.erb'),
    }
  }

  if $::osfamily == 'RedHat' {
    file { "${php_web::config_dir}/sites-enabled":
      ensure => directory,
      owner  => 'root',
      group  => 'root',
    }

    augeas { 'httpd.conf-includesites-enabled':
      require => File["${php_web::config_dir}/sites-enabled"],
      context => "/files${php_web::config_dir}",
      changes => [
        "defnode sitesEnabled conf/${php_web::apache_config}/directive[last()+1] Include",
        "set \$sitesEnabled/arg 'sites-enabled/'",
      ],
      onlyif  => "match conf/${php_web::apache_config}/*[self::directive='Include']/arg[. = 'sites-enabled/'] size == 0",
      notify  => Service[$php_web::web_service],
    }
  }

  if $::osfamily == 'Debian' {
    php_web::apache::enable_module { $php_web::apache_mods: }

    if $php_web::spdy {
      php_web::apache::enable_module { 'spdy': }
    }
    if $php_web::cas {
      php_web::apache::enable_module { 'cas': }
    }
    if $php_web::pagespeed {
      php_web::apache::enable_module { 'pagespeed': }
    }
  }

  file { "${php_web::enabled_sites}/000-default":
    ensure => absent,
    notify => Service[$php_web::web_service],
  }

}
