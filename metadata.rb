# coding: utf-8
name 'magento'
maintainer 'Yevgeniy Viktorov'
maintainer_email 'craftsman@yevgenko.me'
license 'Apache 2.0'
description 'Magento app stack'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.8.8'
recipe 'magento', 'Prepares app stack for magento deployments'

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
depends 'mysql', '= 5.6.3'
depends 'mysql-chef_gem', '= 0.0.5'
depends 'magerun', '~> 2.2.4'
depends 'composer', '~> 2.1.0'