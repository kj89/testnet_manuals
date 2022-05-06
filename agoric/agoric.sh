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
wget -O go1.17.1.linux-amd64.tar.gz https://golang.org/dl/go1.17.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz && rm go1.17.1.linux-amd64.tar.gz
tee $HOME/.bash_profile > /dev/null <<EOF
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile

# get chain id
echo "export CHAIN_ID=$(jq -r .chainName < $HOME/chain.json)" >> $HOME/.bash_profile

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
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
wget -qO $HOME/.agoric/config/genesis.json "curl https://devnet.agoric.net/genesis.json > $HOME/.agoric/config/genesis.json"

# set peers and seeds
peers=$(jq '.peers | join(",")' < chain.json)
seeds=$(jq '.seeds | join(",")' < chain.json)
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
echo -e 'To check logs: \e[1m\e[32mjournalctl -ujournalctl -u agd -f -o cat\e[0m'
echo -e 'To check sync status: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info\e[0m'
