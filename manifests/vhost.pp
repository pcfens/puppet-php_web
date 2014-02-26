define php_web::vhost(
  $domain        = $title,
  $user          = undef,
  $uid           = undef,
  $group         = undef,
  $gid           = undef,
  $manage_user   = true,
  $disabled      = false,
  $webroot       = undef,
  $fpm_custom    = undef,
  $vhost_custom  = undef,
  $disable_ldap  = true,
  $alt_root      = false,
  $show_errors   = false,
  $wordpress     = false,
  $upload_limit  = undef,
  $aliases       = [],
) {

  $webserver = getparam(Class['php_web'], 'webserver')
  $vhost_root = getparam(Class['php_web'], 'vhost_root')
  if !$user or !$group {

    if $::osfamily == 'Debian' {
      $user_real = 'www-data'
    } elsif $::osfamily == 'RedHat' {
      $user_real = $webserver ? {
        'nginx'  => 'nginx',
        'apache' => 'apache',
      }
    }

    $group_real = $user_real
    $real_manage_user = false
  } elsif !$manage_user {
    $real_manage_user = false
    $user_real = $user
    $group_real = $group
  } elsif !$uid or !$gid {
    fail('No UID/GID set but is required here.')
  } else {
    $real_manage_user = true
    $user_real = $user
    $group_real = $group
  }

  if !$webroot {
    $webroot_base = "${vhost_root}/${domain}"
  } else {
    $webroot_base = $webroot
  }

  if $alt_root {
    $webroot_real = "${webroot_base}/public_html"
    file { $webroot_base:
      ensure  => 'directory',
      mode    => '2764',
      owner   => $user_real,
      group   => $group_real,
      before  => File[$webroot_real],
    }
  } else {
    $webroot_real = $webroot_base
  }


  $user_shell = $::osfamily ? {
    Debian  => '/usr/sbin/nologin',
    RedHat  => '/sbin/nologin',
    default => '/bin/false',
  }

  if $real_manage_user {

    group { $group_real:
      ensure => present,
      gid    => $gid,
    }

    user { $user_real:
      ensure   => present,
      uid      => $uid,
      gid      => $gid,
      home     => $webroot_real,
      shell    => $user_shell,
      password => '!',
      require  => Group[$group],
    }

    file { $webroot_real:
      ensure  => 'directory',
      mode    => '2764',
      owner   => $user_real,
      group   => $group_real,
      require => User[$user_real],
    }
  } else {
    file { $webroot_real:
      ensure  => 'directory',
      mode    => '2764',
      owner   => $user_real,
      group   => $group_real,
    }
  }


  file { "${php_web::enabled_sites}/${domain}.conf":
    ensure  => link,
    target  => "${php_web::available_sites}/${domain}.conf",
    require => File["${php_web::available_sites}/${domain}.conf"],
    notify  => Service[$php_web::web_service],
  }


  if $fpm_custom {
    file { "${php_web::php_pool}/${domain}.conf":
      ensure  => present,
      source  => $fpm_custom,
      notify  => Service[$php_web::php_service],
      require => Class['php_web'],
    }
  } else {
    file { "${php_web::php_pool}/${domain}.conf":
      ensure  => present,
      content => template('php_web/php-fpm/phpfpm.erb'),
      notify  => Service[$php_web::php_service],
      require => Class['php_web'],
    }
  }

  if !$disabled {
    if $vhost_custom {
      file { "${php_web::available_sites}/${domain}.conf":
        ensure  => present,
        source  => $vhost_custom,
        notify  => Service[$php_web::web_service],
        require => [ File[$webroot_real] ],
      }
    } else {
      file { "${php_web::available_sites}/${domain}.conf":
        ensure  => present,
        content => template("php_web/${webserver}/phpvhost.erb"),
        notify  => Service[$php_web::web_service],
        require => [ File[$webroot_real] ],
      }
    }
  }

}
