define php_web::apache::enable_module ($module = $title){
  exec { "/usr/sbin/a2enmod ${module}":
    path    => ['/usr/sbin', '/usr/bin'],
    notify  => Service[$php_web::web_service],
    creates => "${php_web::config_dir}/mods-enabled/${module}.load",
  }
}
