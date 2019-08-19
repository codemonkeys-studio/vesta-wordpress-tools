#!/bin/bash
# This script migrates a Wordpress installation to a new domain from the command line.
#

#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

declare -a WEBSITE_TEMPLATES




function generateConfig() {
    echo -e "${YELLOW}This is the first time you're running this script (or no config file found)!${NC}";
    echo -e "${YELLOW}Let's setup some default values!${NC}";

    echo -e "${GREEN}Step 1/6 - DEFAULT EMAIL${NC}";
    echo -e "${BLUE}The default email will be used as a suggested value for vesta and wordpress user creation${NC}";
    while [ -z "$DEFAULT_EMAIL" ]
    do
        read -p "Enter the default email: " DEFAULT_EMAIL
    done

    echo -e "${GREEN}Step 2/6 - DEFAULT FIRST NAME${NC}";
    echo -e "${BLUE}The default first name will be used as a suggested value for vesta user creation${NC}";
    while [ -z "$DEFAULT_FNAME" ]
    do
        read -p "Enter the default first name: " DEFAULT_FNAME
    done

    echo -e "${GREEN}Step 3/6 - DEFAULT LAST NAME${NC}";
    echo -e "${BLUE}The default last name will be used as a suggested value for vesta user creation${NC}";
    while [ -z "$DEFAULT_LNAME" ]
    do
        read -p "Enter the default last name: " DEFAULT_LNAME
    done

    echo -e "${GREEN}Step 4/6 - DEFAULT VESTA USER PACKAGE${NC}";
    echo -e "${BLUE}The default vesta user package will be used as a suggested value for vesta user account creation${NC}";
    while [ -z "$DEFAULT_VESTA_USER_PACKAGE" ]
    do
        read -p "Enter the default vesta user package: " DEFAULT_VESTA_USER_PACKAGE
    done

    echo -e "${GREEN}Step 5/6 - DEFAULT WEB DOMAIN BACKEND${NC}";
    echo -e "${BLUE}The default web domain backend will be used as a suggested value for the website creation${NC}";
    while [ -z "$DEFAULT_WEB_DOMAIN_BACKEND" ]
    do
        read -p "Enter the default web domain backend: " DEFAULT_WEB_DOMAIN_BACKEND
    done

    echo -e "${GREEN}Step 6/6 - WEBSITE TEMPLATES${NC}";
    echo -e "${BLUE}You can add some website templates that you can clone for your new projects${NC}";
    echo -e "${BLUE}For example an e-shop template with all the plugins than you ussually install in an e-commerce site${NC}";
    echo -e "${YELLOW}First enter the vesta user whose account has the template installed and then the domainn used for the template and press Return to continue with the next one${NC}";
    echo -e "${YELLOW}Press Return on an empty line to finish with the templates${NC}";
    # declare -a ACTIVATED_PLUGINS
    current_user="start"
    counter=1
    while [ ! -z "$current_user" ]
    do
        echo -e "${GREEN}Template $counter ${NC}";
        read -p "Vesta user: " current_user
        current_template=$current_user
        current_template+=" "
        read -p "Template Domain: " current_domain
        current_template+=$current_domain
        # echo $current_template
        # current_template="$current_user $current_domain"
        counter=$((counter+1))
        if [ ! -z "$current_template" ] && [ "$current_template" != " " ]
        then
            WEBSITE_TEMPLATES+=("$current_template")
        fi
    done
    # echo ${WEBSITE_TEMPLATES[*]}

    # Write the collected variables to a config file in the user's home dir
    CONFIG_PATH="${HOME}/.v-migratewp.config"
    echo "DEFAULT_EMAIL=${DEFAULT_EMAIL}" > $CONFIG_PATH
    echo "DEFAULT_FNAME=${DEFAULT_FNAME}" >> $CONFIG_PATH
    echo "DEFAULT_LNAME=${DEFAULT_LNAME}" >> $CONFIG_PATH
    echo "DEFAULT_VESTA_USER_PACKAGE=${DEFAULT_VESTA_USER_PACKAGE}" >> $CONFIG_PATH
    echo "DEFAULT_WEB_DOMAIN_BACKEND=${DEFAULT_WEB_DOMAIN_BACKEND}" >> $CONFIG_PATH
    for template in "${WEBSITE_TEMPLATES[@]}"
    do
            echo "WEBSITE_TEMPLATE=${template}" >> $CONFIG_PATH
    done
}

function readConfig() {
    typeset -A config # init array
    config=( # set default values in config array
        [DEFAULT_EMAIL]="test@example.com"
        [DEFAULT_FNAME]="Code"
        [DEFAULT_LNAME]="Monkeys"
        [DEFAULT_VESTA_USER_PACKAGE]="cm"
        [DEFAULT_WEB_DOMAIN_BACKEND]="cm"
    )



    while read line
    do
        if echo $line | grep -F = &>/dev/null
        then
            varname=$(echo "$line" | cut -d '=' -f 1)
            if [ "$varname" = "WEBSITE_TEMPLATE" ]
            then
                WEBSITE_TEMPLATES+=($(echo "$line" | cut -d '=' -f 2-))
            else
                config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
            fi
            # echo "$line" | cut -d '=' -f 2-
        fi
    done < ${HOME}/.v-migratewp.config

    # echo ${ACTIVATED_PLUGINS[*]}

    #DEFALUTS
    DEFAULT_EMAIL=${config[DEFAULT_EMAIL]}
    DEFAULT_FNAME=${config[DEFAULT_FNAME]}
    DEFAULT_LNAME=${config[DEFAULT_LNAME]}
    DEFAULT_VESTA_USER_PACKAGE=${config[DEFAULT_VESTA_USER_PACKAGE]}
    DEFAULT_WEB_DOMAIN_BACKEND=${config[DEFAULT_WEB_DOMAIN_BACKEND]}

}

if [ ! -f "${HOME}/.v-migratewp.config" ]; then
    generateConfig
    # exit 0
else
    readConfig
    # exit 0
fi

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

function generatePass() {
    length=18

    digits=({2..9})
    lower=({a..k} {m..n} {p..z})
    upper=({A..N} {P..Z})
    CharArray=(${digits[*]} ${lower[*]} ${upper[*]})
    ArrayLength=${#CharArray[*]}
    local password=""
    for i in `seq 1 $length`
    do
            index=$(($RANDOM%$ArrayLength))
            char=${CharArray[$index]}
            password=${password}${char}
    done
    echo $password
}

set_user_dir () {

    USERDIR=/home/$1

    if [ -d "$USERDIR" ]; then
        cd $USERDIR
    else
        read -p "CREATE USER ${destination_user} ? (y/n) [y]: " createuser
        createuser=${createuser:-y}

        if [ "$createuser" = "y" ]
        then

            while [ ${#destination_user} -gt 13 ]
            do
                echo -e "${RED}Username must be less than 13 characters long!${NC}";
                read -p "Pick a new Username : " destination_user
            done

            read -p "USER email ? [$DEFAULT_EMAIL]: " user_email
            user_email=${user_email:-"$DEFAULT_EMAIL"}
            read -p "USER First Name ? [$DEFAULT_FNAME]: " user_fname
            user_fname=${user_fname:-$DEFAULT_FNAME}
            read -p "USER Last Name ? [$DEFAULT_LNAME]: " user_lname
            user_lname=${user_lname:-$DEFAULT_LNAME}
            echo -e "${RED}Creating user ${user}!${NC}";


            user_pass=$(generatePass)

            echo -e "${YELLOW}USER PASSWORD ${user_pass} ${NC}"
            #USER PASSWORD EMAIL [PACKAGE] [FNAME] [LNAME]

            v-add-user $destination_user $user_pass $user_email $DEFAULT_VESTA_USER_PACKAGE $user_fname $user_lname

        else
            echo -e "${RED}Aborting!${NC}";
            exit 0

        fi


    fi

    DESTINATION_DIRECTORY=/home/$1/web/$2/public_html

    if [ -d "$DESTINATION_DIRECTORY" ]; then
        cd $DESTINATION_DIRECTORY
    else
        echo -e "${RED}Creating website!${NC}";
        v-add-domain $1 $2
        sleep 2
        cd /home/$1/web/$2/public_html
    fi
    v-add-web-domain-stats $1 $2 awstats
    v-add-web-domain-backend $1 $2 $DEFAULT_WEB_DOMAIN_BACKEND yes

    read -p "Issue Let's Encrypt SSL cert for ${2} ? (y/n) [y]: " ssl
    ssl=${ssl:-y}
    if [ "$ssl" = "y" ]
    then
        urlprefix="https://"
        read -p "Issue Let's Encrypt SSL SSL cert for www.${2}? (y/n) [y]: " sslwww
        sslwww=${sslwww:-y}
    else
        urlprefix="http://"
        sslwww = n
    fi

    if [ "$ssl" = "y" ]
    then
        if [ "$sslwww" = "y" ]
        then
            v-add-letsencrypt-domain $1 $2 www.$2
        else
            v-add-letsencrypt-domain $1 $2
        fi
        NGINX_CONF_PATH=/home/$1/conf/web/${2}.nginx.ssl.conf
        if [ -f "$NGINX_CONF_PATH" ]
        then
            echo -e "${YELLOW}Setting up redirection to HTTPS in new website's nginx config and restarting nginx${NC}"
            sed -i '4ireturn 301 https://$host$request_uri;' /home/$1/conf/web/${2}.nginx.conf
            service nginx restart
            echo -e "${GREEN}All Done! ${NC}"
        fi
    fi

}

function get_source_details() {
    echo -e "${YELLOW}Please, enter the source website details (vesta username and domain)${NC}"

    read -p "SOURCE USERNAME : " source_user
    if [[ -z "$source_user" ]]
    then
       echo -e "${RED}Invalid Username!${NC}";
       exit 0
    fi
    read -p "SOURCE DOMAIN : " source_domain
    if [[ -z "$source_domain" ]]
    then
       echo -e "${RED}Invalid Domain!${NC}";
       exit 0
    fi

    SOURCE_DIRECTORY=/home/$source_user/web/$source_domain/public_html/

    if [ ! -d "$SOURCE_DIRECTORY" ]; then
        echo -e "${RED}Invalid Username or domain!${NC}";
        exit 0
    fi
}

function get_destination_details() {
    echo -e "${YELLOW}Please, enter the destination website details (vesta username and domain)${NC}"
    read -p "DESTINATION USERNAME : " destination_user
    if [[ -z "$destination_user" ]]
    then
       echo -e "${RED}Invalid Username!${NC}";
       exit 0
    fi
    read -p "DESTINATION DOMAIN : " destination_domain
    if [[ -z "$destination_domain" ]]
    then
       echo -e "${RED}Invalid Domain!${NC}";
       exit 0
    fi
}

function choose_template() {
    echo -e "${YELLOW}Which website template do you want to use?${NC}"

    for i in "${!foo[@]}"; do
      printf "%s\t%s\n" "$i" "${foo[$i]}"
    done

    for template_index in "${!WEBSITE_TEMPLATES[@]}"
    do
        template=${WEBSITE_TEMPLATES[$template_index]}
        declare -a template_arr=()
        for word in $template
        do
            template_arr+=($word)
        done
        echo -e "${GREEN}Which website template do you want to use?${NC}"
        echo -e "${YELLOW}[$template_index]. Website ${template_arr[1]} from user ${template_arr[0]}? ${NC}"
    done
    read -p "What's your choice?: " chosen_template_index
    if [ ! -v "WEBSITE_TEMPLATES[$chosen_template_index]" ]
    then
        echo -e "${RED}Invalid Template Chosen!${NC}";
        exit 0
    fi

    chosen_template=${WEBSITE_TEMPLATES[$chosen_template_index]}
    declare -a chosen_template_arr=()
    for word in $chosen_template
    do
        chosen_template_arr+=($word)
    done
    source_user=${chosen_template_arr[0]}
    source_domain=${chosen_template_arr[1]}

    SOURCE_DIRECTORY=/home/$source_user/web/$source_domain/public_html/
}

if [ ${#WEBSITE_TEMPLATES[@]} -gt 0 ]
then
    read -p "Do you want to [C]lone a website template or [M]igrate a wordpress installation to a new domain?: " clone_or_migrate
    if [ "$clone_or_migrate" = "C" ] || [ "$clone_or_migrate" = "c" ]
    then
        choose_template
    elif [ "$clone_or_migrate" = "M" ] || [ "$clone_or_migrate" = "m" ]
    then
        get_source_details
    else
        echo -e "${RED}Invalid Choice!${NC}";
        echo -e "${RED}Now Exiting!${NC}";
        exit 0
    fi
else
    get_source_details
fi



get_destination_details

set_user_dir $destination_user $destination_domain

echo -e "${GREEN}Now copying files to the destination website!${NC}";
echo -e "${YELLOW}Depending on the size of the source website this may take some time!${NC}";
echo -e "${YELLOW}Please be patient!${NC}";

rsync -a $SOURCE_DIRECTORY $DESTINATION_DIRECTORY
echo -e "${GREEN}All Done!${NC}";
if [ $source_user != $destination_user ]
then
    echo -e "${YELLOW}Changing copied files owner to $destination_user !${NC}";
    chown -R $destination_user:$destination_user ${DESTINATION_DIRECTORY}/
    echo -e "${GREEN}All Done!${NC}";
fi

echo -e "${YELLOW}Creating Database for the Destination WordPress Installation${NC}"

read -p "Destination Database USER : ${destination_user}_" db_user

username_length=${#destination_user}
max_db_name_length=15
max_db_user_length=$((max_db_name_length-username_length))

while [ ${#db_user} -gt $max_db_user_length ]
do
    echo -e "${RED}Username must be less than $max_db_user_length characters long!${NC}";
    read -p "Pick a new Username : ${user}_" db_user
done

db_exists=true
while [ "$db_exists" == "true" ]
do
    db_exists=$(/usr/local/bin/v-dbexists $destination_user ${destination_user}_${db_user})
    if [ "$db_exists" == "true" ]
    then
        echo -e "${RED}Username or Databse already exists!${NC}";
        read -p "Pick a new Username : ${destination_user}_" db_user
        while [ ${#db_user} -gt $max_db_user_length ]
        do
            echo -e "${RED}Username must be less than $max_db_user_length characters long!${NC}";
            read -p "Pick a new Username : ${destination_user}_" db_user
        done
    fi
done

db_pass=$(generatePass)


echo -e "${YELLOW}Database PASSWORD for destination WordPress${NC}"
echo $db_pass

/usr/local/vesta/bin/v-add-database $destination_user $db_user $db_user $db_pass mysql localhost

echo -e "${GREEN}User and Database Created!"
echo -e "${YELLOW}Done creating Database USER & Database PASSWORD for destination WordPress${NC}"

sleep 2

echo -e "${YELLOW}Now Exporting source database and importing it to the destination database!${NC}";
cd $SOURCE_DIRECTORY
sudo -u $source_user wp db export ./db_export.sql
mv db_export.sql ${DESTINATION_DIRECTORY}/
cd $DESTINATION_DIRECTORY

#change wp-config.php with new db connection details
sudo -u $destination_user wp config set DB_NAME ${destination_user}_$db_user
sudo -u $destination_user wp config set DB_USER ${destination_user}_$db_user
sudo -u $destination_user wp config set DB_PASSWORD $db_pass
sed -i -e s+${SOURCE_DIRECTORY}+${DESTINATION_DIRECTORY}/+g ./wp-config.php
sed -i -e s+${source_domain}+${destination_domain}+g ./wp-config.php
if [ -f ${DESTINATION_DIRECTORY}/wordfence-waf.php ]
then
    sed -i -e s+${source_domain}+${destination_domain}+g ${DESTINATION_DIRECTORY}/wordfence-waf.php
fi
if [ -f ${DESTINATION_DIRECTORY}/.user.ini ]
then
    sed -i -e s+${source_domain}+${destination_domain}+g ${DESTINATION_DIRECTORY}/.user.ini
fi
sudo -u $destination_user wp db import db_export.sql
echo -e "${GREEN}All Done!${NC}";
echo -e "${YELLOW}Now searching the databse for $source_domain and replacing it with $destination_domain ${NC}";
sudo -u $destination_user wp search-replace "${source_domain}" "${destination_domain}"

new_db_home_url=$(sudo -u $destination_user wp option get home)
new_wpconfig_home_url=$(sudo -u $destination_user wp config get WP_HOME)
active_home_var=db
if [[ $new_wpconfig_home_url == *"Error"* ]] || [ -z $wpconfig_home_url ]
then
    new_home_url=$new_db_home_url
else
    new_home_url=$new_wpconfig_home_url
    active_home_var=config
fi
if [[ $new_home_url != *"https"* ]] && [ "$ssl" = "y" ]
then
    fixed_home_url="${new_home_url/http/https}"
    echo -e "${RED}Source website ${source_domain} didn't have SSL installed but new ${destination_domain} has! ${NC}";
    read -p "Do you want to search the database for instances of ${new_home_url} and replace it with ${fixed_home_url}? [y]: " replace_https
    replace_https=${replace_https:-y}
    if [ "$replace_https" = "y" ]
    then
        echo -e "${YELLOW}Now searching the database for ${new_home_url} and replacing it with ${fixed_home_url} ${NC}";
        sudo -u $destination_user wp search-replace "${new_home_url}" "${fixed_home_url}"
        if [ "$active_home_var" == "config" ]
        then
            echo -e "${YELLOW}Now searching the wp-config.php file for ${new_home_url} and replacing it with ${fixed_home_url} ${NC}";
            sed -i -e s+${new_home_url}+${fixed_home_url}/+g ./wp-config.php
        fi

    fi
    echo -e "${GREEN}All Done!${NC}";
fi

# Deactivate wordfence so that it will not cause any problems and all settings will be deleted
sudo -u $destination_user wp plugin is-active wordfence
if [ $? -eq 0 ]
then
    sudo -u $destination_user wp plugin deactivate wordfence
    if [ -f "${SOURCE_DIRECTORY}.user.ini" ]; then
        rm ${SOURCE_DIRECTORY}.user.ini
    fi
fi

sudo -u $destination_user wp plugin is-installed worker
if [ $? -eq 0 ]
then
    sudo -u $destination_user wp plugin is-active worker
    if [ $? -eq 0 ]
    then
        sudo -u $destination_user wp plugin deactivate worker
    fi
    # sudo -u $destination_user wp plugin delete worker
    sudo -u $destination_user wp option delete mwp_potential_key
    sudo -u $destination_user wp plugin activate worker
    managewp_activation_key=$(sudo -u $destination_user wp option get mwp_potential_key)
    echo -e "${RED}********************************************************* ${NC}"
    echo -e "${GREEN}ManageWP Activation Key: $managewp_activation_key"
    echo -e "${RED}********************************************************* ${NC}"
else
    echo -e "${GREEN}********************************************************* ${NC}"
    echo -e "${GREEN}ManageWP is NOT installed"
    echo -e "${GREEN}********************************************************* ${NC}"
    read -p "Do you want to  install it? (y/n) [y]: " installworker
    installworker=${installworker:-y}
    if [ "$installworker" = "y" ]
    then
        sudo -u $destination_user wp plugin install worker --activate
        managewp_activation_key=$(sudo -u $destination_user wp option get mwp_potential_key)
        echo -e "${GREEN}********************************************************* ${NC}"
        echo -e "${GREEN}ManageWP Activation Key: $managewp_activation_key"
        echo -e "${GREEN}********************************************************* ${NC}"
    fi
fi

sudo -u $destination_user wp plugin is-installed wordfence
if [ $? -eq 0 ]
then
    sudo -u $destination_user wp plugin activate wordfence
fi

admin_pass=$(generatePass)
sudo -u $destination_user wp user update 1 --user_pass=${admin_pass}
admin_username=$(sudo -u $destination_user wp user get 1 --field=login)
echo -e "${RED}********************************************************* ${NC}"
echo -e "${GREEN}New Password for admin user $admin_username : $admin_pass ${NC}"
echo -e "${RED}********************************************************* ${NC}"


echo -e "${GREEN}Migration Complete!${NC}";

