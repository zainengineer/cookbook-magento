case node['platform_family']
when 'rhel', 'fedora'
    #TODO detect which version do not have git support
    if node['platform_version'].to_f < 5.2
        node.set[:git][:version] = '1.7.9'
        node.set[:git][:url] = 'http://git-core.googlecode.com/files/git-1.7.9.tar.gz'
        node.set[:git][:checksum] = 'dd9dfcf1da59f09c4b66b53836b56fcb2208d0be9edf1f8b9079c7e980435086'
        Chef::Log.info "installing git 1.7.9 from source "
        #This should not be needed but in one case. Built essential was missing
        #added to debug why it is not working
        include_recipe 'build-essential::default'
        include_recipe 'git::source'
    else
        include_recipe 'git'
    end
else
    include_recipe 'git'
end