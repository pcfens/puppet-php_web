class php_web::params {
  $webserver = $::osfamily ? {
    'Debian' => 'apache',
    default  => 'apache',
  } 

  $suhosin = $::osfamily ? {
    'Debian' => true,
    'RedHat' => false,
    default  => false,
  }

  $extra_apache_packages = $::osfamily ? {
    'Debian' => ['libapache2-mod-geoip'],
    default  => ['mod_ssl',
                  'mod_geoip'],
  }

  $extra_php_packages = $::osfamily ? {
    'Debian' => [ 'php5-curl',
                  'php5-gd',
                  'php5-imagick',
                  'php5-ldap',
                  'php5-mcrypt',
                  'php5-memcache',
                  'php5-mysql',
                  'php5-pgsql',
                  'php5-pspell',
                  'php5-xmlrpc',
                  'php5-xsl' ],
    default  => [ 'php-gd',
                  'php-ldap',
                  'php-pdo',
                  'php-soap',
                  'php-xml']
  }

  if $::osfamily == 'Debian' {
    $apache_mods = ['rewrite',
                    'actions']
  } else {
    $apache_mods = undef
  }

  $pear_libs = ['Archive_Tar',
                'Cache_Lite',
                'Console_Getopt',
                'HTML_Template_IT',
                'HTTP',
                'HTTP_Request',
                'HTTP_Request2',
                'MDB2|2.4.1',
                'MDB2_Driver_mssql|1.2.1',
                'MDB2_Driver_mysql|1.4.1',
                'MDB2_Driver_oci8|1.4.1',
                'Mail',
                'Net_SMTP',
                'Net_UserAgent_Detect',
                'Net_URL',
                'Net_URL2',
                'PHP_Archive',
                'Structures_Graph',
                'XML_Parser',
                'XML_RPC2',
                'XML_Util' ]

  if defined(Class['mariadb']) {
    $require_mariadb = true
  } else {
    $require_mariadb = false
  }
}
