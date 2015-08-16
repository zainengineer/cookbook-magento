# vagrantConfigFile = node[:magento][:dir] + '/app/etc/local.xmlvagrant';
# targetFile = node[:magento][:dir] + '/app/etc/local.xml';
# linkTo =  'local.xmlvagrant';
# if File.exist?(vagrantConfigFile)
#     link vagrantConfigFile do
#       link_type                  :symbolic
#       #mode                       Integer, String
#       #owner                      Integer, String
#       target_file                targetFile # defaults to 'name' if not specified
#       to                         linkTo
#       #ignore_failure             true
#       action                     :create
#     end
# end