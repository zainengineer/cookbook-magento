# coding: utf-8
include_recipe 'git'
  # BOF: Initialization block
  case node['platform_family']
  when 'rhel', 'fedora'
    include_recipe 'yum'
    include_recipe 'yum-epel'
  else
    include_recipe 'apt'
  end
  include_recipe 'php'
  enc_key = nil # magento encryption key
  webserver = node[:magento][:webserver]
  user = node[:magento][:user]
  group = node[webserver]['group']
  php_conf =  if platform?('centos', 'redhat')
                ['/etc', '/etc/php.d']
              else
                ['/etc/php5/fpm', '/etc/php5/cli/conf.d']
              end

  user "#{user}" do
    comment 'magento guy'
    home node[:magento][:dir]
    system true
  end
  # EOF: Initialization block

  # Install php-fpm package
  include_recipe 'php-fpm'

  # Centos Polyfills
  package 'libmcrypt' if platform?('centos', 'redhat')

  # Install required packages
  node[:magento][:packages].each do |pkg|
    package pkg do
      action :install
    end
  end

  # Ubuntu Polyfills
  if platform?('ubuntu', 'debian')
    bash 'Tweak CLI php.ini file' do
      cwd '/etc/php5/cli'
      code <<-EOH
      sed -i 's/memory_limit = .*/memory_limit = 128M/' php.ini
      sed -i 's/;realpath_cache_size = .*/realpath_cache_size = 32K/' php.ini
      sed -i 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/' php.ini
      EOH
    end
  end

  bash 'Tweak apc.ini file' do
    cwd php_conf[1] # module ini files
    code <<-EOH
    grep -q -e 'apc.stat=0' apc.ini || echo "apc.stat=0" >> apc.ini
    EOH
  end

  bash 'Tweak FPM php.ini file' do
    cwd php_conf[0] # php.ini location
    code <<-EOH
    sed -i 's/memory_limit = .*/memory_limit = 128M/' php.ini
    sed -i 's/;realpath_cache_size = .*/realpath_cache_size = 32K/' php.ini
    sed -i 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/' php.ini
    EOH
    notifies :restart, resources(service: 'php-fpm')
  end


web_recipe = "magento::_web_#{node[:magento][:webserver]}"
Chef::Log.info "adding web recipe: " + web_recipe
include_recipe web_recipe

directory node[:magento][:dir] do
    owner user
    group group
    mode 0755
    action :create
    recursive true
end

directory node[:magento][:dir] do
    owner user
    group group
    mode 0755
    action :create
    recursive true
end

#####################################################
#           Fresh Magento Install                   #
#####################################################

if node[:magento][:fresh_install] && ! (File.exist? node[:magento][:install_flag])

  # Fetch magento release
  unless node[:magento][:url].empty?
    remote_file "#{Chef::Config[:file_cache_path]}/magento.tar.gz" do
      source node[:magento][:url]
      mode 0644
    end
    execute 'untar-magento' do
      cwd node[:magento][:dir]
      command <<-EOH
      tar --strip-components 1 -xzf \
      #{Chef::Config[:file_cache_path]}/magento.tar.gz
      EOH
    end
  end


  # Generate local.xml file
  if enc_key
    template File.join(node[:magento][:dir], 'app', 'etc', 'local.xml') do
      source 'local.xml.erb'
      mode 0600
      owner node[:magento][:user]
      variables(
        db_config: db_config,
        enc_key: enc_key,
        session: node[:magento][:session],
        inst_date: inst_date
      )
    end
  end

  bash 'Ensure correct permissions & ownership' do
    cwd node[:magento][:dir]
    code <<-EOH
    chown -R #{user}:#{group} #{node[:magento][:dir]}
    chmod -R o+w media
    chmod -R o+w var
    EOH
  end

##end of fresh install
end

# Setup Database
# if Chef::Config[:solo]
db_config = node[:magento][:db]

# else
  # FIXME: data bags search throwing 404 error: Net::HTTPServerException
  # db_config = search(:db_config, "id:master").first ||
  #                                                    {:host => 'localhost'}
  # db_user = search(:db_users, "id:magento").first || node[:magento][:db]
  # enc_key = search(:magento, "id:enckey").first
# end

if db_config[:host] == 'localhost'
   db_recipe = "magento::_db_#{node[:magento][:database]}"
   Chef::Log.info "adding database recipe: "  + db_recipe
   include_recipe db_recipe
end

file node[:magento][:install_flag] do
    owner 'root'
    group 'root'
    mode '0655'
    content Time.new.to_s
    action :create_if_missing
end

include_recipe 'system'
include_recipe 'magerun'
include_recipe 'composer'