class Build
  def Build.configure(config, settings)

    # Configure The Box
    config.vm.box = "ubuntu/bionic64"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.7.7"

    if settings['networking'][0]['public']
      config.vm.network "public_network", type: "dhcp"
    end

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
      vb.customize ["modifyvm", :id, "--audio", "none", "--usb", "off", "--usbehci", "off"]
      vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    end

    # Configure Port Forwarding To The Box
    # config.vm.network "forwarded_port", guest: 80, host: 8000
    # config.vm.network "forwarded_port", guest: 443, host: 44300
    # config.vm.network "forwarded_port", guest: 3306, host: 33060

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"] ||= "tcp"
      end
    end

    # Register All Of The Configured Shared Folders
    if settings['folders'].kind_of?(Array)
      settings["folders"].each do |folder|
        config.vm.synced_folder folder["map"], folder["to"], owner: folder["owner"] ||= nil, group: folder["group"] ||= nil
      end
    end

#    config.vm.provision :shell, path: "bootstrap.sh"
    config.vm.provision "shell" do |s|
        s.path = "bootstrap.sh"
        s.args = Array.new
        if settings["nginx"]["mode"] ||= false
          s.args << "--nginx"
          s.args << settings["nginx"]["mode"]
        end
        
        if settings["mysql"]["password"] ||= false
          s.args << "--mysql"
          s.args << settings["mysql"]["password"]
        else
          s.args << "--mysql"
          s.args << "vagrant" # default password
        end
        
        if settings["php"]["version"] ||= false
          s.args << "--php"
          s.args << settings["php"]["version"]
        end
    end
  end
end
