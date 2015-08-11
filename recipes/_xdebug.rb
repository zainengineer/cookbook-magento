#include_recipe 'xdebug'

#should work in attributes but not sure how to make it work
node.set[:xdebug]['directives'][:remote_host]  = node[:magento][:remote_host]

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