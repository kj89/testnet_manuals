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
TERITORI_PORT=19
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export TERITORI_CHAIN_ID=teritori-testnet-v2" >> $HOME/.bash_profile
echo "export TERITORI_PORT=${TERITORI_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$TERITORI_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$TERITORI_PORT\e[0m"
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
git clone https://github.com/TERITORI/teritori-chain
cd teritori-chain
git checkout teritori-testnet-v2
make install

# config
teritorid config chain-id $TERITORI_CHAIN_ID
teritorid config keyring-backend test
teritorid config node tcp://localhost:${TERITORI_PORT}657

# init
teritorid init $NODENAME --chain-id $TERITORI_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.teritori/config/genesis.json "https://raw.githubusercontent.com/TERITORI/teritori-chain/main/testnet/teritori-testnet-v2/genesis.json"

# set peers and seeds
SEEDS=""
PEERS="0b42fd287d3bb0a20230e30d54b4b8facc412c53@176.9.149.15:26656,2371b28f366a61637ac76c2577264f79f0965447@176.9.19.162:26656,2f394edda96be07bf92b0b503d8be13d1b9cc39f@5.9.40.222:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.teritori/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${TERITORI_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${TERITORI_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${TERITORI_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${TERITORI_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${TERITORI_PORT}660\"%" $HOME/.teritori/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${TERITORI_PORT}317\"%; s%^address = \":8080\"%address = \":${TERITORI_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${TERITORI_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${TERITORI_PORT}091\"%" $HOME/.teritori/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.teritori/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.teritori/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.teritori/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.teritori/config/app.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ueteritori\"/" $HOME/.teritori/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.teritori/config/config.toml

# reset
teritorid unsafe-reset-all --home $HOME/.teritori

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/teritorid.service > /dev/null <<EOF
[Unit]
Description=teritori
After=network-online.target

[Service]
User=$USER
ExecStart=$(which teritorid) start --home $HOME/.teritori
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable teritorid
sudo systemctl restart teritorid

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u teritorid -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${TERITORI_PORT}657/status | jq .result.sync_info\e[0m"
