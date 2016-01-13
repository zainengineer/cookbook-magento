if node[:magento][:redis]
    include_recipe 'redisio'
    include_recipe 'redisio::enable'
end