#Without it I cannot install php-mcrypt
#http://stackoverflow.com/questions/17109818/install-php-mcrypt-on-centos-6
case node['platform_family']
when 'rhel', 'fedora'
    if node['platform_version'].to_f < 6.5
        execute 'upgrade_epl' do
          command 'wget http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && rpm -ivh epel-release-6-8.noarch.rpm'
          ignore_failure true
        end
    end
end