# coding: utf-8
name 'project_cp'
maintainer 'Yevgeniy Viktorov'
maintainer_email 'craftsman@yevgenko.me'
license 'Apache 2.0'
description 'Magento app stack'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.1'
recipe 'project_cp', 'Project cp'

%w(debian ubuntu centos redhat fedora amazon).each do |os|
  supports os
end

%w(apt yum apache2 nginx mysql openssl php yum-epel
   mysql-chef_gem).each do |cb|
  depends cb
end

depends 'php', '~> 1.5.0'
depends 'php-fpm', '>= 0.6.4'
depends 'nginx', '~> 2.6'
depends 'system', '~> 0.7.0'
depends 'git', '~> 4.2.2'
depends 'mysql', '~> 6.1.0'
depends 'database', '~> 4.0.8'
depends 'composer', '~> 2.1.0'
depends 'xdebug', '~> 1.0.0'
depends 'php-ioncube', '~> 0.2.0'
depends 'apt', '~> 2.7.0'
depends 'ubuntu', '~> 1.1.8'
depends 'nodejs', '~> 1.3.0'