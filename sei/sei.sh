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
SEI_PORT=12
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export SEI_CHAIN_ID=sei-testnet-2" >> $HOME/.bash_profile
echo "export SEI_PORT=${SEI_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$SEI_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$SEI_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux -y

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
cd $HOME
sudo rm sei-chain -rf
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.2beta
make install 
sudo mv ~/go/bin/seid /usr/local/bin/seid

# config
seid config chain-id $SEI_CHAIN_ID
seid config keyring-backend test
seid config node tcp://localhost:${SEI_PORT}657

# init
seid init $NODENAME --chain-id $SEI_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/genesis.json"
wget -qO $HOME/.sei/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/addrbook.json"

# set peers and seeds
SEEDS=""
PEERS="bccab1003dd4f794ad8be49209700129fb86de99@38.242.221.88:26656,9d008f97b36634038318fc7a6d38e4978dac30f1@185.218.125.252:36376,07536775a07378711a9e8e772fbba231cbe72e4d@135.181.249.17:26656,38b4d78c7d6582fb170f6c19330a7e37e6964212@194.163.189.114:46656,a74b7ce1f17bf0f907fa9afac35d568a0f0d1be7@161.97.101.182:26656,404d6a9fc895bb29487acc6e2b0e3eb8db4d3591@38.242.237.233:36376,60072f103317b08a879f5289b32ce77b4459a85e@144.91.96.37:26656,f6c80c797ab4b3161fbf758ed23573c11ea5d559@173.212.215.104:26356,aab3bba2d43c669af98ed12110965aa5406d80f4@167.235.247.75:26656,a2cc243ec9b0e4d251f9cf0f6353934400efd501@65.21.131.215:26696,7f0960fb4cb46877036cd9bbb7b5b4c0d428a25b@65.108.204.119:46656,85b1b27fe8bebc7356db8b67b71d3660bd9a990e@217.79.178.14:36656,1ef8e08999ca9e78bae039f99726273bb45308b1@78.47.118.55:26656,b598895524b0566fefec4554d87a90d685fbf17c@167.235.22.62:26656,e8ce5e9e2e558995200869003606833f48b82c5c@135.181.136.33:21656,a327fec642e28ad634d473aa7361f5c528d460a7@65.21.245.204:26656,5bc51fba57616d8b29f9946c7221c6dfee1cb363@207.180.221.9:26656,52d4fdc4cdbfa831d669e1dd7594460fc4ef0547@135.181.150.45:26656,05c40c953348ba521a1ab424546bd27cea98fb0a@35.202.172.225:26656,14815555e184f7c324164dd9fab28d1ef82441d7@185.252.232.115:26656,1643290fc6c082787dec187908b257dabdbdb10a@142.132.226.193:26656,d52c416dafffaf06004c48bd9670ccb70809887d@80.87.200.127:26656,7e8a75a307f1e5b384363608c7f56ba072e8adfb@207.154.215.172:26656,645923152f90c35fbfeaf7ff0845518ea8d9cf7c@178.128.196.154:26656,4292b95b1722e97b10471618ca219e2eb12b6aa5@38.242.216.201:26656,6a1df7b06df67690fc8278ebf9c7d9c430fe76ad@178.20.44.109:26656,24d6a6bef9be26c1d8112fcd4c143423716c3f2b@134.209.194.216:26656,99393b1c278292ee7de394c8c633e05048428b1b@52.165.81.45:26656,0f466b832a0c4ca266b85964998b6ce87c32bb00@154.12.242.17:26656,ff5ae1e9616e9ae075bfdf36825e0b83c109a334@68.183.75.184:26656,e99e7c8cbea8f21582262479e757af42051b7877@38.242.247.140:26656,e677be91206ece2bf1090bd47a913814c896253a@85.12.236.11:26656,5ed56d1ea06881e27d993959e822d5c42f34ddf7@173.82.101.30:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sei/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SEI_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SEI_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SEI_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SEI_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SEI_PORT}660\"%" $HOME/.sei/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SEI_PORT}317\"%; s%^address = \":8080\"%address = \":${SEI_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SEI_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SEI_PORT}091\"%" $HOME/.sei/config/app.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.sei/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sei/config/app.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usei\"/" $HOME/.sei/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sei/config/config.toml

# reset
seid tendermint unsafe-reset-all --home $HOME/.sei

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/seid.service > /dev/null <<EOF
[Unit]
Description=sei
After=network-online.target

[Service]
User=$USER
ExecStart=$(which seid) start --home $HOME/.sei
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable seid
sudo systemctl restart seid

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u seid -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${SEI_PORT}657/status | jq .result.sync_info\e[0m"
