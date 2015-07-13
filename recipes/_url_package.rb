node[:magento][:url_package].each do |packageInfo|
    Chef::Log.info "installing package "
    Chef::Log.info packageInfo
    packageUrl = packageInfo[:url].to_s
    packageName = packageInfo[:name].to_s
    checkSum = packageInfo[:checksum].to_s
    fileName = File.basename(packageUrl)
    localPath = '/tmp/url_package' + fileName
    remote_file localPath do
        source packageUrl
        mode 0644
        #curl ftp://rpmfind.net/linux/mageia/distrib/2/x86_64/media/core/updates/php-mysql-5.3.27-1.2.mga2.x86_64.rpm | shasum -a 256
        checksum checkSum
    end
    package packageName do
      source localPath
      action :install
      allow_downgrade true
    end
end