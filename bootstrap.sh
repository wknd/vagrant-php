#!/usr/bin/env bash

echo "updating"
apt-get -y update
apt-get -y upgrade

echo "----installing packages----"
echo "installing nginx"
apt-get install -y nginx

echo "installing mysql"
debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
apt-get install -y mysql-server mysql-client

echo "installing php"
apt-get install -y php7.2-dev php7.2-cli php7.2-fpm php7.2-mysql php7.2-json

if [ "$1" = "nginx" ]; then
    echo "setting proper nginx config"
    case "$2" in
        phpbb)
            echo "setting things up for PHPBB"
            cp /vagrant/configs/nginx.phpbb.conf /etc/nginx/sites-available/default
            ;;
    esac
    echo "restarting services"
    service nginx restart
    service php7.2-fpm restart
fi

