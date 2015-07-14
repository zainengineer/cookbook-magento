#include_recipe '::_fix_epl'
case node['platform_family']
when 'rhel', 'fedora'
    if node['platform_version'].to_f < 5.2
        Chef::Log.info "Removing existing packages"
        node[:magento][:packages].each do |pkg|
            package pkg do
              action :remove
              ignore_failure true
            end
        end
    end
end
# Install required packages
node[:magento][:packages].each do |pkg|
    package pkg do
      action :install
    end
end