#!/bin/bash
echo "=================================================="
echo -e "\033[0;35m"
echo " :::    ::: ::::::::::: ::::    :::  ::::::::  :::::::::  :::::::::: ::::::::  ";
echo " :+:   :+:      :+:     :+:+:   :+: :+:    :+: :+:    :+: :+:       :+:    :+: ";
echo " +:+  +:+       +:+     :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+       +:+        ";
echo " +#++:++        +#+     +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#++:++#  +#++:++#++ ";
echo " +#+  +#+       +#+     +#+  +#+#+# +#+    +#+ +#+    +#+ +#+              +#+ ";
echo " #+#   #+#  #+# #+#     #+#   #+#+# #+#    #+# #+#    #+# #+#       #+#    #+# ";
echo " ###    ###  #####      ###    ####  ########  #########  ########## ########  ";
echo -e "\e[0m"
echo "=================================================="

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=augusta-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Your node name: ' $NODENAME
echo 'Your wallet name: ' $WALLET
echo 'Your chain name: ' $CHAIN_ID
echo '================================================='
sleep 2

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
sudo apt install -y uidmap dbus-user-session

# download binary
cd $HOME
mkdir archway && cd archway
wget "https://github.com/Northa/archway_bin/releases/download/v0.0.3/archwayd"

chmod +x archwayd
sudo mv archwayd /usr/local/bin/

# init
archwayd init ${NODENAME} --chain-id $CHAIN_ID

# config
archwayd config chain-id $CHAIN_ID
archwayd config keyring-backend file

# download addrbook and genesis
wget -qO $HOME/.archway/config/genesis.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/augusta/genesis.json"
wget -qO $HOME/.archway/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/augusta/addrbook.json"
wget -qO $HOME/peers.txt "https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/augusta/peers.txt"

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0august\"/" $HOME/.archway/config/app.toml

# set peers and seeds
SEEDS="2f234549828b18cf5e991cc884707eb65e503bb2@34.74.129.75:31076,c8890bcde31c2959a8aeda172189ec717fef0b2b@95.216.197.14:26656"
PEERS=$(cat $HOME/peers.txt)
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.archway/config/config.toml
wget -O addrbook.json https://api.nodes.guru/addrbook_archway.json
mv addrbook.json $HOME/.archway/config/
# enable prometheus
sed -i.bak -e "s/prometheus = false/prometheus = true/" $HOME/.archway/config/config.toml

# add external (if dont use sentry), port is default
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address = \"\"/external_address = \"$external_address:26656\"/" $HOME/.archway/config/config.toml

# enable pormetheus
sed -i.bak -e "s/prometheus = false/prometheus = true/" $HOME/.archway/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.archway/config/app.toml

# reset
archwayd unsafe-reset-all

# create service
tee $HOME/archwayd.service > /dev/null <<EOF
[Unit]
Description=ARCHWAY
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which archwayd) start --x-crisis-skip-assert-invariants
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/archwayd.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable archwayd
sudo systemctl restart archwayd

echo '=============== SETUP FINISHED ==================='
echo 'To check logs: journalctl -u archwayd -f -o cat'
echo 'To check sync status: curl -s localhost:26657/status'
