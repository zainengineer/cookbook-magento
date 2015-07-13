case node['platform_family']
when 'rhel', 'fedora'
    #TODO detect which version do not have git support
    if node['platform_version'].to_i < 5.2
        node.set[:git][:version] = '1.7.9'
        node.set[:git][:url] = 'http://git-core.googlecode.com/files/git-1.7.9.tar.gz'
        node.set[:git][:checksum] = 'http://git-core.googlecode.com/files/git-1.7.9.tar.gz'
        Chef::Log.info "installing git 1.7.9 from source "
    end
else
#     include_recipe 'git'
end

include_recipe 'git'