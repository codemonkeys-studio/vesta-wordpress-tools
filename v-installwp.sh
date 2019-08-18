#!/bin/bash
# This script installs WordPress from Command Line.


#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

declare -a ACTIVATED_PLUGINS=()
declare -a OPTIONAL_PLUGINS=()

function generateConfig() {
    echo -e "${YELLOW}This is the first time you're running this script (or no config file found)!${NC}";
    echo -e "${YELLOW}Let's setup some default values!${NC}";

    echo -e "${GREEN}Step 1/9 - DEFAULT EMAIL${NC}";
    echo -e "${BLUE}The default email will be used as a suggested value for vesta and wordpress user creation${NC}";
    while [ -z "$DEFAULT_EMAIL" ]
    do
        read -p "Enter the default email: " DEFAULT_EMAIL
    done

    echo -e "${GREEN}Step 2/9 - DEFAULT FIRST NAME${NC}";
    echo -e "${BLUE}The default first name will be used as a suggested value for vesta user creation${NC}";
    while [ -z "$DEFAULT_FNAME" ]
    do
        read -p "Enter the default first name: " DEFAULT_FNAME
    done

    echo -e "${GREEN}Step 3/9 - DEFAULT LAST NAME${NC}";
    echo -e "${BLUE}The default last name will be used as a suggested value for vesta user creation${NC}";
    while [ -z "$DEFAULT_LNAME" ]
    do
        read -p "Enter the default last name: " DEFAULT_LNAME
    done

    echo -e "${GREEN}Step 4/9 - DEFAULT VESTA USER PACKAGE${NC}";
    echo -e "${BLUE}The default vesta user package will be used as a suggested value for vesta user account creation${NC}";
    while [ -z "$DEFAULT_VESTA_USER_PACKAGE" ]
    do
        read -p "Enter the default vesta user package: " DEFAULT_VESTA_USER_PACKAGE
    done

    echo -e "${GREEN}Step 5/9 - DEFAULT WEB DOMAIN BACKEND${NC}";
    echo -e "${BLUE}The default web domain backend will be used as a suggested value for the website creation${NC}";
    while [ -z "$DEFAULT_WEB_DOMAIN_BACKEND" ]
    do
        read -p "Enter the default web domain backend: " DEFAULT_WEB_DOMAIN_BACKEND
    done

    echo -e "${GREEN}Step 6/9 - ACTIVATED PLUGINS${NC}";
    echo -e "${BLUE}Add some plugins that will be installed & activated automatically after the wordpress installation is finished.${NC}";
    echo -e "${BLUE}See the README file for instructions on what to use as the plugin's name${NC}";
    echo -e "${YELLOW}Enter the plugin's name and press Return to continue with the next plugin${NC}";
    echo -e "${YELLOW}Press Return on an empty line to finish with the activated plugins${NC}";
    # declare -a ACTIVATED_PLUGINS
    current_plugin="start"
    while [ ! -z "$current_plugin" ]
    do
        read -p "Add a plugin: " current_plugin
        if [ ! -z "$current_plugin" ]
        then
            ACTIVATED_PLUGINS+=($current_plugin)
        fi
    done
    # echo ${ACTIVATED_PLUGINS[*]}

    echo -e "${GREEN}Step 7/9 - OPTIONAL PLUGINS${NC}";
    echo -e "${BLUE}The plugins in the optional array will not be installed and activated automatically. You will be asked about each one seperately${NC}";
    echo -e "${BLUE}See the README file for instructions on what to use as the plugin's name${NC}";
    echo -e "${YELLOW}Enter the plugin's name and press Return to continue with the next plugin${NC}";
    echo -e "${YELLOW}Press Return on an empty line to finish with the optional plugins${NC}";
    # declare -a OPTIONAL_PLUGINS
    current_plugin="start"
    while [ ! -z "$current_plugin" ]
    do
        read -p "Add a plugin: " current_plugin
        if [ ! -z "$current_plugin" ]
        then
            OPTIONAL_PLUGINS+=($current_plugin)
        fi
    done

    echo -e "${GREEN}Step 8/9 - DROPBOX API KEY${NC}";
    echo -e "${BLUE}You can connect to your Dropbox account and install premium plugins from a designated folder${NC}";
    echo -e "${BLUE}You will be asked if you want to install & activate each one of the plugins found in that folder${NC}";
    echo -e "${BLUE}See the README file for instructions on how to create an Api Key${NC}";
    echo -e "${YELLOW}Press Return on an empty line to skip setting up Dropbox${NC}";
    read -p "DROPBOX API KEY: " DROPBOX_API_KEY

    echo -e "${GREEN}Step 9/9 - DROPBOX FOLDER${NC}";
    echo -e "${BLUE}If you created a Dropbox App in the previus step, the script will automatically load all the plugins uploaded to that app's folder (by default Apps/your_app_name)${NC}";
    echo -e "${BLUE}if you want to load the plugins from a subfolder e.g. /Apps/your_app_name/folder/subbolder you should enter the subfolder path relative to your app's folder e.g. /folder/subbolder${NC}";
    echo -e "${YELLOW}Press Return on an empty line if you don't want to set a subfolder path${NC}";
    read -p "DROPBOX FOLDER PATH: " DROPBOX_FOLDER_PATH

    # Write the collected variables to a config file in the user's home dir
    CONFIG_PATH="${HOME}/.v-installwp.config"
    echo "DEFAULT_EMAIL=${DEFAULT_EMAIL}" > $CONFIG_PATH
    echo "DEFAULT_FNAME=${DEFAULT_FNAME}" >> $CONFIG_PATH
    echo "DEFAULT_LNAME=${DEFAULT_LNAME}" >> $CONFIG_PATH
    echo "DEFAULT_VESTA_USER_PACKAGE=${DEFAULT_VESTA_USER_PACKAGE}" >> $CONFIG_PATH
    echo "DEFAULT_WEB_DOMAIN_BACKEND=${DEFAULT_WEB_DOMAIN_BACKEND}" >> $CONFIG_PATH
    for plugin_name in "${ACTIVATED_PLUGINS[@]}"
    do
            echo "ACTIVATED_PLUGIN=${plugin_name}" >> $CONFIG_PATH
    done
    for plugin_name in "${OPTIONAL_PLUGINS[@]}"
    do
            echo "OPTIONAL_PLUGIN=${plugin_name}" >> $CONFIG_PATH
    done
    # echo "OPTIONAL_PLUGINS=${OPTIONAL_PLUGINS[*]}" >> $CONFIG_PATH
    echo "DROPBOX_API_KEY=${DROPBOX_API_KEY}" >> $CONFIG_PATH
    echo "DROPBOX_FOLDER_PATH=${DROPBOX_FOLDER_PATH}" >> $CONFIG_PATH
}

function readConfig() {
    typeset -A config # init array
    config=( # set default values in config array
        [DEFAULT_EMAIL]="test@example.com"
        [DEFAULT_FNAME]="Code"
        [DEFAULT_LNAME]="Monkeys"
        [DEFAULT_VESTA_USER_PACKAGE]="cm"
        [DEFAULT_WEB_DOMAIN_BACKEND]="cm"
        [ACTIVATED_PLUGINS]="classic-editor contact-form-7"
        [OPTIONAL_PLUGINS]="wordfence"
        [DROPBOX_FOLDER_PATH]=""
        [DROPBOX_API_KEY]="XXXXXXX"
    )



    while read line
    do
        if echo $line | grep -F = &>/dev/null
        then
            varname=$(echo "$line" | cut -d '=' -f 1)
            if [ "$varname" = "ACTIVATED_PLUGIN" ]
            then
                ACTIVATED_PLUGINS+=($(echo "$line" | cut -d '=' -f 2-))
            elif [ "$varname" = "OPTIONAL_PLUGIN" ]
            then
                OPTIONAL_PLUGINS+=($(echo "$line" | cut -d '=' -f 2-))
            else
                config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
            fi
            # echo "$line" | cut -d '=' -f 2-
        fi
    done < ${HOME}/.v-installwp.config

    # echo ${ACTIVATED_PLUGINS[*]}

    #DEFALUTS
    DEFAULT_EMAIL=${config[DEFAULT_EMAIL]}
    DEFAULT_FNAME=${config[DEFAULT_FNAME]}
    DEFAULT_LNAME=${config[DEFAULT_LNAME]}
    DEFAULT_VESTA_USER_PACKAGE=${config[DEFAULT_VESTA_USER_PACKAGE]}
    DEFAULT_WEB_DOMAIN_BACKEND=${config[DEFAULT_WEB_DOMAIN_BACKEND]}

    # plugins_activated=${config[ACTIVATED_PLUGINS]}
    # echo "plugins_activated ->"$plugins_activated
    # declare -a ACTIVATED_PLUGINS=()
    # for word in $plugins_activated
    # do
    #     echo $word
    #     ACTIVATED_PLUGINS+=($word)
    # done
    # declare -a ACTIVATED_PLUGINS=( ${config[ACTIVATED_PLUGINS]} )
    # declare -a OPTIONAL_PLUGINS=( ${config[OPTIONAL_PLUGINS]} )
    DROPBOX_FOLDER_PATH=${config[DROPBOX_FOLDER_PATH]}
    DROPBOX_API_KEY=${config[DROPBOX_API_KEY]}

    # echo "DEFAULT_EMAIL=${DEFAULT_EMAIL}"
    # echo "DEFAULT_FNAME=${DEFAULT_FNAME}"
    # echo "DEFAULT_LNAME=${DEFAULT_LNAME}"
    # echo "DEFAULT_VESTA_USER_PACKAGE=${DEFAULT_VESTA_USER_PACKAGE}"
    # echo "DEFAULT_WEB_DOMAIN_BACKEND=${DEFAULT_WEB_DOMAIN_BACKEND}"
    # echo "ACTIVATED_PLUGINS "${ACTIVATED_PLUGINS[*]}
    # echo "OPTIONAL_PLUGINS=( ${OPTIONAL_PLUGINS[*]} )"
    # echo "DROPBOX_API_KEY=${DROPBOX_API_KEY}"
    # echo "DROPBOX_FOLDER_PATH=${DROPBOX_FOLDER_PATH}"
}

if [ ! -f "${HOME}/.v-installwp.config" ]; then
    generateConfig
    # exit 0
else
    readConfig
    # exit 0
fi

#DEFALUTS
# DEFAULT_EMAIL="test@example.com"
# DEFAULT_FNAME="Code"
# DEFAULT_LNAME="Monkeys"
# DEFAULT_VESTA_USER_PACKAGE="cm"
# DEFAULT_WEB_DOMAIN_BACKEND="cm"
# declare -a ACTIVATED_PLUGINS
# ACTIVATED_PLUGINS=("classic-editor" "contact-form-7")
# declare -a OPTIONAL_PLUGINS
# OPTIONAL_PLUGINS=("wordfence")
# # declare -a PREMIUM_PLUGINS
# # PREMIUM_PLUGINS=("plugin1.zip" "plugin2.zip")
# DROPBOX_FOLDER_PATH=""
# DROPBOX_API_KEY="XXXXXXX"



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
        read -p "CREATE USER ${user} ? (y/n) [y]: " createuser
        createuser=${createuser:-y}

        if [ "$createuser" = "y" ]
        then

            while [ ${#user} -gt 13 ]
            do
                echo -e "${RED}Username must be less than 13 characters long!${NC}";
                read -p "Pick a new Username : " user
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

            v-add-user $user $user_pass $user_email $DEFAULT_VESTA_USER_PACKAGE $user_fname $user_lname

        else
            echo -e "${RED}Aborting!${NC}";
            exit 0

        fi


    fi

    DIRECTORY=/home/$1/web/$2/public_html

    if [ -d "$DIRECTORY" ]; then
        cd $DIRECTORY
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
        sslwww=n
    fi

    if [ "$ssl" = "y" ]
    then
        if [ "$sslwww" = "y" ]
        then
            v-add-letsencrypt-domain $1 $2 www.$2
        else
            v-add-letsencrypt-domain $1 $2
        fi
        echo -e "${YELLOW}Setting up redirection to HTTPS in new website's nginx config and restarting nginx${NC}"
        sed -i '4ireturn 301 https://$host$request_uri;' /home/$1/conf/web/${2}.nginx.conf
        service nginx restart
        echo -e "${GREEN}All Done! ${NC}"
    fi

}

echo -e "${YELLOW}Please, enter vesta username and domain on which you want to install WordPress${NC}"

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


set_user_dir $user $domain


rm -f index.html robots.txt
echo -e "${YELLOW}Downloading the latest version of WordPress and set optimal & secure configuration...${NC}"
wget http://wordpress.org/latest.tar.gz
echo -e "${YELLOW}Unpacking WordPress into website home directory..."
sleep 2
tar xfz latest.tar.gz
chown -R $user:$user wordpress/
mv wordpress/* ./
rmdir ./wordpress/
rm -f latest.tar.gz readme.html wp-config-sample.php license.txt
mv index.html index.html.bak 2>/dev/null




#cration of robots.txt
echo -e "${YELLOW}Creating robots.txt file...${NC}"

sleep 2
cat >/home/$user/web/$domain/public_html/robots.txt <<EOL
User-agent: *
Disallow: /cgi-bin
Disallow: /wp-admin/
Disallow: /wp-includes/
Disallow: /wp-content/
Disallow: /wp-content/plugins/
Disallow: /wp-content/themes/
Disallow: /trackback
Disallow: */trackback
Disallow: */*/trackback
Disallow: */*/feed/*/
Disallow: */feed
Disallow: /*?*
Disallow: /tag
Disallow: /?author=*
EOL

chown -R $user:$user /home/$user/web/$domain/public_html/robots.txt

echo -e "${GREEN}File robots.txt was successfully created!"

sleep 2

echo -e "${YELLOW}Add Database & USER for WordPress${NC}"

read -p "Database USER : ${user}_" db_user

username_length=${#user}
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
    db_exists=$(/usr/local/bin/v-dbexists $user ${user}_${db_user})
    if [ "$db_exists" == "true" ]
    then
        echo -e "${RED}Username or Databse already exists!${NC}";
        read -p "Pick a new Username : ${user}_" db_user
        while [ ${#db_user} -gt $max_db_user_length ]
        do
            echo -e "${RED}Username must be less than $max_db_user_length characters long!${NC}";
            read -p "Pick a new Username : ${user}_" db_user
        done
    fi
done

db_pass=$(generatePass)


echo -e "${YELLOW}Add Database USER & Database PASSWORD for WordPress${NC}"
echo $db_pass

/usr/local/vesta/bin/v-add-database $user $db_user $db_user $db_pass mysql localhost

echo -e "${GREEN}User and Database Created!"

sleep 2

echo -e "${YELLOW}Setting up Wordpress${NC}"

# echo "sudo -u $user wp core config --dbhost=localhost --dbname=${user}_${db_user} --dbuser=${user}_${db_user} --dbpass=${db_pass}"

sudo -u $user wp core config --dbhost=localhost --dbname=${user}_${db_user} --dbuser=${user}_${db_user} --dbpass=${db_pass}

read -p "Website Title : " website_title
# read -p "Admin Email : " admin_email
# read -e -p "Admin Email? [$user_email]: " -i "$user_email" admin_email
if [[ -z "$user_email" ]]
then
   suggested_email=$DEFAULT_EMAIL
else
    suggested_email=$user_email
fi
read -p "Admin Email? [$suggested_email]: " admin_email
admin_email=${admin_email:-"$suggested_email"}

sudo -u $user wp core install --url=${urlprefix}${domain} --title="$website_title" --admin_name=$admin_email --admin_email=$admin_email

sudo -u $user wp plugin deactivate hello
sudo -u $user wp plugin delete hello
sudo -u $user wp plugin deactivate akismet
sudo -u $user wp plugin delete akismet

for plugin_name in "${ACTIVATED_PLUGINS[@]}"
do
        sudo -u $user wp plugin install $plugin_name  --activate
done

for plugin_name in "${OPTIONAL_PLUGINS[@]}"
do
        read -p "Install $plugin_name ? (y/n) [y]: " installplugin
        installplugin=${installplugin:-y}
        if [ "$installplugin" = "y" ]
        then
            sudo -u $user wp plugin install $plugin_name
            read -p "Activate $plugin_name ? (y/n) [y]: " activateplugin
            activateplugin=${activateplugin:-y}
            if [ "$activateplugin" = "y" ]
            then
                sudo -u $user wp plugin activate $plugin_name
            fi
        fi
done

if [ ! -z DROPBOX_API_KEY ]
then
    declare -a DROPBOX_PLUGINS
    DROPBOX_PLUGINS=( $(/usr/local/bin/v-dropbox_list $DROPBOX_API_KEY $DROPBOX_FOLDER_PATH) )
    # result=($(comm -12 <(for X in "${PREMIUM_PLUGINS[@]}"; do echo "${X}"; done|sort)  <(for X in "${DROPBOX_PLUGINS[@]}"; do echo "${X}"; done|sort)))
    if [ ${#DROPBOX_PLUGINS[@]} -gt 0 ]
    then
         for plugin_name in "${DROPBOX_PLUGINS[@]}"
         do
                 save_file_path="${DIRECTORY}/wp-content/plugins/${plugin_name}"
                 save_dir_path="${DIRECTORY}/wp-content/plugins/"
                 read -p "Install $plugin_name ? (y/n) [n]: " installplugin
                 installplugin=${installplugin:-n}
                 if [ "$installplugin" = "y" ]
                 then
                     sudo -u $user curl -o $save_file_path -X POST https://content.dropboxapi.com/2/files/download --header 'Authorization: Bearer '$DROPBOX_API_KEY --header 'Dropbox-API-Arg: {"path":"'$DROPBOX_FOLDER_PATH'/'$plugin_name'"}'
                     sudo -u $user unzip $save_file_path -d $save_dir_path
                     sudo -u $user rm $save_file_path
                     read -p "Activate $plugin_name ? (y/n) [y]: " activateplugin
                     activateplugin=${activateplugin:-y}
                     if [ "$activateplugin" = "y" ]
                     then
                         sudo -u $user wp plugin activate ${plugin_name%.*}
                     fi
                 fi

         done
     fi
 fi




sudo -u $user wp plugin is-active worker
if [ $? -eq 0 ]
then
    managewp_activation_key=$(sudo -u $user wp option get mwp_potential_key)
    echo -e "${GREEN}********************************************************* ${NC}"
    echo -e "${GREEN}ManageWP Activation Key: $managewp_activation_key"
    echo -e "${GREEN}********************************************************* ${NC}"
fi


# sudo -u $user wp plugin install mainwp-child --activate
echo -e "${GREEN}All done! Enjoy Fresh WordPress Installation.${NC}"
