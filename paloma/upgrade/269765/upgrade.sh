#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=269765
VERSION=v0.11.1
echo -e "$GREEN_COLOR YOUR NODE WILL BE UPDATED TO VERSION: $VERSION ON BLOCK NUMBER: $BLOCK $NO_COLOR\n"
for((;;)); do
	height=$(palomad status |& jq -r ."SyncInfo"."latest_block_height")
	if ((height>=$BLOCK)); then

		sudo systemctl stop palomad
		sudo systemctl stop pigeond
		wget -O - https://github.com/palomachain/paloma/releases/download/v0.11.1/paloma_Linux_x86_64.tar.gz | \
		sudo tar -C /usr/local/bin -xvzf - palomad
		sudo chmod +x /usr/local/bin/palomad
		wget -O - https://github.com/palomachain/pigeon/releases/download/v0.11.0/pigeon_Linux_x86_64.tar.gz | \
		tar -C /usr/local/bin -xvzf - pigeon
		chmod +x /usr/local/bin/pigeon
		sudo systemctl start palomad && sudo systemctl start pigeond

		for (( timer=60; timer>0; timer-- )); do
			printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
			sleep 1
		done
		height=$(palomad status |& jq -r ."SyncInfo"."latest_block_height")
		if ((height>$BLOCK)); then
			echo -e "$GREEN_COLOR YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION: $VERSION $NO_COLOR\n"
		fi
		palomad version --long | head
		break
	else
		echo -e "${GREEN_COLOR}$height${NO_COLOR} ($(( BLOCK - height  )) blocks left)"
	fi
	sleep 5
done
