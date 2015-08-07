include_recipe 'firewall'
firewall 'ufw' do
  action :disable
end

service "iptables" do
  action :stop
end