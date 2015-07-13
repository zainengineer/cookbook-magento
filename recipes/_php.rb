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
    # shasum php-5.3.29.tar.gz -a 256
    node.set[:php][:checksum] = '57cf097de3d6c3152dda342f62b1b2e9c988f4cfe300ccfe3c11f3c207a0e317'

    node.set[:magento][:packages] = %w()
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

  # Install php-fpm package
   include_recipe 'php-fpm'

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

include_recipe 'magerun'
include_recipe 'composer'
include_recipe 'xdebug'

# Install required packages
  node[:magento][:packages].each do |pkg|
    package pkg do
      action :install
    end
  end