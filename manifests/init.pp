class php_web (
  $webserver             = $php_web::params::webserver,
  $vhost_root            = $php_web::params::vhost_root,
  $spdy                  = false,
  $pagespeed             = false,
  $suhosin               = $php_web::params::suhosin,
  $mod_security          = false,
  $php_cas               = false,
  $apache_cas            = false,
  $cas_login_url         = undef,
  $cas_validate_url      = undef,
  $extra_apache_packages = $php_web::params::extra_apache_packages,
  $extra_php_packages    = $php_web::params::extra_php_packages,
  $pear_libs             = $php_web::params::pear_libs,
  $apache_mods           = $php_web::params::apache_mods,
  $admin_email           = undef,
  $firewall_ports        = [80, 443],
  $manage_selinux        = true,
  $require_mariadb       = $php_web::params::require_mariadb,
) inherits php_web::params {

  validate_bool($spdy, $pagespeed, $mod_security, $apache_cas)
  validate_string($admin_email)

  if $apache_cas and !($cas_login_url or $cas_validate_url){
    fail('cas_login_url and cas_validate_url must be set to enable CAS')
  }

  case $::osfamily {
    'Debian': {
      $web_service = downcase($webserver) ? {
        'apache' => 'apache2',
        'nginx'  => 'nginx',
      }
      $available_sites = "/etc/${web_service}/sites-available"
      $enabled_sites = "/etc/${web_service}/sites-enabled"
      $php_pool = '/etc/php5/fpm/pool.d'
      $php_service = 'php5-fpm'
      $web_user = 'www-data'

    }
    default: {
      $web_service = downcase($webserver) ? {
        'apache' => 'httpd',
        'nginx'  => 'nginx',
      }
      $available_sites = "/etc/${web_service}/sites-available"
      $enabled_sites = "/etc/${web_service}/sites-enabled"
      $php_pool = '/etc/php-fpm.d'
      $php_service = 'php-fpm'
      if $apache_mods {
        info('php_web module cannot manage apache mods in the RedHat OS family')
      }

      if $web_service == 'apache' {
        $web_user = 'apache'
      } elsif $web_service == 'nginx' {
        $web_user = 'nginx'
      }

    }
  }

  $config_dir = "/etc/${web_service}"

  if !$::selinux and $manage_selinux {
    info('Ignoring the manage_selinux flag - selinux is disable or not present on this system')
  }

  $apache_config = $::osfamily ? {
    'Debian' => 'apache2.conf',
    default => 'httpd.conf',
  }


  if $webserver == 'apache' {
    class { 'php_web::apache':
      before => Class['php_web::php'],
    }
  } elsif $webserver == 'nginx' {
    class { 'php_web::nginx':
      before => Class['php_web::php'],
    }
  }
  class { 'php_web::php': }
}
