#!/usr/bin/env bash

echo -e "\e[0m----\e[35mupdating\e[0m----"
apt-get -y -qq update
echo -e "\e[0m" # resetting terminal colors and what not 
apt-get -y -qq upgrade
echo -e "\e[0m"

echo -e "\e[0m----\e[35mparsing arguments\e[0m----"
# stolen from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# allowing for space separated arguements
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -m|--mysql) # set mysql password
    MYSQLPASSWD="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--nginx)
    NGINXMODE="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--php)
    PHPVERSION="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters



echo -e "\e[0m----\e[35minstalling packages\e[0m----"
echo -e "\e[94minstalling nginx\e[0m"
apt-get install -qq -y nginx
echo -e "\e[0m"

echo -e "\e[94minstalling mysql\e[0m"
if [ -z ${MYSQLPASSWD+x} ]; then
    echo -e '\e[31mERROR: MySQL root password \e[1mnot\e[21m set\e[0m'
else
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password '"$MYSQLPASSWD"
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '"$MYSQLPASSWD"
  apt-get install -qq -y mysql-server mysql-client
  echo -e "\e[0m"
fi

echo -e "\e[94minstalling php\e[0m"
if [ -z ${PHPVERSION+x} ]; then
  echo -e "\e[93mWARNING: php version not specified, using \e[1m7.2\e[0m"
  PHPVERSION='7.2'
  apt-get install -qq -y php"$PHPVERSION"-dev php"$PHPVERSION"-cli php"$PHPVERSION"-fpm php"$PHPVERSION"-mysql php"$PHPVERSION"-json
else
  echo -e "\e[94minstalling php version $PHPVERSION\e[0m"
  apt-get install -qq -y php"$PHPVERSION"-dev php"$PHPVERSION"-cli php"$PHPVERSION"-fpm php"$PHPVERSION"-mysql php"$PHPVERSION"-json
fi

echo -e "\e[0m"
if [ -z ${NGINXMODE+x} ]; then
  echo -e "\e[93mWARNING: no nginx config specified, using system default\e[0m"
else
  echo "\e[94msetting proper nginx config\e[0m"
  case "$NGINXMODE" in
      phpbb)
          echo "\e[0msetting things up for PHPBB"
          cp /vagrant/configs/nginx.phpbb.conf /etc/nginx/sites-available/default
          if [ -z ${MYSQLPASSWD+x} ]; then
              echo -e "\e[31mERROR: MySQL root password \e[1mnot\e[21m set, can't create db for phpbb\e[0m"
          else
              mysql -u root -p"$MYSQLPASSWD" < /vagrant/configs/mysql.phpbb.sql
          fi
          ;;
  esac
  echo "\e[94restarting services\e[0m"
  service nginx restart
  service php7.2-fpm restart
fi
