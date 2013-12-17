define php_web::php::pear_package (
  $package    = $title,
  $repository = 'pear.php.net',
  $version    = 'latest',
){

  $pkg_array = split($package, '[|]')

  if $pkg_array[1] {
    $real_package = $pkg_array[0]
    $real_version = $pkg_array[1]
  } else {
    $real_package = $package
    $real_version = $version
  }

  if $real_version != 'latest' {
    $pear_source = "${repository}|${real_package}-${real_version}"
  } else {
    $pear_source = "${repository}|${real_package}"
  }

  package { "pear-${repository}-${real_package}":
    ensure   => $real_version,
    name     => $real_package,
    provider => 'pear',
    source   => $pear_source,
    require  => Package['php-pear'],
  }

}
