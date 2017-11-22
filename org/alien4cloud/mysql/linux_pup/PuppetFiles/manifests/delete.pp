
  service { 'mysql':
    enable => true,
    ensure => stopped,
    }
	
  file { "/etc/mysql":
    path    => "/etc/mysql"
    ensure => "absent",
  }

   file { "/home/ubuntu/puppetlabs-release-trusty.deb":
    path    => "/home/ubuntu/puppetlabs-release-trusty.deb"
    ensure => "absent",
  }
  
  file { "/etc/puppet":
    path    => "/etc/puppet"
    ensure => "absent",
  }