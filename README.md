# vesta-installwp

A small script to automatically install Wordpress and any plugins you may want in a Vesta CP server

It uses WP-CLI to perform the Wordpress & plugin installation and can install WP-CLI if it is not already installed

It initially asks for a vesta username and a domain in which wordpress will be installed.
If the user does not exist it will ask some more questions and create the user. (it will automatically create a password which will be echoed in the terminal)

You will then be asked if a Let's Encrypt ssl certificate should be issued for the domain and for the www alias.

After that, it will ask you for the database/user name. (By default it creates a database and db user with the same name and automatically creates a strong password which it outputs to the terminal) The convention for vesta db naming is user_dbname, so you should only enter the last part "dbname", the user_ will be prefixed automatically. (please make sure that the db name isn't already taken because there is no error checking yet at this point).

It will install wordpress, ask for an admin email and create an Administrator user using the provided email as username. The password will be automatically created by wordpress and echoed in the terminal. (you could always perform a password reset using your email if you miss it)


To install login as root at your vesta server and clone or download this repo
```bash
git clone https://github.com/tsarbo/vesta-installwp.git
```

cd into vesta-installwp
```bash
cd vesta-installwp
```
Open istallwp.sh with an editor
```bash
vim v-installwp.sh
```
and change the default values at the top
```bash
#DEFALUTS
DEFAULT_EMAIL="dev@codemonkeys.studio"
DEFAULT_FNAME="Code"
DEFAULT_LNAME="Monkeys"
DEFAULT_VESTA_USER_PACKAGE="cm"
DEFAULT_WEB_DOMAIN_BACKEND="cm"
declare -a ACTIVATED_PLUGINS
ACTIVATED_PLUGINS=("classic-editor" "contact-form-7")
declare -a NOT_ACTIVATED_PLUGINS
NOT_ACTIVATED_PLUGINS=("mainwp-child" "wordfence")
PREMIUM_PLUGINS=("wp-rocket.zip" "wp-smush-pro.zip")
DROPBOX_FOLDER_PATH=""
DROPBOX_API_KEY="XXXXXXX"
```

After you change them to fit your needs, make the script executable
```bash
chmod +x v-installwp.sh
```
 and copy it to /usr/local/bin
 ```bash
 cp v-installwp.sh /usr/local/bin/v-installwp
 ```

If you want to connect with Dropbox and download some premium plugins you may have uploaded there (Instructions on how to do that are in the end of this Readme) also run these commands:

```bash
chmod +x dropbox_list
```
 ```bash
 cp dropbox_list /usr/local/bin/
 ```


 You can then run it simply by typing
 ```bash
v-installwp
 ```

**In the deafults:**
* The ACTIVATED_PLUGINS and NOT_ACTIVATED_PLUGINS arrays should be filled with the plugin slug, which you can get from the plugin's url in the Wordpress plugin repository

e.g. The plugin Classic Editor has a url https://el.wordpress.org/plugins/classic-editor/ so the slug is the last part of that url "classic-editor"

* The plugins in the ACTIVATED_PLUGINS array will be installed and activated automatically

* You will be asked if you want to install and activate each one of the plugins in the NOT_ACTIVATED_PLUGINS array.

# Dropbox Intergration

In order to install some premium wordpress plugins you may have, you can connect your Dropbox account so that the script can download the plugins from there.

To do that you havbe to create a Dropbox App in order to get an API key

To Create an App go to [Dropbox Developers](https://www.dropbox.com/developers/apps/create)

Choose Dropbox API & App Folder inthe Type of Access section and enter a name for your app (that will also be the name of the dropbox folder that will be created so I wouldn't put any spaces or not allowed characters there) and click Create App

![Create App](https://assets.codemonkeys.studio/github/dropbox_1.jpg)

All you have to do now is click the buttton Generate Access token in the OAuth section and copy the API key

![Create Api key](https://assets.codemonkeys.studio/github/dropbox_2.jpg)

Assign the generated API key to the DROPBOX_API_KEY variable in the installwp script
 ```bash
 DROPBOX_API_KEY="XXXXXXX"
 ```
The DROPBOX_FOLDER_PATH variable should remain empty if you don't plan to create any folders inside the /Apps/your_app_name folder in your Dropbox.

If you do create folders and you want to load the plugins from a specified folder the you should fill in the folder path.
The root of your app is the folder /Apps/your_app_name so if you want to load the plugins from the folder /Apps/your_app_name/folder/subbolder the DROPBOX_FOLDER_PATH variable should contain the string "/folder/subbolder"

```bash
DROPBOX_FOLDER_PATH="/folder/subbolder"
```

Finally you should put the filenames (the full filename with the extention) in the PREMIUM_PLUGINS array e.g.
```bash
PREMIUM_PLUGINS=("wp-rocket.zip" "wp-smush-pro.zip")
```









