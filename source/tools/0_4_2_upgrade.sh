#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=212000
VERSION=v0.4.2
echo -e "$GREEN_COLOR YOUR NODE WILL BE UPDATED TO VERSION: $VERSION ON BLOCK NUMBER: $BLOCK $NO_COLOR\n"
for((;;)); do
height=$(sourced status |& jq -r ."SyncInfo"."latest_block_height")
if ((height>=$BLOCK)); then
cd $HOME
rm source -rf
git clone https://github.com/ingenuity-build/source.git --branch $VERSION
cd source
make build
sudo chmod +x ./build/sourced && sudo mv ./build/sourced /usr/local/bin/sourced
echo "restart the system..."
sudo systemctl restart sourced
for (( timer=60; timer>0; timer-- ))
        do
                printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
                sleep 1
        done
height=$(sourced status |& jq -r ."SyncInfo"."latest_block_height")
if ((height>$BLOCK)); then
echo -e "$GREEN_COLOR YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION: $VERSION $NO_COLOR\n"
fi
sourced version --long | head
break
else
echo $height
fi
sleep 1
done
