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
AURA_PORT=17
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export AURA_CHAIN_ID=euphoria-1" >> $HOME/.bash_profile
echo "export AURA_PORT=${AURA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$AURA_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$AURA_PORT\e[0m"
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
git clone https://github.com/aura-nw/aura && cd aura
git checkout euphoria_4027003
make install

# config
aurad config chain-id $AURA_CHAIN_ID
aurad config keyring-backend test
aurad config node tcp://localhost:${AURA_PORT}657

# init
aurad init $NODENAME --chain-id $AURA_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.aura/config/genesis.json "https://raw.githubusercontent.com/aura-nw/testnets/main/euphoria-1/genesis.json"

# set peers and seeds
SEEDS="705e3c2b2b554586976ed88bb27f68e4c4176a33@13.250.223.114:26656,b9243524f659f2ff56691a4b2919c3060b2bb824@13.214.5.1:26656"
PEERS="ca57fb351699ec368127973f246ab04381b726d2@135.181.154.42:36656,a8f02c61ae74b646c323ac5c98a1eae6a4770141@116.202.112.175:26656,64fdaa6da59901793beda215679ac2a6549b46b4@144.91.122.166:26656,bf9bd3bf988f9c869416d8254678f8dc0123bf14@178.18.252.197:26656,bfa492255ba40d3422f3078bfd6e55696ba005c0@65.108.101.50:60756,3d6b07bdb11754c8c8512525dac109d8bdee3857@65.21.53.39:56656,2e1407476ad3566eb11ac92ad1df4782c7ba83dd@18.143.61.108:26656,7812205773ac30f3d47200ac2391c79896c60135@54.254.220.113:26656,6e36fc042ea8210d34d6c7629586b555ecb84307@51.91.146.110:26656,594f32a7496097e5c8cecd23156862e714c9a729@144.76.224.246:56656,679b953c7f95ca4445e9284a2ecdcf58360ccc76@38.242.215.194:26656,a1f4205a10d99a56a47842bc9091182e5c039ea6@185.144.99.246:26656,7241697d037363bf542d096e5a01308377d5f0a9@51.222.244.75:20356,7f68aa91cc4b6cbbc781ee1d23879324299140d9@13.215.141.96:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.aura/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${AURA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${AURA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${AURA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${AURA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${AURA_PORT}660\"%" $HOME/.aura/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${AURA_PORT}317\"%; s%^address = \":8080\"%address = \":${AURA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${AURA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${AURA_PORT}091\"%" $HOME/.aura/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.aura/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.aura/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.aura/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.aura/config/app.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ueaura\"/" $HOME/.aura/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.aura/config/config.toml

# reset
aurad unsafe-reset-all --home $HOME/.aura

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/aurad.service > /dev/null <<EOF
[Unit]
Description=aura
After=network-online.target

[Service]
User=$USER
ExecStart=$(which aurad) start --home $HOME/.aura
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable aurad
sudo systemctl restart aurad

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u aurad -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${AURA_PORT}657/status | jq .result.sync_info\e[0m"
