# coding: utf-8
# General settings
default[:magento][:url] = 'http://www.magentocommerce.com/downloads/assets/1.'\
                          '9.0.1/magento-1.9.0.1.tar.gz'
default[:magento][:dir] = '/var/www/magento'
default[:magento][:domain] = node['fqdn']
# Magento CE's sample data can be found here:
# 'http://www.magentocommerce.com/downloads/assets/1.9.0.0/magento-sample-dat'\
# 'a-1.9.0.0.tar.gz'
# If you are using a version of Magento Community Edition older than 1.9.0.0,
# you will need to use a version of sample data that is compatible with your
# version.
default[:magento][:sample_data_url] = ''
default[:magento][:run_type] = 'store'
default[:magento][:run_codes] = []
default[:magento][:session][:save] = 'db'
default[:magento][:user] = 'magento'

# Required packages
case node['platform_family']
when 'rhel', 'fedora'
  default[:xdebug][:config_file] = '/etc/php.d/xdebug.ini'
  default[:php][:ext_conf_dir] = '/etc/php.d/'
  if node['platform_version'].to_f < 5.2
    default[:magento][:packages] = %w(php-cli php-common php-curl php-gd php-mcrypt php-mysql php-pear php-xml)
    default['php']['packages'] = []
  else
    default[:magento][:packages] = %w(php-cli php-common php-curl php-gd php-mcrypt php-mysql php-pear php-apc php-xml)
  end
  if node['platform_version'].to_f < 6.5

  #      default[:magento][:url_package] = [
  #      {:name => 'mysql',:checksum => '53470b876bce1875cfd010851bb49aacb32156e80733a1723452401722830c33',           :url => 'http://dev.mysql.com/get/mysql-community-release-el5-5.noarch.rpm'  }
  #      ]
     default[:magento][:url_package] = []
  else
    default[:magento][:url_package] = []
  end
else
  default[:magento][:packages] = %w(php5-cli php5-common php5-curl php5-gd php5-mcrypt php5-mysql php-pear php-apc)

  default[:xdebug][:config_file] = '/etc/php5/fpm/conf.d/20-xdebug.ini'
  default[:php][:ext_conf_dir] = '/etc/php5/fpm/conf.d'
end

# Web Server
default[:magento][:webserver] = 'nginx'
default[:magento][:http_port] = 80
default[:magento][:https_port] = 443
default[:magento][:nginx][:send_timeout] = 60
default[:magento][:nginx][:proxy_read_timeout] = 60

default[:magento][:apache][:kill_port80] = false

set['php-fpm']['pools'] = {
    "default" => {
        :enable => true
    },
    "magento" => {
        :enable => "true",
        name: 'magento',
        listen: '127.0.0.1:9001',
        allowed_clients: ['127.0.0.1'],
        user: node[:magento][:user],
        group: node[node[:magento][:webserver]][:group],
        process_manager: 'dynamic',
        max_children: 50,
        start_servers: 5,
        min_spare_servers: 5,
        max_spare_servers: 35,
        max_requests: 500
    }
}

# Web Server SSL Settings
default[:magento][:cert_name] = "#{node[:magento][:domain]}.pem"

# Credentials
::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default[:magento][:database] = 'mysql'

default[:magento][:db][:host] = 'localhost'
default[:magento][:db][:database] = 'magento'
default[:magento][:db][:username] = 'magentouser'
default[:magento][:db][:password] = 'password'
default[:magento][:db][:acl] = 'localhost'


default[:magento][:nginx][:default_listen] = '127.0.0.1:9000'
# ilikerandompasswords is default by mysql
default[:mysql][:db][:root_password] = 'password'
default[:mysql][:db][:server_root_password] = 'password'
default[:mysql][:db][:allow_remote_root] = true
default[:magento][:fresh_install] = false
default[:magento][:install_flag] = '/root/.magento.app.installed'
default[:magento][:remote_host] ='127.0.0.1'
default[:magento][:ioncube] = true
default[:magento][:redis] = true
default[:system][:timezone] = 'Australia/Adelaide'


default[:php][:version] = '5.4'

#default[:xdebug][:config_file] = '/etc/php5/fpm/conf.d/20-xdebug.ini'
default[:xdebug][:web_server][:service_name] = default[:magento][:webserver]
default[:xdebug][:directives] = { remote_enable:  1}


# curl ftp://rpmfind.net/linux/Mandriva/official/updates/2008.1/x86_64/media/main/updates/glibc-2.7-12.2mnb1.x86_64.rpm | shasum -a 256
default[:magento][:url_package_5_3] = [
{:name => 'php-common',:checksum => '5c67feed56e2ace07d3503950592faf886f2b6d0505dc983ecff459f7786aaa4',           :url => 'ftp://rpmfind.net/linux/centos/5.11/os/x86_64/CentOS/php-common-5.1.6-44.el5_10.x86_64.rpm'  },
{:name => 'php-mysql',:checksum => 'fd3abf88bd8962ed3e3dd760fcec8679d80717a6916fb93d041ffba70a703161',        :url => 'ftp://rpmfind.net/linux/centos/5.11/os/x86_64/CentOS/php-mysql-5.1.6-44.el5_10.x86_64.rpm'  },
]
