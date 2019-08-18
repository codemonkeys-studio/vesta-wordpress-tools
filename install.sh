#!/bin/bash
# Installation script
#

#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Moving files in all the right places!${NC}";
echo -e "${GREEN}Installing the v-installwp script!${NC}";
chmod +x v-installwp.sh
cp v-installwp.sh /usr/local/bin/v-installwp
echo -e "${BLUE}v-installwp installed!${NC}";

echo -e "${GREEN}Installing the v-migratewp script!${NC}";
chmod +x v-migratewp.sh
cp v-migratewp.sh /usr/local/bin/v-migratewp
echo -e "${BLUE}v-migratewp installed!${NC}";

echo -e "${GREEN}Installing the v-fixwpssl script!${NC}";
chmod +x v-fixwpssl.sh
cp v-fixwpssl.sh /usr/local/bin/v-fixwpssl
echo -e "${BLUE}v-fixwpssl installed!${NC}";

echo -e "${GREEN}Installing the helper scripts!${NC}";
chmod +x v-dropbox_list.phar
cp v-dropbox_list.phar /usr/local/bin/v-dropbox_list
chmod +x v-dbexists.phar
cp v-dbexists.phar /usr/local/bin/v-dbexists
echo -e "${BLUE}Helper scripts installed!${NC}";

echo -e "${YELLOW}******${GREEN}All Done${YELLOW}******${NC}";
