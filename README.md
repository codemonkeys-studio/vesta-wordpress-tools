# vesta-installwp
A small script to automatically install Wordpress and any plugins you may want in a Vesta CP server

It uses WP-CLI to perform the Wordpress & plugin installation and can install WP-CLI if it is not already installed

It initially asks for a vesta username and a domain in which wordpress will be installed.
If the user does not exist it will ask some more questions and create the user. (it will automatically create a password which will be echoed in the terminal)

You will then be asked if a Let's Encrypt ssl certificate should be issued for the domain and for the www alias

After that it will ask you for the database/user name. (By default it creates a database and db user with the same name and automatically creates a strong password which it outputs to the terminal) The convention for vesta db naming is user_dbname, so you should only enter the last part "dbname" the user_ will be prefixed automatically. (please make sure that the db name isn't already taken because there is no error checking yet at this point).

It will install wordpress, ask for an admin email and create an Administrator user using the provided email as username. The password will be automatically created by wordpress and echoed in the terminal. (you could always perform a password reset using your email if you miss it)


To install login as root at your vesta server, clone or download this repo
```bash
git clone https://github.com/tsarbo/vesta-installwp.git
```

cd into vesta-installwp
```bash
cd vesta-installwp
```
Open istallwp.sh with an editor
```bash
vim installwp.sh
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
```

After you change them to fit your needs, make the script executable
```bash
chmod +x installwp.sh
```
 and copy it to /usr/local/bin
 ```bash
 cp installwp.sh /usr/local/bin/installwp
 ```

 You can then run it simply byt typing
 ```bash
installwp
 ```

**In the deafults:**
* The ACTIVATED_PLUGINS and NOT_ACTIVATED_PLUGINS arrays should be filled with the plugin slug, which you can get from the plugin's url in the Wordpress plugin repository
e.g. The plugin Classic Editor has a url https://el.wordpress.org/plugins/classic-editor/ so the slug is the last part of that url "classic-editor"

* The plugins in the ACTIVATED_PLUGINS array will be installed and activated automatically

* You will be asked for each one of the plugins in the NOT_ACTIVATED_PLUGINS array, if you want to install and activate it




