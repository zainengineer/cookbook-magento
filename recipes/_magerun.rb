include_recipe 'magerun'
include_recipe '::_pipe_viewer'

# link to create
targetFile = '/usr/local/bin/n98-magerun.phar'

#file that already exists
linkTo =  'n98-magerun';

link linkTo do
  link_type                  :symbolic
  #mode                       Integer, String
  #owner                      Integer, String
  target_file                targetFile # defaults to 'name' if not specified
  to                         linkTo
  #ignore_failure             true
  action                     :create
end
