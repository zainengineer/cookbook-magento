#include_recipe 'xdebug'

clientIP = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first
networkIP = clientIP.split('.')
ipParts = clientIP.split('.')
ipParts[3] = 1;
networkIP = ipParts.join('.')
directives = node[:xdebug]['directives'].to_hash
directives[:remote_host]  = networkIP
if directives[:remote_host.to_s]
    puts "inside if of delete"
    directives.delete(:remote_host.to_s)
end if
directives.delete(:remote_host.to_s)
node.set[:xdebug]['directives'] = directives


if platform?(%w{debian ubuntu})
  package "php5-xdebug"
elsif platform?(%w{centos redhat fedora amazon scientific})
  #assuming php 5.3
  if node['platform_version'].to_f < 6.5
    package "php-pecl-xdebug"
  else
    php_pear "xdebug" do
        action :install
      end
  end
end

template node['xdebug']['config_file'] do
  source 'xdebug.ini.erb'
  owner 'root'
  group 'root'
  mode 0644
  cookbook "xdebug"
  unless node['xdebug']['web_server']['service_name'].empty?
    notifies :restart, resources("service[#{node['xdebug']['web_server']['service_name']}]"), :delayed
  end
end

directives = node['xdebug']['directives']

unless directives.nil?
  if directives.key?('remote_log')
    file directives['remote_log'] do
      owner 'root'
      group 'root'
      mode 0777
      not_if { directives['remote_log'].empty? }
    end
  end
end