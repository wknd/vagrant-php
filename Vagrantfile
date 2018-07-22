# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'yaml'

if File.file?("./config.yaml")
  configFile = File.expand_path("./config.yaml")
  
elsif File.file?("./vagrantconfig.yaml")
  configFile = File.expand_path("./vagrantconfig.yaml")

elsif File.file?("../vagrantconfig.yaml")
  configFile = File.expand_path("../vagrantconfig.yaml")
  
elsif File.file?("./config.yaml")
  configFile = File.expand_path("../config.yaml")
  
else
  abort("can't find config file")
end
require_relative 'setup.rb'

Vagrant.configure(2) do |config|

  Build.configure(config, YAML::load(File.read(configFile)))

end
