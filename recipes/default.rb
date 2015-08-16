# coding: utf-8
  # BOF: Initialization block

#This will add more sources in default repository for ubuntu
include_recipe '::_ubuntu'
#adding this recipie will automatically do
# apt-get update

include_recipe 'apt'

  #git is needed for some installations like n98 etc
include_recipe '::_fix_epl'
  include_recipe '::_git'
  include_recipe '::_epel_update'
#   case node['platform_family']
#   when 'rhel', 'fedora'
#     include_recipe 'yum'
#     include_recipe 'yum-epel'
#   else
#     include_recipe 'apt'
#   end
#   include_recipe '::_fix_epl'
  enc_key = nil # magento encryption key
  webserver = node[:magento][:webserver]
  user = node[:magento][:user]
  group = node[webserver]['group']

  user "#{user}" do
    comment 'magento guy'
    home node[:magento][:dir]
    system true
  end
  # EOF: Initialization block

  # Centos Polyfills
  #package 'libmcrypt' if platform?('centos', 'redhat')


   db_recipe = "::_db_#{node[:magento][:database]}"
   Chef::Log.info "adding database recipe: "  + db_recipe
   include_recipe db_recipe


web_recipe = "::_web_#{node[:magento][:webserver]}"
# Chef::Log.info "adding web recipe: " + web_recipe
include_recipe web_recipe
  include_recipe '::_php'

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

# file node[:magento][:install_flag] do
#     owner 'root'
#     group 'root'
#     mode '0655'
#     content Time.new.to_s
#     action :create_if_missing
# end
#include_recipe '::_fix_epl'
include_recipe 'system'
include_recipe '::_firewall'
include_recipe "nodejs"