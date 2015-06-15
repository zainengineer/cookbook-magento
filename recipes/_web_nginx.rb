# coding: utf-8

if File.exist? node[:magento][:install_flag]
    return
end

include_recipe 'nginx'

Magento.create_ssl_cert(File.join(node[:nginx][:dir], 'ssl'),
                        node[:magento][:domain], node[:magento][:cert_name])

%w(backend).each do |file|
  cookbook_file File.join(node[:nginx][:dir], 'conf.d', "#{file}.conf") do
    source "nginx/#{file}.conf"
    mode 0644
    owner 'root'
    group 'root'
  end
end

bash 'Drop default site' do
  cwd node[:nginx][:dir]
  code <<-EOH
  rm -rf conf.d/default.conf
  EOH
  notifies :reload, resources(service: 'nginx')
end

php_fpm_pools = node['php-fpm']['pools']
#php_fpm_pools = {"default"=>{"enable"=>true}}

# example of adding listen
# https://github.com/yevgenko/cookbook-php-fpm/blob/fe9bb839f4416cac36cb451ce604eac6b3773406/.kitchen.yml


#default_listen = '127.0.0.1:9000'
default_listen = node[:magento][:nginx][:default_listen]
#

php_fpm_pools.each do |name, config|
  next if (name != "magento")
  next if config.has_key?"enable" && !config['enable']
  next if !config.has_key?"listen"
  default_listen = config.listen
end

%w(default ssl).each do |site|
  template File.join(node[:nginx][:dir], 'sites-available', site) do
    source 'nginx-site.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables(
      path: node[:magento][:dir],
      ssl: (site == 'ssl') ? true : false,
      ssl_cert: File.join(node[:nginx][:dir], 'ssl',
                          node[:magento][:cert_name]),
      ssl_key: File.join(node[:nginx][:dir], 'ssl', node[:magento][:cert_name]),
      listen_param: default_listen
    )
  end
  nginx_site site do
    template nil
    notifies :reload, resources(service: 'nginx')
  end
end