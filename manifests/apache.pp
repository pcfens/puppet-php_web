# Private Class
class php_web::apache {
  if $::lsbdistcodename == 'trusty' {
    include ::apt

    apt::source { 'multiverse':
      location => 'http://archive.ubuntu.com/ubuntu',
      repos    => 'multiverse',
      before   => Class['::apache'],
    }

    apt::source { 'multiverse-updates':
      location => 'http://archive.ubuntu.com/ubuntu',
      repos    => 'multiverse',
      release  => 'trusty-updates',
      before   => Class['::apache'],
    }
  }

  $required_mods = ['actions', 'alias', 'fastcgi' ]

  $install_mods = union($::php_web::apache_mods, $required_mods)

  $apache_super = {
    'default_vhost' => false,
    'default_mods'  => $install_mods,
  }

  $apache_parameters = deep_merge($::php_web::apache_params, $apache_super)
  $apache_class = { '::apache' => $apache_parameters }

  create_resources('class', $apache_class)
}
