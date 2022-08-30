#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=136750
VERSION=innuendo1
echo -e "$GREEN_COLOR YOUR NODE WILL BE UPDATED TO VERSION: $VERSION ON BLOCK NUMBER: $BLOCK $NO_COLOR\n"
for((;;)); do
	height=$(quicksilverd status |& jq -r ."SyncInfo"."latest_block_height")
	if ((height>=$BLOCK)); then

		sudo systemctl stop quicksilverd
		cd $HOME && rm quicksilver -rf
		git clone https://github.com/ingenuity-build/quicksilver.git --branch innuendo1
		cd quicksilver
		make build
		sudo chmod +x ./build/quicksilverd && sudo mv ./build/quicksilverd /usr/local/bin/quicksilverd
		echo "restart the system..."
		sudo systemctl restart quicksilverd && journalctl -fu quicksilverd -o cat

		for (( timer=60; timer>0; timer-- )); do
			printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
			sleep 1
		done
		height=$(quicksilverd status |& jq -r ."SyncInfo"."latest_block_height")
		if ((height>$BLOCK)); then
			echo -e "$GREEN_COLOR YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION: $VERSION $NO_COLOR\n"
		fi
		quicksilverd version --long | head
		break
	else
		echo -e "${GREEN_COLOR}$height${NO_COLOR} ($(( BLOCK - height  )) blocks left)"
	fi
	sleep 5
done
