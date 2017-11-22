
  exec { "create-${::db_user}": 
    #unless => "mysql -uroot -p${::db_password} ${::db_name}",
    path => ["/bin", "/usr/bin"],
    command => "sudo mysql -uroot -p${::db_password} -e \"CREATE USER '${::db_user}'@'%' IDENTIFIED BY '${::db_password}';\"",
    require => Exec["create-${::db_name}-db"],
  }
  
  exec { "create-${::db_name}-db":
    unless => "sudo mysql -uroot ${::db_name}",
    path => ["/bin", "/usr/bin"],
    command => "sudo mysql -uroot -p${::db_password} -e \"create database ${::db_name};\"",
  }

  exec { "Grant all privileges ${::db_user} on ${::db_name}": 
    #unless => "mysql -uroot -p${::db_password} ${::db_name}",
    path => ["/bin", "/usr/bin"],
    command => "sudo mysql -uroot -p${::db_password} -e \"GRANT ALL PRIVILEGES ON ${::db_name}.* TO '${::db_user}'@'%' WITH GRANT OPTION\"",
    require => Exec["create-${::db_user}"],
  }

  exec { "Flush privileges": 
    #unless => "mysql -uroot -p${::db_password} ${::db_name}",
    path => ["/bin", "/usr/bin"],
    command => "sudo mysql -uroot -p${::db_password} -e \"FLUSH PRIVILEGES\"",
	require => Exec["Grant all privileges ${::db_user} on ${::db_name}"],
  }