php_conf =  if platform?('centos', 'redhat')
                ['/etc', '/etc/php.d']
              else
                ['/etc/php5/fpm', '/etc/php5/cli/conf.d']
              end

if node[:php][:version].to_s == '5.3'
    node.set[:xdebug][:version] = '2.2.7'
    node.set[:php][:version] = '5.3.29'
    node.set[:php][:install_method] = 'source'
    # online suggests  https://coderwall.com/p/bbfjrw/calculate-checksum-for-chef-s-remote_file-resource suggests shaphp-5.3.29.tar.gz| cut -c-12
    # shasum  -a 256 php-5.3.29.tar.gz
    node.set[:php][:checksum] = '57cf097de3d6c3152dda342f62b1b2e9c988f4cfe300ccfe3c11f3c207a0e317'

     #node.set[:magento][:packages] = %w(php-cli php-common php-curl php-gd  php-mcrypt php-pear php-apc php-xml)
    node.set[:magento][:packages] = %w()
    node.set[:magento][:url_package] = node[:magento][:url_package_5_3]
#     php_pear "PDO" doXML_RPCXML_RPC
#       action :install
#     end
#     package "bison" do
#         :remove
#     end
#
# #     bisonLibLocalPath  = "/tmp/libbison#{version}_#{arch}.deb"
#     bisonLibLocalPath  = "/tmp/libbison-dev_2.5.dfsg-2.1_amd64.deb"
# #     bisonLibRemoteUrl = "http://launchpadlibrarian.net/140087283/libbison-dev_#{version}.dfsg-1_#{arch}.deb";
#     bisonLibRemoteUrl = "http://launchpadlibrarian.net/96013406/libbison-dev_2.5.dfsg-2.1_amd64.deb";
#
#     remote_file bisonLibLocalPath do
#       source bisonLibRemoteUrl
#       mode 0644
# #       checksum "" # PUT THE SHA256 CHECKSUM HERE
#     end
#
#     dpkg_package "libbison" do
#       source bisonLibLocalPath
#       action :install
#     end
#
# #     bisonLocalPath  = "/tmp/libbison#{version}_#{arch}.deb"
#     bisonLocalPath  = "/tmp/bison_2.5.dfsg-2.1_amd64.deb"
# #     bisonRemoteUrl = "http://launchpadlibrarian.net/140087283/libbison-dev_#{version}.dfsg-1_#{arch}.deb";
#     bisonRemoteUrl = "http://launchpadlibrarian.net/96013405/bison_2.5.dfsg-2.1_amd64.deb";
#
#     remote_file bisonLocalPath do
#       source bisonRemoteUrl
#       mode 0644
# #       checksum "" # PUT THE SHA256 CHECKSUM HERE
#     end
#
#     dpkg_package "libbison" do
#       source bisonLocalPath
#       action :install
#     end

end
include_recipe 'php'
include_recipe '::_url_package'

  # Install php-fpm package
include_recipe '::_php_fpm'

include_recipe 'composer'
include_recipe '::_xdebug'
include_recipe '::_magento_packages'
include_recipe '::_ioncube'

service "php-fpm" do
  service_name('php5-fpm') if platform_family?('debian')
  action :restart
  provider(Chef::Provider::Service::Upstart)if (platform?('ubuntu') && node['platform_version'].to_f >= 14.04)
end