#!/bin/bash
declare -a PREMIUM_PLUGINS
PREMIUM_PLUGINS=( "wp-rocket.zip" "wpai-user-add-on_1.1.1.zip" )
# printf '%s\n' "${PREMIUM_PLUGINS[@]}"

declare -a DROPBOX_PLUGINS
DROPBOX_PLUGINS=( $(php dropbox_list.php) )
# printf '%s\n' "${DROPBOX_PLUGINS[@]}"
# echo $DROPBOX_PLUGINS
result=($(comm -12 <(for X in "${PREMIUM_PLUGINS[@]}"; do echo "${X}"; done|sort)  <(for X in "${DROPBOX_PLUGINS[@]}"; do echo "${X}"; done|sort)))

echo ${result[@]}

for plugin_name in "${result[@]}"
do
        curl -o $plugin_name -X POST https://content.dropboxapi.com/2/files/download --header 'Authorization: Bearer sl.AIogH7P_SdWU6rb9c4Q3oQsP04vaT-_6nQ0_nTAMBH1V2pw8w7ZaGj4FH-BFgiM-v8EhwDwD_0c1Hpv2J41HImzNQkINu_FlJFABJToP879A4Mc-01wa78QY3io9n1aEOIswC3ME' --header 'Dropbox-API-Arg: {"path":"/wp_premium_plugins/'$plugin_name'"}'
done


#A=(vol-175a3b54 vol-382c477b vol-8c027acf vol-93d6fed0 vol-71600106 vol-79f7970e vol-e3d6a894 vol-d9d6a8ae vol-8dbbc2fa vol-98c2bbef vol-ae7ed9e3 vol-5540e618 vol-9e3bbed3 vol-993bbed4 vol-a83bbee5 vol-ff52deb2)
#B=(vol-175a3b54 vol-e38d0c94 vol-2a19386a vol-b846c5cf vol-98c2bbef vol-7320102b vol-8f6226cc vol-27991850 vol-71600106 vol-615e1222)

# intersections=()

# for item1 in "${PREMIUM_PLUGINS[@]}"; do
#     for item2 in "${DROPBOX_PLUGINS[@]}"; do
#         if [[ $item1 == "$item2" ]]; then
#             intersections+=( "$item1" )
#             break
#         fi
#     done
# done

# printf '%s\n' "${intersections[@]}"
