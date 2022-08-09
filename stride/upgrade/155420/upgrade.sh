#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=155420
VERSION=4184e0c3852695895781a22c8723270bcc5b7f4e
echo -e "$GREEN_COLOR YOUR NODE WILL BE UPDATED TO VERSION: $VERSION ON BLOCK NUMBER: $BLOCK $NO_COLOR\n"
for((;;)); do
height=$(strided status |& jq -r ."SyncInfo"."latest_block_height")
if ((height>=$BLOCK)); then

sudo systemctl stop strided
cd $HOME && rm -rf stride
git clone https://github.com/Stride-Labs/stride.git && cd stride
git checkout 4184e0c3852695895781a22c8723270bcc5b7f4e
make build
sudo cp $HOME/stride/build/strided /usr/local/bin
echo "restart the system..."
sudo systemctl restart strided && journalctl -fu strided -o cat

for (( timer=60; timer>0; timer-- ))
        do
                printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
                sleep 1
        done
height=$(strided status |& jq -r ."SyncInfo"."latest_block_height")
if ((height>$BLOCK)); then
echo -e "$GREEN_COLOR YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION: $VERSION $NO_COLOR\n"
fi
strided version --long | head
break
else
echo $height
fi
sleep 1
done
