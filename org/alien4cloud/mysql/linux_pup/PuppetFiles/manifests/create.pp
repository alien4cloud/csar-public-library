  
  exec { "apt-get update":
    command => "/usr/bin/apt-get update",
    onlyif  => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
	}
  
  package { 'mysql-server': 
    ensure => installed, 
	require => Exec["apt-get update"],
    }
   
  service { 'mysql':
    enable => true,
    ensure => running,
    require => Package["mysql-server"],
    }
  file { "/etc/mysql/my.cnf":
    mode    => 600,
    owner   => "mysql",
    group   => "mysql",
    content => template("/etc/puppet/templates/my.cnf.erb"),
	notify => Service["mysql"],
	require => Package["mysql-server"],
  }

  file { "/etc/mysql/conf.d/my.cnf":
    mode    => 600,
    owner   => "mysql",
    group   => "mysql",
	content => template("/etc/puppet/templates/mysqld_safe_syslog.cnf.erb"),
	notify => Service["mysql"],
	require => Package["mysql-server"],
  }
 
  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p${::db_password} status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password ${::db_password}",
	require => Package["mysql-server"],
  }

