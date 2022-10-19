#!/bin/bash

echo -e "\033[0;35m"
echo " :::    ::: ::::::::::: ::::    :::  ::::::::  :::::::::  :::::::::: ::::::::  ";
echo " :+:   :+:      :+:     :+:+:   :+: :+:    :+: :+:    :+: :+:       :+:    :+: ";
echo " +:+  +:+       +:+     :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+       +:+        ";
echo " +#++:++        +#+     +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#++:++#  +#++:++#++ ";
echo " +#+  +#+       +#+     +#+  +#+#+# +#+    +#+ +#+    +#+ +#+              +#+ ";
echo " #+#   #+#  #+# #+#     #+#   #+#+# #+#    #+# #+#    #+# #+#       #+#    #+# ";
echo " ###    ###  #####      ###    ####  ########  #########  ########## ########  ";
echo -e "\e[0m"

sleep 2

# set vars
echo -e "\e[1m\e[32mReplace <NODENAME> below with the name of your node\e[0m"
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
source ~/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e '================================================='
sleep 3

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update packages
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# update dependencies
sudo apt install curl build-essential git wget npm nodejs jq make gcc tmux -y

# create chain data directory
sudo mkdir -p /var/lib/bifrost-data
sudo chmod 0777 /var/lib/bifrost-data

# update executables
cd $HOME
wget -qO bifrost-node "https://github.com/bifrost-platform/bifrost-node/releases/download/v1.0.0/bifrost-node"
wget -qO bifrost-testnet.json "https://github.com/bifrost-platform/bifrost-node/releases/download/v1.0.0/bifrost-testnet.json"
sudo chmod +x bifrost-node
sudo mv bifrost-node /usr/local/bin/
sudo mv bifrost-testnet.json /var/lib/bifrost-data

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create bifrost-node service 
sudo tee <<EOF >/dev/null /etc/systemd/system/bifrostd.service
[Unit]
Description=Bifrost Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which bifrost-node) \\
--base-path /var/lib/bifrost-data \\
--chain /var/lib/bifrost-data/bifrost-testnet.json \\
--port 30333 \\
--validator \\
--state-cache-size 0 \\
--runtime-cache-size 64 \\
--name $NODENAME
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable bifrostd
sudo systemctl restart bifrostd

echo "==================================================="
echo -e '\e[32mCheck node status\e[39m' && sleep 1
if [[ `service bifrostd status | grep active` =~ "running" ]]; then
  echo -e "Your bifrost node \e[32minstalled and running\e[39m!"
else
  echo -e "Your bifrost node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo -e "Check your node logs: \e[32mjournalctl -fu bifrostd -o cat\e[39m"
sleep 2
