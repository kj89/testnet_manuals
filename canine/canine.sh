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
JACKAL_PORT=37
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export JACKAL_CHAIN_ID=canine-1" >> $HOME/.bash_profile
echo "export JACKAL_PORT=${JACKAL_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$JACKAL_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$JACKAL_PORT\e[0m"
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
git clone https://github.com/JackalLabs/canine-chain.git
cd canine-chain
git checkout v1.1.1
make install

# config
canined config chain-id $JACKAL_CHAIN_ID
canined config keyring-backend test
canined config node tcp://localhost:${JACKAL_PORT}657

# init
canined init $NODENAME --chain-id $JACKAL_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.canine/config/genesis.json "https://raw.githubusercontent.com/JackalLabs/woof/master/genesis/woof-final.json"

# set peers and seeds
SEEDS="052c498dd1cc603b4d32f772035b6a8ca902def3@23.88.73.211:26656,0bdeaaa237b41e3b964a027a110c6ab5bf561177@209.34.206.38:26656,bf7ee27a24e7d5f45653206fbbda8c4b716b74b1@89.58.38.59:26656,9eecc498dd2542c862f5bfb84ed7d2e1e3d922ab@34.201.48.14:26656,bf62b185eef3c185f8ebf81d5cf54bdc064b21d8@85.10.216.157:26656,43e800018a5b52ba119a5410ff45cbeb63182cc8@207.244.127.5:26656,942087a9665e8235f8037d0b9d2a3f8a8c3d562b@104.207.138.181:26656,9d0094606fe8748f1c06b494f7c0cbbd44808ec6@131.153.59.6:26656,6071fe2fc7e4f49caa4b1fd1cfe19007152312e0@34.76.87.33:26656,3f58d7c35ad55ef6cea94f7aa2ffe79df1c01768@78.107.253.133:26656,46cb18ca32ad7329cb82a10316087794ef12150f@185.107.57.74:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.canine/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${JACKAL_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${JACKAL_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${JACKAL_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${JACKAL_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${JACKAL_PORT}660\"%" $HOME/.canine/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${JACKAL_PORT}317\"%; s%^address = \":8080\"%address = \":${JACKAL_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${JACKAL_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${JACKAL_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${JACKAL_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${JACKAL_PORT}546\"%" $HOME/.canine/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.canine/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.canine/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.canine/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.canine/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ujkl\"/" $HOME/.canine/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.canine/config/config.toml

# reset
canined tendermint unsafe-reset-all --home $HOME/.canine

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/canined.service > /dev/null <<EOF
[Unit]
Description=canine
After=network-online.target

[Service]
User=$USER
ExecStart=$(which canined) start --home $HOME/.canine
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable canined
sudo systemctl restart canined

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u canined -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${JACKAL_PORT}657/status | jq .result.sync_info\e[0m"
