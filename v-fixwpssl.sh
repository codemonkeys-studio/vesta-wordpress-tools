#!/bin/bash
# This script installs a let's encrypt ssl cert for a Wordpress installation, if it's not installed and performs a search and replace operation in the database to replace http with https
#
#

#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

#Check if wp-cli is installed and the offer to install it
if ! [ -x "$(command -v wp)" ]; then
    echo -e "${RED}WP-CLI is absolutely necessary for this script to run and it is not installed!${NC}";
    read -p "Do you want to install it? (It's perfectly safe) (y/n) [y]: " wpcli
    wpcli=${wpcli:-y}
    if [ "$wpcli" = "y" ]
    then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
    else
        echo -e "${RED}Aborting!${NC}";
        exit 0
    fi
fi

echo -e "${YELLOW}Please, enter vesta username and domain for the website you want to install the ssl and or fix the database${NC}"

read -p "USERNAME : " user
if [[ -z "$user" ]]
then
   echo -e "${RED}Invalid Username!${NC}";
   exit 0
fi
read -p "DOMAIN : " domain
if [[ -z "$domain" ]]
then
   echo -e "${RED}Invalid Domain!${NC}";
   exit 0
fi

WEB_DIRECTORY=/home/$user/web/$domain/public_html
NGINX_CONF_PATH=/home/$user/conf/web/${domain}.nginx.ssl.conf
if [ ! -f "$NGINX_CONF_PATH" ]
then
    echo -e "${YELLOW}It seems that you do not have an SSL certificate installed. Do you want to install one now?${NC}"
    read -p "Issue Let's Encrypt SSL cert for ${domain} ? (y/n) [y]: " ssl
    ssl=${ssl:-y}
    if [ "$ssl" = "y" ]
    then
        read -p "Issue Let's Encrypt SSL SSL cert for www.${domain}? (y/n) [y]: " sslwww
        sslwww=${sslwww:-y}
    else
        sslwww=n
    fi

    if [ "$ssl" = "y" ]
    then
        if [ "$sslwww" = "y" ]
        then
            v-add-letsencrypt-domain $user $domain www.$domain
        else
            v-add-letsencrypt-domain $user $domain
        fi
        echo -e "${YELLOW}Setting up redirection to HTTPS in new website's nginx config and restarting nginx${NC}"
        sed -i '4ireturn 301 https://$host$request_uri;' /home/$user/conf/web/${domain}.nginx.conf
        service nginx restart
        echo -e "${GREEN}All Done! ${NC}"
    fi
fi
cd $WEB_DIRECTORY
db_home_url=$(sudo -u $user wp option get home)
wpconfig_home_url=$(sudo -u $user wp config get WP_HOME)
active_home_var=db
if [[ $wpconfig_home_url == *"Error"* ]]
then
    home_url=$db_home_url
else
    home_url=$wpconfig_home_url
    active_home_var=config
fi


fixed_home_url="${home_url/http/https}"
echo -e "${YELLOW}We will now search the database for instances of ${home_url} and replace it with ${fixed_home_url}! ${NC}";
sudo -u $user wp search-replace "${home_url}" "${fixed_home_url}"
if [ "$active_home_var" == "config" ]
then
    echo -e "${YELLOW}Now searching the wp-config.php file for ${home_url} and replacing it with ${fixed_home_url} ${NC}";
    sed -i -e s+${home_url}+${fixed_home_url}/+g ./wp-config.php
fi
echo -e "${GREEN}All Done!${NC}";
