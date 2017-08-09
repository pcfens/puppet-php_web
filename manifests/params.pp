# Private class
class php_web::params {
  $webserver = 'apache'
  $webserver_real = getparam(Class['php_web'], 'webserver')

  $php_disable_functions = ''

  $use_php_set_handler = false
  $plain_html = false

  $apache_mods = ['actions', 'alias', 'auth_basic', 'dir', 'fastcgi', 'headers',
    'mime', 'rewrite' ]

  $php_mods = [ 'mysql', ]

  $manage_vhost_user = true

  if $::osfamily == 'Debian' {
    $vhost_user = 'www-data'
    $uid = 33
    $user_shell = '/usr/sbin/nologin'
  } elsif $::osfamily == 'RedHat' {
    $user_shell =  '/sbin/nologin'
    if $webserver_real == 'apache' {
      $vhost_user = 'apache'
      $uid = 48
    } elsif $webserver_real == 'nginx' {
      $vhost_user = 'nginx'
      $uid = 499
    }
  } else {
    fail('Your OS isn\'t supported by the php_web module')
  }

}
