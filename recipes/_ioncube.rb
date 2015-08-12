if node[:magento][:ioncube]
    include_recipe "php-ioncube::install"
end