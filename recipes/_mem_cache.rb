if node[:magento][:mem_cache]
  php_pear "memcache" do
    action :install
  end
end