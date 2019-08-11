#!/bin/bash
# This script installs WordPress from Command Line.

#DEFALUTS
DEFAULT_EMAIL="test@example.com"
DEFAULT_FNAME="Code"
DEFAULT_LNAME="Monkeys"
DEFAULT_VESTA_USER_PACKAGE="cm"
DEFAULT_WEB_DOMAIN_BACKEND="cm"
declare -a ACTIVATED_PLUGINS
ACTIVATED_PLUGINS=("classic-editor" "contact-form-7")
declare -a NOT_ACTIVATED_PLUGINS
NOT_ACTIVATED_PLUGINS=("wordfence")
declare -a PREMIUM_PLUGINS
PREMIUM_PLUGINS=("plugin1.zip" "plugin2.zip")
DROPBOX_FOLDER_PATH=""
DROPBOX_API_KEY="XXXXXXX"


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
            # read -p "USER email ? [dev@codemonkeys.studio]: " user_email
            # if [[ -z "$user_email" ]]
            # then
            #    user_email="dev@codemonkeys.studio"
            # fi
            # read -e -p "USER email ? [dev@codemonkeys.studio]: " -i "dev@codemonkeys.studio" user_email
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
        sslwww = n
    fi

    if [ "$ssl" = "y" ]
    then
        if [ "$sslwww" = "y" ]
        then
            v-add-letsencrypt-domain $1 $2 www.$2 yes
        else
            v-add-letsencrypt-domain $1 $2 yes
        fi
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

read -p "Database USER : " db_user
# read -p "Database PASSWORD : " db_pass

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

for plugin_name in "${NOT_ACTIVATED_PLUGINS[@]}"
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

if [ ${#PREMIUM_PLUGINS[@]} -gt 0 ]
then
   declare -a DROPBOX_PLUGINS
   DROPBOX_PLUGINS=( $(/usr/local/bin/dropbox_list $DROPBOX_API_KEY $DROPBOX_FOLDER_PATH) )
   result=($(comm -12 <(for X in "${PREMIUM_PLUGINS[@]}"; do echo "${X}"; done|sort)  <(for X in "${DROPBOX_PLUGINS[@]}"; do echo "${X}"; done|sort)))
   if [ $result != 'NoFiles' ]
   then
        for plugin_name in "${result[@]}"
        do
                save_file_path="${DIRECTORY}/wp-content/plugins/${plugin_name}"
                save_dir_path="${DIRECTORY}/wp-content/plugins/"
                read -p "Install $plugin_name ? (y/n) [y]: " installplugin
                installplugin=${installplugin:-y}
                if [ "$installplugin" = "y" ]
                then
                    sudo -u $user curl -o $save_file_path -X POST https://content.dropboxapi.com/2/files/download --header 'Authorization: Bearer '$DROPBOX_API_KEY --header 'Dropbox-API-Arg: {"path":"'$DROPBOX_FOLDER_PATH'/'$plugin_name'"}'
                    sudo -u $user unzip $save_file_path -d $save_dir_path
                    sudo -u $user rm $save_dir_path
                    read -p "Activate $plugin_name ? (y/n) [y]: " activateplugin
                    activateplugin=${activateplugin:-y}
                    if [ "$activateplugin" = "y" ]
                    then
                        sudo -u $user wp plugin activate $plugin_name
                    fi
                fi

        done
    fi
fi


# sudo -u $user wp plugin install mainwp-child --activate
echo -e "${GREEN}All done! Enjoy Fresh WordPress Installation.${NC}"
