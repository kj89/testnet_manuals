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
MANDE_PORT=38
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export MANDE_CHAIN_ID=mande-testnet-1" >> $HOME/.bash_profile
echo "export MANDE_PORT=${MANDE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$MANDE_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$MANDE_PORT\e[0m"
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
curl -OL https://github.com/mande-labs/testnet-1/raw/main/mande-chaind
mkdir -p $HOME/go/bin
mv mande-chaind /$HOME/go/bin/
chmod 744 /$HOME/go/bin/mande-chaind

# config
mande-chaind config chain-id $MANDE_CHAIN_ID
mande-chaind config keyring-backend test
mande-chaind config node tcp://localhost:${MANDE_PORT}657

# init
mande-chaind init $NODENAME --chain-id $MANDE_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.mande-chain/config/genesis.json "https://raw.githubusercontent.com/mande-labs/testnet-1/main/genesis.json"
wget -qO $HOME/.mande-chain/config/addrbook.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/Mande%20Chain/addrbook.json"

# set peers and seeds
SEEDS="cd3e4f5b7f5680bbd86a96b38bc122aa46668399@34.171.132.212:26656"
PEERS="4fbbf09c5561c4a9692e368a672b99180b3f70ee@185.182.184.200:46656,156eb9c408b5274c14e7139fa14b3210de359848@5.161.113.160:26656,6780b2648bd2eb6adca2ca92a03a25b216d4f36b@34.170.16.69:26656,736105b3a268e992d92b7e684e7692af5dbf4246@45.67.216.54:26656,5b346b9e05426f73ec04117ed5bc663fb0d0287b@65.108.205.149:26656,19a7467dc9aa99b3cdc8ee82492a57c4ffa46fc3@5.161.98.239:26656,ae7f43821ee156c16751232ac2db588eddbd2311@65.108.2.41:26656,a5553ba1568ddd609d6573d8d9c0ebcf38b56b42@93.185.166.182:26656,1fefb3ea03659e49fdcc06fefc02b784e78e00cd@62.171.133.91:26656,0583f64245d6f28a138e8e2a347d9f67344fcca0@144.76.97.251:31356"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.mande-chain/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${MANDE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${MANDE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${MANDE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${MANDE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${MANDE_PORT}660\"%" $HOME/.mande-chain/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${MANDE_PORT}317\"%; s%^address = \":8080\"%address = \":${MANDE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${MANDE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${MANDE_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${MANDE_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${MANDE_PORT}546\"%" $HOME/.mande-chain/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.mande-chain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.mande-chain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.mande-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.mande-chain/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0mand\"/" $HOME/.mande-chain/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.mande-chain/config/config.toml

# reset
mande-chaind tendermint unsafe-reset-all --home $HOME/.mande-chain

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/mande-chaind.service > /dev/null <<EOF
[Unit]
Description=mande
After=network-online.target

[Service]
User=$USER
ExecStart=$(which mande-chaind) start --home $HOME/.mande-chain
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable mande-chaind
sudo systemctl restart mande-chaind

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u mande-chaind -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${MANDE_PORT}657/status | jq .result.sync_info\e[0m"
