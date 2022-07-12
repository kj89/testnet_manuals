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
CARDCHAIN_PORT=18
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export CARDCHAIN_CHAIN_ID=Cardchain" >> $HOME/.bash_profile
echo "export CARDCHAIN_PORT=${CARDCHAIN_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$CARDCHAIN_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$CARDCHAIN_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

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
curl https://get.ignite.com/DecentralCardGame/Cardchain@latest! | sudo bash

# config
Cardchain config chain-id $CARDCHAIN_CHAIN_ID
Cardchain config keyring-backend test
Cardchain config node tcp://localhost:${CARDCHAIN_PORT}657

# init
Cardchain init $NODENAME --chain-id $CARDCHAIN_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.Cardchain/config/genesis.json "https://raw.githubusercontent.com/DecentralCardGame/Testnet1/main/genesis.json"

# set peers and seeds
SEEDS=""
PEERS="cd1c88e7829a940fc6332c925943fb0e45588121@138.201.139.175:21106,a9c56a9479bbdb8aa7bfb93bd85907bd4f4a4cca@135.181.154.42:26656,407fd08d831eaec4be840bf762740a72c5c48ea6@159.69.11.174:36656,a506820ea90c5b0ddb9005ef720a121e9f6bbaeb@45.136.28.158:26658,8b376446ae31162449c9749390830b05420bdf55@95.216.223.244:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.Cardchain/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CARDCHAIN_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CARDCHAIN_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CARDCHAIN_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CARDCHAIN_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CARDCHAIN_PORT}660\"%" $HOME/.Cardchain/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CARDCHAIN_PORT}317\"%; s%^address = \":8080\"%address = \":${CARDCHAIN_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CARDCHAIN_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CARDCHAIN_PORT}091\"%" $HOME/.Cardchain/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.Cardchain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.Cardchain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.Cardchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.Cardchain/config/app.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ubpf\"/" $HOME/.Cardchain/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.Cardchain/config/config.toml

# reset
Cardchain unsafe-reset-all --home $HOME/.Cardchain

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/Cardchain.service > /dev/null <<EOF
[Unit]
Description=Cardchain
After=network-online.target

[Service]
User=$USER
ExecStart=$(which Cardchain) start --home $HOME/.Cardchain
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable Cardchain
sudo systemctl restart Cardchain

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u Cardchain -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${CARDCHAIN_PORT}657/status | jq .result.sync_info\e[0m"
