# -*- mode: ruby -*-
# vi: set ft=ruby :

#Allow local overrides to change ip
defaultConfig = {
    memory: 2048,
    ip:  '192.168.38.56',
    sync_method: :share
}
vagrantConfig = defaultConfig
if (Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('1.9') )
    if File.exists?('vagrant.local.yaml')
        require 'yaml'
        localConfig = YAML.load_file('vagrant.local.yaml')
        vagrantConfig = defaultConfig.merge!(localConfig)
    end
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", vagrantConfig[:memory]]
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    v.customize ["modifyvm", :id, "--vram", "50"]
  end


  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: vagrantConfig[:ip]
  #config.vm.network "private_network", ip: "192.168.40.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  if vagrantConfig[:sync_method].to_sym == :rsync
    config.vm.synced_folder ".", "/var/www/cp",
          type: "rsync",
          create: "true" ,
          rsync__auto: true,
          rsync__exclude: "sql_dumps",
          rsync__chown: false,
          rsync__args: ["--verbose", "--archive", "--delete", "-z"]
  else
    config.vm.synced_folder ".", "/var/www/cp", :mount_options => ["dmode=777","fmode=777"]
  end


  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.provision "chef_solo" do |chef|
    #just adding the recipie in berkshelf file is not enough.
    #It will simply install nginx recipie in host(your) home directory
    #including it will actually execute it
   #chef.add_recipe "magento"

    chef.json = {
            :php => {
#                 :version => "5.3"
            },
            :magento => {
                :run_codes => {
                    'vagrant.one-website.com' => 'base',
                    'vagrant.second-website.com' => 'second'
                },
                :run_type => 'website',
                :webserver => 'apache2',
                :server_params => {
                    :MAGE_IS_DEVELOPER_MODE => 'true'
                }
            }
        }
  end
  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end