#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
WITHOU_COLOR='\033[0m'
for((;;)); do
height=$(quicksilverd status |& jq -r ."SyncInfo"."latest_block_height")
if ((height>=98000)); then
cd $HOME
rm quicksilver -rf
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.4.1
cd quicksilver
make build
sudo chmod +x ./build/quicksilverd && sudo mv ./build/quicksilverd /usr/local/bin/quicksilverd
echo "restart the system..."
sudo systemctl restart quicksilverd
for (( timer=60; timer>0; timer-- ))
        do
                printf "* second restart after sleep for ${RED_COLOR}%02d${WITHOUT_COLOR} sec\r" $timer
                sleep 1
        done
height=$(quicksilverd status |& jq -r ."SyncInfo"."latest_block_height")
if ((height>98000)); then
echo -e "$GREEN_COLOR YOUR NODE SUCCESFULLY UPDATE TO 0.4.1 VERSION $WITHOU_COLOR\n"
fi
quicksilverd version --long | head
break
else
echo $height
fi
sleep 1
done
