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
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
TERP_PORT=33
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export TERP_CHAIN_ID=athena-1" >> $HOME/.bash_profile
echo "export TERP_PORT=${TERP_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$TERP_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$TERP_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/terpnetwork/terp-core.git
cd terp-core
make install

# config
terpd config chain-id $TERP_CHAIN_ID
terpd config keyring-backend test
terpd config node tcp://localhost:${TERP_PORT}657

# init
terpd init $NODENAME --chain-id $TERP_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.terp/config/genesis.json "https://raw.githubusercontent.com/terpnetwork/test-net/master/athena-1/genesis.json"

# set peers and seeds
SEEDS="5a6f4f80c7a29055028fc503216a1539594ad33f@89.111.15.146:11513"
PEERS="15f5bc75be9746fd1f712ca046502cae8a0f6ce7@terp-testnet.nodejumper.io:30656,65f819851e9eb2484818cb7d12f4edd759a1223a@65.21.143.79:25856,c989593c89b511318aa6a0c0d361a7a7f4271f28@65.108.124.172:26656,e6630d7bcc1c6c9593fdcb7e7e1fb762b3e257d1@65.21.134.202:26636,74a37dda6fe3b8c88630b8e2eb808abccba14a44@65.21.131.215:26636,abf05e076f72192c0f45c3e6cef9f5bd285fac4b@65.21.151.93:46656,d6d7e96122f61a3a2216df9a74822171489a0e17@65.109.17.86:34656,1f5b5de284d47acd69ba73461fb6894a051bec59@51.75.88.124:26656,84d770b9c4d10c734fd9ec5753ab19d4693ecbcd@116.202.236.115:21316,a4f76a1c232dece6aa80ba9ada569d3355111c69@78.46.16.236:47656,ff2ee3da5675de1dcd25aca8d7958d9a0b439f55@185.237.252.152:36656,9b0c5af3f13fe8ca3d0a89d5752e8f5f9062ce7c@95.216.168.99:60656,c2a177164098b317261d55fb1c946a97e5e35adb@75.119.134.69:30656,2e4e0f43100b424dc4b27e478acc39bebe32344d@77.37.176.99:55656,63910944ee1c3dd7ae683cc4b96241bcf059c08f@167.99.0.78:26656,3786f8392cf865c8fd4f599f30f5047c33977432@135.181.221.186:29656,7e5c0b9384a1b9636f1c670d5dc91ba4721ab1ca@195.201.218.107:36656,c583c0a09ba50fb2eef6cb665dbdea1e5b790ffd@161.97.167.120:20656,88497ab3bbbcc1e8545771f45020e738bcce590f@46.138.245.164:26465,3122336186c16b9ba7f309afbac06412183121f8@65.108.103.86:56656,a24cbc18af3f3558719e2f479ff412f60e126683@181.41.142.78:11504,7cd2881b35643352deed6ec283727c3d05be7502@38.242.214.172:11656,69dd5a6c7d11903a6198109576fa739a216ed92a@97.84.107.110:26656,6cdf2bca6266926c5524404f8898c5b8894e8554@65.108.70.119:21856,e95eaf418dc2e61437f1b514eda666cd20949571@149.102.143.147:46656,2c7cef934ae39bc6a2fb240b4bfb2c3e0ba0be4e@193.46.243.184:36656,14ca69edabb36c51504f1a760292f8e6b9190bd7@65.21.138.123:28656,d2af3d86ee5698037d802567ed930f8d58d89c25@38.242.199.93:16656,cfce40d126cc442267f931c42703155b00bf06c6@65.21.251.128:26656,c73dc07274fa184ceb9dbe35aa4cd75e75f3a6e8@95.217.207.236:18656,f9d7b883594e651a45e91c49712151bf93322c08@141.95.65.26:29456,c8566ae397962bd6b150db94489442957e8bac72@65.109.61.47:15656,166939372c24934c2227cf9c1f1aaa0bd55510bf@161.97.157.15:26656,5a6f4f80c7a290"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.terp/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${TERP_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${TERP_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${TERP_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${TERP_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${TERP_PORT}660\"%" $HOME/.terp/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${TERP_PORT}317\"%; s%^address = \":8080\"%address = \":${TERP_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${TERP_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${TERP_PORT}091\"%" $HOME/.terp/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.terp/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uterpx\"/" $HOME/.terp/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.terp/config/config.toml

# reset
terpd tendermint unsafe-reset-all --home $HOME/.terp

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/terpd.service > /dev/null <<EOF
[Unit]
Description=terp
After=network-online.target

[Service]
User=$USER
ExecStart=$(which terpd) start --home $HOME/.terp
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable terpd
sudo systemctl restart terpd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u terpd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${TERP_PORT}657/status | jq .result.sync_info\e[0m"
