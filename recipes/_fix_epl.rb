#TODO: install require modules for ssl and then enable https back again
case node['platform_family']
when 'rhel', 'fedora'
    if node['platform_version'].to_f < 6.5
        #remove https from epl repository, otherwise it will error
        #https://community.hpcloud.com/article/centos-63-instance-giving-cannot-retrieve-metalink-repository-epel-error
        #http://serverfault.com/questions/637549/epel-repo-for-centos-6-causing-error
        Chef::Log.info "fixing epl (removeing https from mirror) "
        myCommand = 'sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo &&  sed -i "s/gpgkey=https/gpgkey=http/" /etc/yum.repos.d/epel.repo'
        execute "fix_epl" do
          command myCommand
          action :run
          only_if { ::File.exists?('/etc/yum.repos.d/epel.repo') }
        end
        package 'ca-certificates' do
            action :upgrade
        end
        myCommand = 'sed -i "s/mirrorlist=http/mirrorlist=https/" /etc/yum.repos.d/epel.repo &&  sed -i "s/gpgkey=http/gpgkey=https/" /etc/yum.repos.d/epel.repo'
        execute "fix_epl" do
          command myCommand
          action :run
          only_if { ::File.exists?('/etc/yum.repos.d/epel.repo') }
        end
#         file '/etc/yum.repos.d/remi.repo' do
#           action :delete
#           only_if { ::File.exists?('/etc/yum.repos.d/remi.repo') }
#         end
        Chef::Log.info "disabling remi repository "
        yum_repository 'remi' do
#           action :delete
            enabled false
            ignore_failure true
            #action :makecache
        end
    end
end