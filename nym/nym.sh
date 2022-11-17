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

echo -e "\e[1m\e[32mPlease make sure you have already generated your nym wallet address as it will be needed in installation process!\e[0m"
echo -e "\e[1m\e[32mIf not please visit https://nymtech.net/ and download nym wallet application to generate new wallet\e[0m"
read -p "Press enter to continue"

# set variables
if [ ! $NODENAME ]; then
	read -p "Enter your nym mixnode name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET_ADDRESS ]; then
	read -p $'Enter your nym wallet address. It should begin with \e[1m\e[32mn1\e[0m...: ' WALLET_ADDRESS
	echo 'export WALLET_ADDRESS='$WALLET_ADDRESS >> $HOME/.bash_profile
fi

# set latest nym mixnode version
NYM_MIXNODE_VERSION="1.0.1"
source $HOME/.bash_profile

echo '================================================================================'
echo -e "Nym mixnode version: \e[1m\e[32m$NYM_MIXNODE_VERSION\e[0m"
echo -e "Your nym mixnode name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your nym wallet address: \e[1m\e[32m$WALLET_ADDRESS\e[0m"
echo '================================================================================'
sleep 2

echo -e "\e[1m\e[32mPlease make sure settings above are filled correctly and press Enter to continue... \e[0m"
read -p "Press CTRL+C to exit"

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing prerequisites... \e[0m" && sleep 1
# install packages
sudo apt install pkg-config build-essential libssl-dev curl jq ufw snapd base58 -y

echo "DefaultLimitNOFILE=65535" >> /etc/systemd/system.conf

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
wget -O nym-mixnode "https://github.com/nymtech/nym/releases/download/nym-binaries-$NYM_MIXNODE_VERSION/nym-mixnode"

# give persmissions to execute and move binaries into bin
chmod +x nym-mixnode
sudo mv nym-mixnode /usr/bin/

echo -e "\e[1m\e[32m4. Initializing service... \e[0m" && sleep 1
# init
nym-mixnode init --id $NODENAME --host $(curl ifconfig.me) --wallet-address $WALLET_ADDRESS

# create systemd service
sudo tee /etc/systemd/system/nym-mixnode.service > /dev/null <<EOF
[Unit]
Description=Nym Mixnode
StartLimitInterval=350
StartLimitBurst=10

[Service]
User=$USER
ExecStart=$(which nym-mixnode) run --id '$NODENAME'
KillSignal=SIGINT
Restart=on-failure
RestartSec=30
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable nym-mixnode

echo -e "\e[1m\e[32m5. Setting up firewall to allow tcp ports 1789, 1790, 8000, 22, 80, 443... \e[0m" && sleep 1
# set up firewall
sudo ufw allow 1789,1790,8000,22,80,443/tcp
sudo ufw --force enable

echo -e "\e[1m\e[32m6. Increasing Max open files limit... \e[0m" && sleep 1
echo "DefaultLimitNOFILE=65535" >> /etc/systemd/system.conf
sudo systemctl daemon-reload

echo -e "\e[1m\e[32m7. Starting Nym mixnode... \e[0m" && sleep 1
sudo systemctl start nym-mixnode

echo -e '\e[1m\e[32m=============== SETUP FINISHED ===================\e[0m'
echo -e 'To start mixing packet you have to \e[1m\e[32mbond your mixnode\e[0m first!'
