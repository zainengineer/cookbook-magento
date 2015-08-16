# coding: utf-8

mysql_service 'default' do
  bind_address '0.0.0.0'
  initial_root_password node[:mysql][:server_root_password]
  action [:create, :start]
end

#extra config is added in conf.d

# mysql_config 'foo' do
#   source 'my_extra_settings.erb'
#   notifies :restart, 'mysql_service[foo]'
#   action :create
# end

mysql_client 'default' do
  action :create
end


#This comes from a different cookbook database
#https://github.com/opscode-cookbooks/database

# mysql_connection_info = {
#     :host     => node[:magento][:db][:host],
#     :username => 'root',
#     :password => node['mysql']['server_root_password']
# }

# create a mysql user but grant no privileges
# mysql_database_user node[:magento][:db][:username] do
#   connection mysql_connection_info
#   password node[:magento][:db][:username]
#   action :create
# end

# grant all privileges on all databases/tables from 127.0.0.1
# mysql_database_user node[:magento][:db][:username] do
#   connection mysql_connection_info
#   password node[:magento][:db][:password]
#   action :grant
# end