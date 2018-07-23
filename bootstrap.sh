#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

echo -e "\e[0m----\e[35mupdating\e[0m----"
apt-get -qq -y update > /dev/null
echo -e "\e[0m" # resetting terminal colors and what not 
apt-get -qq -y upgrade > /dev/null
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
    -m|--mode)
    MODE="$2"
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
apt-get -qq -y install nginx > /dev/null
echo -e "\e[0m"

echo -e "\e[94minstalling mysql\e[0m"
if [ -z ${MYSQLPASSWD+x} ]; then
    echo -e '\e[31mERROR: MySQL root password \e[1mnot\e[21m set\e[0m'
else
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password '"$MYSQLPASSWD"
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '"$MYSQLPASSWD"
  apt-get -qq -y install mysql-server mysql-client > /dev/null
  echo -e "\e[0m"
fi

echo -e "\e[94minstalling php\e[0m"
if [ -z ${PHPVERSION+x} ]; then
  echo -e "\e[93mWARNING: php version not specified, using \e[1m7.2\e[0m"
  PHPVERSION='7.2'
  apt-get -qq -y install php"$PHPVERSION"-dev php"$PHPVERSION"-cli php"$PHPVERSION"-fpm php"$PHPVERSION"-mysql php"$PHPVERSION"-json > /dev/null
else
  echo -e "\e[94minstalling php version $PHPVERSION\e[0m"
  apt-get -qq -y install php"$PHPVERSION"-dev php"$PHPVERSION"-cli php"$PHPVERSION"-fpm php"$PHPVERSION"-mysql php"$PHPVERSION"-json > /dev/null
fi

echo -e "\e[0m"
if [ -z ${MODE+x} ]; then
  echo -e "\e[93mWARNING: no nginx config specified, using system default\e[0m"
else
  echo -e "\e[94msetting proper nginx config\e[0m"
  case "$MODE" in
      phpbb)
          echo -e "\e[0msetting things up for PHPBB"
          cp /vagrant/configs/phpbb/nginx.phpbb.conf /etc/nginx/sites-available/default
          if [ -z ${MYSQLPASSWD+x} ]; then
              echo -e "\e[31mERROR: MySQL root password \e[1mnot\e[21m set, can't create db for phpbb\e[0m"
          else
              sed -e "s/--DATABASE--/$databasename/g" -e "s/--USERNAME--/$username/g" -e "s/--PASSWORD--/$password/g" /vagrant/configs/phpbb/mysql.phpbb.sql | mysql -u root -p"$MYSQLPASSWD"
          fi
          ;;
      symfony-dev)
          echo -e "\e[0msetting things up for symfony development"
          
          echo -e "\e[0minstalling extra php dependencies"
          apt-get -qq -y install php"$PHPVERSION"-zip > /dev/null
          
          echo -e "\e[0minstalling composer"
          EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
          php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
          ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")"

          if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
          then
              >&2 echo 'ERROR: Invalid installer signature'
              rm composer-setup.php
              exit 1
          fi

          php composer-setup.php --quiet
          RESULT=$?
          rm composer-setup.php
          mv composer.phar /usr/local/bin/composer
          
          echo -e "\e[0mcreating db and user for symfony"
          if [ -z ${MYSQLPASSWD+x} ]; then
              echo -e "\e[31mERROR: MySQL root password \e[1mnot\e[21m set, can't create db for symfony\e[0m"
          else
              sed -e "s/--DATABASE--/$databasename/g" -e "s/--USERNAME--/$username/g" -e "s/--PASSWORD--/$password/g" /vagrant/configs/symfony/mysql.symfony.sql | mysql -u root -p"$MYSQLPASSWD"
          fi
          
      ;;
  esac
  echo -e "\e[94mrestarting services\e[0m"
  service nginx restart
  service php7.2-fpm restart
fi
