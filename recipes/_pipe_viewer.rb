case node['platform_family']
when 'rhel', 'fedora'
    yum_repository 'zenoss' do
      description "RPMs from ivarch.com for pipeviewer"
      baseurl "http://www.ivarch.com/programs/rpms/$basearch/"
      gpgkey 'http://www.ivarch.com/personal/public-key.txt'
      action :create
    end
    yum_package 'pv' do
      action :install
    end
else

end