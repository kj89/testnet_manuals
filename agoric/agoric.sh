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

# download network configuration
curl https://main.agoric.net/network-config > $HOME/chain.json

# set vars
AGORIC_PORT=27
if [ ! $NODENAME ]; then
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export AGORIC_CHAIN_ID=$(jq -r .chainName < $HOME/chain.json)" >> $HOME/.bash_profile
echo "export AGORIC_PORT=${AGORIC_PORT}" >> $HOME/.bash_profile
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

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-upgrade-7
make build
. $HOME/.bash_profile
sudo cp $HOME/ag0/build/ag0 /usr/local/bin

# config
ag0 config chain-id $AGORIC_CHAIN_ID
ag0 config keyring-backend file
ag0 config node tcp://localhost:${AGORIC_PORT}657

# init
ag0 init $NODENAME --chain-id $AGORIC_CHAIN_ID

# download genesis
curl https://main.agoric.net/genesis.json > $HOME/.agoric/config/genesis.json 

# set peers and seeds
peers=$(jq '.peers | join(",")' < $HOME/chain.json)
peers='"2c03e71116d1a2f9ba39a63a97058fcdeabfe2be@159.148.31.233:26656,ef12448f0f8671a195ab38c590cac713ad703a8b@146.70.66.202:26656,320dd22ee85e2b68f891b670331eb9fec9dc419e@80.64.208.63:26656,f095bb53006ebddcbbf29c8df70dddcba6419e36@142.93.145.13:26656,0c370d803934e3273c61b2577a0c6e91b9f677e0@139.59.7.33:26656,c03f4e7fe0f4c081b14f6731e74aa89ff2d4c197@84.244.95.237:26656,8c30ee29afc4b77cf98222edcc3fe823cf1e8306@195.201.106.244:26656,b2285313e3411e3d5bcbee72e526108e6bd07da4@185.147.80.110:26656,68c9c4e8388ed6936ff147ffe6b9913e79328957@35.215.62.66:26656,99968808ecae7bc41b14df3bcb51b724ee5f782f@134.209.154.162:26656,2d352e7a97cef2a6b253906d3741efaee16b6af0@64.227.14.179:26656,5a6c74c824805c3e75cea44df019b69db8fb935a@142.132.149.55:26656,0464c8dded70d01f5ab50a8d6047a6b27ddf2ccd@84.244.95.232:26656,9cd93ebaa554e68990ecec234de74e848c7755e7@137.184.45.31:10003,f4b809dcf7004b8a30eaa4e9bb0a65164368b75a@49.12.165.122:26656,4d0953252dd26b5ff96292bd2a836bd8a77f4eed@159.69.63.222:26656,f554d57fd9326a90580483e23cab8d728bfb232a@78.46.84.150:26656,c84170667fcf54024b24f05b2f9dd6608570ac8c@157.90.35.145:28656,cb6ae22e1e89d029c55f2cb400b0caa19cbe5523@15.223.138.194:26603,1da72d9acd9c26a332c99e5e5f91b586f1ebc7c4@3.14.237.44:26656"'
seeds=$(jq '.seeds | join(",")' < $HOME/chain.json)
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${AGORIC_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${AGORIC_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${AGORIC_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${AGORIC_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${AGORIC_PORT}660\"%" $HOME/.agoric/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${AGORIC_PORT}317\"%; s%^address = \":8080\"%address = \":${AGORIC_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${AGORIC_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${AGORIC_PORT}091\"%" $HOME/.agoric/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.agoric/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.agoric/config/config.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025ubld\"/" $HOME/.agoric/config/app.toml

# reset
ag0 tendermint unsafe-reset-all --home $HOME/.agoric

# create service
sudo tee /etc/systemd/system/agoricd.service > /dev/null <<EOF
[Unit]
Description=agoric
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ag0) start --home $HOME/.agoric
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# start service
sudo systemctl daemon-reload
sudo systemctl enable agoricd
sudo systemctl restart agoricd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u agoricd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${AGORIC_PORT}657/status | jq .result.sync_info\e[0m"
