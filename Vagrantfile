Vagrant.configure("2") do |config|
  config.vm.box      = 'precise32'
  config.vm.box_url  = 'http://files.vagrantup.com/precise32.box'
  config.vm.hostname = 'dev-box'
  
  config.vm.network :forwarded_port, guest: 3000, host: 3001

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifest'
  end
end