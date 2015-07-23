# coding: utf-8

node.set['apache']['default_modules'] = %w(status actions alias auth_basic
                                           authn_file authz_default
                                           authz_groupfile authz_host
                                           authz_user autoindex dir env mime
                                           negotiation setenvif ssl headers
                                           expires log_config logio fastcgi)
include_recipe 'apache2'

Magento.create_ssl_cert(File.join(node[:apache][:dir], 'ssl'),
                        node[:magento][:domain], node[:magento][:cert_name])

php_fpm_pools = node['php-fpm']['pools']
default_listen = node[:magento][:nginx][:default_listen]
php_fpm_pools.each do |name, config|
  next if (name != "magento")
  next if config.has_key?"enable" && !config['enable']
  next if !config.has_key?"listen"
  default_listen = config.listen
end

cgiDoc = File.join(node['apache']['docroot_dir'], 'php5.external')

cgiHost = ' -host ' + default_listen


%w(default ssl).each do |site|
  if site == 'ssl'
    cgissl =  '_ssl'
  else
    cgissl = ''
  end
  FastCgiExternalServer = cgiDoc + cgissl + cgiHost

  web_app "#{site}" do
    template 'apache2-site.conf.erb'
    docroot node[:magento][:dir]
    server_name node[:magento][:domain]
    server_aliases node.fqdn
    ssl true if site == 'ssl'
    ssl_cert File.join(node[:apache][:dir], 'ssl', node[:magento][:cert_name])
    ssl_key File.join(node[:apache][:dir], 'ssl', node[:magento][:cert_name])
    fast_cgi_external_server FastCgiExternalServer
  end
end

%w(default 000-default).each do |site|
  apache_site "#{site}" do
    enable false
  end
end
