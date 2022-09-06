#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=3608063
VERSION=v1.7.0
echo -e "$GREEN_COLOR YOUR NODE WILL BE UPDATED TO VERSION: $VERSION ON BLOCK NUMBER: $BLOCK $NO_COLOR\n"
for((;;)); do
	height=$(gravityd status |& jq -r ."SyncInfo"."latest_block_height")
	if ((height>=$BLOCK)); then

		sudo systemctl stop gravityd
		cd $HOME
		rm gravity-bin -rf
		mkdir gravity-bin && cd gravity-bin
		wget -O gravityd https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.7.0/gravity-linux-amd64
		wget -O gbt https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.7.0/gbt
		chmod +x *
		sudo mv * /usr/bin/
		echo "restart the system..."
		sudo systemctl restart gravityd
		sudo systemctl restart orchestrator
		for (( timer=60; timer>0; timer-- )); do
			printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
			sleep 1
		done
		height=$(gravityd status |& jq -r ."SyncInfo"."latest_block_height")
		if ((height>$BLOCK)); then
			echo -e "$GREEN_COLOR YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION: $VERSION $NO_COLOR\n"
		fi
		gravityd version --long | head
		break
	else
		echo -e "${GREEN_COLOR}$height${NO_COLOR} ($(( BLOCK - height  )) blocks left)"
	fi
	sleep 5
done
