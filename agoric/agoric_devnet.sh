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

# download network configuration
curl https://devnet.agoric.net/network-config > $HOME/chain.json

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# install node.js
curl https://deb.nodesource.com/setup_14.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt upgrade -y
sudo apt install nodejs=14.* yarn build-essential jq -y
sleep 1

# install go
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# get chain id
echo "export CHAIN_ID=$(jq -r .chainName < $HOME/chain.json)" >> $HOME/.bash_profile

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd /usr/src/
git clone https://github.com/Agoric/agoric-sdk -b $CHAIN_ID
cd agoric-sdk

# Install and build Agoric Javascript packages
yarn install
yarn build

# Install and build Agoric Cosmos SDK support
(cd packages/cosmic-swingset && make)

# config
agd config chain-id $CHAIN_ID
agd config keyring-backend file

# init
agd init $NODENAME --chain-id $CHAIN_ID

# download genesis
curl https://devnet.rpc.agoric.net/genesis | jq .result.genesis > $HOME/.agoric/config/genesis.json 

# set peers and seeds
peers=$(jq '.peers | join(",")' < $HOME/chain.json)
seeds=$(jq '.seeds | join(",")' < $HOME/chain.json)
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml

# Fix `Error: failed to parse log level`
sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.agoric/config/config.toml

# reset
agd unsafe-reset-all

# create service
tee /etc/systemd/system/agd.service > /dev/null <<EOF
[Unit]
Description=Agoric Cosmos daemon
After=network-online.target

[Service]
# OPTIONAL: turn on JS debugging information.
#SLOGFILE=.agoric/data/chain.slog
User=$USER
# OPTIONAL: turn on Cosmos nondeterminism debugging information
#ExecStart=$(which agd) start --log_level=info --trace-store=.agoric/data/kvstore.trace
ExecStart=$(which agd) start --log_level=warn
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# start service
sudo systemctl daemon-reload
sudo systemctl enable agd
sudo systemctl restart agd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u agd -f -o cat\e[0m'
echo -e 'To check sync status: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info\e[0m'
