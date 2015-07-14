case node['platform_family']
when 'rhel', 'fedora'
    #TODO detect which version do not have git support
    if node['platform_version'].to_f < 5.2

#         Chef::Log.info "enabling remi repository "
        node.set['php-fpm']['skip_repository_install'] = true
#         yum_repository 'remi' do
#             enabled true
#             action :makecache
#         end
        include_recipe 'php-fpm'
#         Chef::Log.info "disabling remi repository "
#         yum_repository 'remi' do
#             enabled false
#             action :makecache
#         end

    else
        include_recipe 'php-fpm'
    end
else
    include_recipe 'php-fpm'
end