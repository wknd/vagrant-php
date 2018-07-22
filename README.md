Vagrant setup for php development. This will house the vagrant stuff and application specific nginx configs.

It was based on [spiritix vagrant-php7](https://github.com/spiritix/vagrant-php7) and [ncaroyannis vagrant-php7](https://github.com/ncaroyannis/vagrant-php7) but taking the best parts of both.

Based on a standard [ubuntu/bionic64](https://app.vagrantup.com/ubuntu/boxes/bionic64) box, with a nice ```config.yaml``` and ```setup.rb``` script, a ```bootstrap.sh``` that actually works and disabling the silly console that all these ubuntu boxes come with.

Simply create and modify ```config.yaml``` and do ```vagrant up```
the ```config.yaml``` file may optionally be called ```vagrantconfig.yaml``` and may exist in this projects root directory or in the parent directory.

If you're adding new nginx related stuff, add a config in the configs directory and add a new case for it in the bottom of ```bootstrap.sh```

