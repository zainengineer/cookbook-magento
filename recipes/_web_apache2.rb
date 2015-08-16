# coding: utf-8
#fuser -k -n tcp 80

#For some reason fastcgi module which is part of apache default modules was listening at port 80. Now not happening
#-k is parameter which kills the process
# execute 'kill-port-80' do
#     command "fuser -k -n tcp 80"
#     ignore_failure true
#     only_if node[:magento][:apache][:kill_port80]
# end
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
  siteName = site
  if site == 'ssl'
    cgissl =  '_ssl'
    port = node[:magento][:https_port]
  else
    cgissl = ''
    port = node[:magento][:http_port]
  end
  FastCgiExternalServer = cgiDoc + cgissl + cgiHost

  #web_app is apache recipie thing
  # https://github.com/svanzoest-cookbooks/apache2#web_app

  web_app "#{site}" do
    #name siteName
    enable true
    template 'apache2-site.conf.erb'
    docroot node[:magento][:dir]
    server_name node[:magento][:domain]
    server_aliases node.fqdn
    ssl true if site == 'ssl'
    ssl_cert File.join(node[:apache][:dir], 'ssl', node[:magento][:cert_name])
    ssl_key File.join(node[:apache][:dir], 'ssl', node[:magento][:cert_name])
    fast_cgi_external_server FastCgiExternalServer
    web_port port
  end
end

%w(000-default).each do |site|
  apache_site "#{site}" do
    enable false
  end
end
