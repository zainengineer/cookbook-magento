if node['platform_family']=='debian'
    include_recipe 'ubuntu'
end


# template '/etc/apt/sources.list' do
#     mode 00644
#     variables(
#         :architectures => node['ubuntu']['architectures'],
#         :code_name => node['ubuntu']['codename'],
#         :security_url => node['ubuntu']['security_url'],
#         :archive_url => node['ubuntu']['archive_url'],
#         :include_source_packages => node['ubuntu']['include_source_packages'],
#         :components => node['ubuntu']['component_list']
#     )
#     notifies :run, 'execute[apt-get update]', :immediately
#     source 'sources.list.erb'
# end
#
# include_recipe 'apt'
#
# if node['ubuntu']['locale']
#
#     %w{ LC_ALL LANG }.each do |envvar|
#         execute "set_locale_#{envvar.downcase}" do
#             command "update-locale #{envvar}=#{node['ubuntu']['locale']}"
#             action :run
#             not_if "grep #{envvar}=#{node['ubuntu']['locale']} /etc/default/locale"
#         end
#     end
#
# end