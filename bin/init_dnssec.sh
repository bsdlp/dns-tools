#!/usr/bin/env bash

# http://robertmuth.blogspot.com/2012/08/better-bash-scripting-in-15-minutes.html
set -o nounset
set -o errexit

# get path to dir where script lives
# https://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# get zone and try to validate
# https://stackoverflow.com/questions/15268987/bash-based-regex-domain-name-validation

_validate_zone_name() {
    ggrep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'
}

while [[ ! $(echo $zone_name | _validate_zone_name) ]] ; do
    echo -n "zone: "
    read zone_name 
done

readonly KEYDIRNAME=${zone_name/./-}

# cd to root of fly/dns
cd $DIR/../

mkdir -p keys/$KEYDIRNAME/ && cd $_

readonly KEYDIR=keys/$KEYDIRNAME/

ZSK=$(dnssec-keygen -r/dev/random -a RSASHA1 -b 1024 -n ZONE $zone_name)
KSK=$(dnssec-keygen -r/dev/random -f KSK -a RSASHA1 -b 1280 -n ZONE $zone_name)

echo "\$include $(greadlink -e $KEYDIR)/$ZSK.key ;ZSK"
echo "\$include $(greadlink -e $KEYDIR)/$KSK.key ;KSK"
