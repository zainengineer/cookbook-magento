# coding: utf-8

db_installed_file = '/root/.magento.db.installed'

unless File.exist?(db_installed_file)

  include_recipe 'mysql::server'
  include_recipe 'mysql::client'
  include_recipe 'mysql_tuning::default'
  #include_recipe 'mysql-chef_gem'

  root_password = node[:mysql][:server_root_password]
  db_config = node[:magento][:db]

  #Executs the sql generated via erb template later
  #When template is created later, it calls execute via notifify
  #Although this code is interpreted first, command inside is executed later via notification
  execute 'mysql-install-mage-privileges' do
    command <<-EOH
    /usr/bin/mysql -u root -p#{root_password} < \
    /etc/mysql/mage-grants.sql
    EOH
    action :nothing
  end

  #database initialization script such as creating magento script
  #This script remains on the system so you can view it in hard coded /etc/mysql/mage-grants.sql
  #You can debug it too using
  # mysql -u root -p#{root_password} < /etc/mysql/mage-grants.sql
  template '/etc/mysql/mage-grants.sql' do
    path '/etc/mysql/mage-grants.sql'
    source 'grants.sql.erb'
    owner 'root'
    group 'root'
    mode 0600
    variables(database: node[:magento][:db])
    notifies :run, resources(execute: 'mysql-install-mage-privileges'),
             :immediately
  end

  # Save node data after writing the MYSQL root password, so that a failed
  # chef-client run that gets this far doesn't cause an unknown password to get
  # applied to the box without being saved in the node data.
  unless Chef::Config[:solo]
    ruby_block 'save node data' do
      block do
        node.save
      end
      action :create
    end
  end

  # Import Sample Data
  unless node[:magento][:sample_data_url].empty?
    include_recipe 'mysql::client'

    remote_file File.join(Chef::Config[:file_cache_path],
                          'magento-sample-data.tar.gz') do
      source node[:magento][:sample_data_url]
      mode 0644
    end

    bash 'magento-sample-data' do
      cwd "#{Chef::Config[:file_cache_path]}"
      code <<-EOH
        mkdir #{name}
        cd #{name}
        tar --strip-components 1 -xzf \
        #{Chef::Config[:file_cache_path]}/magento-sample-data.tar.gz
        mv media/* #{node[:magento][:dir]}/media/

        mv magento_sample_data*.sql data.sql 2>/dev/null
        /usr/bin/mysql -h #{db_config[:host]} -u #{db_config[:username]} \
        -p#{db_config[:password]} #{db_config[:database]} < data.sql
        cd ..
        rm -rf #{name}
      EOH
    end
  end

  include_recipe '::_symlink'

  file db_installed_file do
    owner 'root'
    group 'root'
    mode '0655'
    content Time.new.to_s
    action :create_if_missing
  end
end
