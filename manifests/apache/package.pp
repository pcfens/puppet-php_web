class php_web::apache::package {

  package { $php_web::web_service:
    ensure => installed,
  }

  if $php_web::extra_apache_packages {
    package { $php_web::extra_apache_packages:
      ensure  => present,
      require => Package[$php_web::web_service],
    }
  }

  if $php_web::apache_cas {
    $cas_package = $::osfamily ? {
      'Debian' => 'libapache2-mod-auth-cas',
      default  => 'mod_auth_cas',
    }

    package { $cas_package:
      ensure  => latest,
      require => Package[$php_web::web_service],
    }
  }


  if $::osfamily == 'Debian' {
    package { 'libapache2-mod-fastcgi':
      ensure  => present,
      require => Package[$php_web::web_service],
    }


    if $php_web::spdy or $php_web::pagespeed {
      apt::key { 'google':
        key        => '7FAC5991',
        key_server => 'pgp.mit.edu',
      }
    }

    if $php_web::spdy {
      apt::source { 'mod-spdy':
        require     => Apt::Key['google'],
        location    => 'http://dl.google.com/linux/mod-spdy/deb/',
        release     => 'stable',
        repos       => 'main',
        include_src => false,
      }

      package { 'mod-spdy-beta':
        ensure  => latest,
        require => [ Package[$php_web::web_service], Apt::Source['mod-spdy'] ],
      }
    }

    if $php_web::pagespeed {
      apt::source { 'mod-pagespeed':
        require     => Apt::Key['google'],
        location    => 'http://dl.google.com/linux/mod-pagespeed/deb/',
        release     => 'stable',
        repos       => 'main',
        include_src => false,
      }

      package { 'mod-pagespeed-stable':
        ensure  => latest,
        require => [ Package[$php_web::web_service], Apt::Source['mod-pagespeed'] ],
      }
    }
  } elsif $::osfamily == 'RedHat' {

    package { 'mod_fastcgi':
      ensure   => installed,
      require  => Package[$php_web::web_service],
      provider => 'rpm',
      source   =>
        'http://apt.sw.be/redhat/el6/en/x86_64/rpmforge/RPMS/mod_fastcgi-2.4.6-2.el6.rf.x86_64.rpm',
    }

    if !defined(Package['at']) {
      package { 'at':
        ensure => latest,
      }
    }

    if $php_web::spdy {
      package { 'mod-spdy-beta':
        ensure   => latest,
        provider => 'rpm',
        source   => 'https://dl-ssl.google.com/dl/linux/direct/mod-spdy-beta_current_x86_64.rpm',
        require  => [ Package[$php_web::web_service], Package['at'] ],
      }
    }

    if $php_web::pagespeed {
      package { 'mod-pagespeed-stable':
        ensure   => latest,
        provider => 'rpm',
        source   => 'https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm',
        require  => [ Package[$php_web::web_service], Package['at'] ],
      }
    }

    if $::selinux == true and $php_web::manage_selinux {
      selboolean { 'httpd_use_nfs':
        persistent => true,
        value      => 'on',
      }

      selboolean { 'httpd_can_network_connect_db':
        persistent => true,
        value      => 'on',
      }
    }

  } else {
    fail('Your platform is not supported by php_web')
  }

  if $php_web::firewall_ports {
    firewall { "050 allow ${php_web::web_service}":
      proto  => 'tcp',
      action => 'accept',
      dport  => $php_web::firewall_ports,
    }
  }

}
