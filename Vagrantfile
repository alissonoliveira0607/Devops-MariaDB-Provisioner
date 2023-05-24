Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.network "private_network", ip:"27.78.101.50"
    config.vm.hostname = "mariadb"
    config.vm.network "forwarded_port", guest: 3306,host: 3306
    config.vm.provision "shell", path: "provisioner/provisioner_mariadb.sh"
    config.vm.provider :virtualbox do |v|
      v.name = "MARIADB" 
    end
  end
  