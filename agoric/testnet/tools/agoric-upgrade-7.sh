#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=146039
VERSION=agoric-upgrade-7
echo -e "$GREEN_COLOR YOUR NODE WILL BE UPDATED TO VERSION: $VERSION ON BLOCK NUMBER: $BLOCK $NO_COLOR\n"
for((;;)); do
height=$(ag0 status |& jq -r ."SyncInfo"."latest_block_height")
if ((height>=$BLOCK)); then
sudo systemctl stop agoricd
cd $HOME && rm $HOME/ag0 -rf
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-upgrade-7
make build
. $HOME/.bash_profile
cp $HOME/ag0/build/ag0 /usr/local/bin
echo "restart the system..."
sudo systemctl restart agoricd
for (( timer=60; timer>0; timer-- ))
        do
                printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
                sleep 1
        done
height=$(ag0 status |& jq -r ."SyncInfo"."latest_block_height")
if ((height>$BLOCK)); then
echo -e "$GREEN_COLOR YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION: $VERSION $NO_COLOR\n"
fi
ag0 version --long | head
break
else
echo $height
fi
sleep 1
done
