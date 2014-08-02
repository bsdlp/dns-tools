#!/usr/bin/env bash

# get path to dir where script lives
# https://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
readonly _DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

readonly _NSDCON_OPTS="-c $_DIR/../conf/local.conf"

source $_DIR/../conf/common.sh

rsync -avz --progress $_DIR/../nsd/compiled/ $MASTER_USER@$MASTER_IP:$MASTER_PATH/zones/
scp $_DIR/../nsd/zones.list $MASTER_USER@$MASTER_IP:$MASTER_PATH/zones.list
scp $_DIR/../nsd/nsd.conf $MASTER_USER@$MASTER_IP:$MASTER_PATH/nsd.conf
ssh $MASTER_USER@$MASTER_IP 'chown -R nsd:nsd /etc/nsd/'

if [[ $1 == "restart" ]]
then /usr/local/sbin/nsd-control $_NSDCON_OPTS stop \
    && /usr/local/sbin/nsd-control $_NSDCON_OPTS start
else /usr/local/sbin/nsd-control $_NSDCON_OPTS reload
fi
