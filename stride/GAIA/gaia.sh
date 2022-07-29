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
GAIA_PORT=23
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export GAIA_CHAIN_ID=GAIA" >> $HOME/.bash_profile
echo "export GAIA_PORT=${GAIA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$GAIA_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$GAIA_PORT\e[0m"
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
git clone https://github.com/Stride-Labs/gaia.git
cd gaia
git checkout 5b47714dd5607993a1a91f2b06a6d92cbb504721
make build
sudo cp $HOME/gaia/build/gaiad /usr/local/bin

# config
gaiad config chain-id $GAIA_CHAIN_ID
gaiad config keyring-backend test
gaiad config node tcp://localhost:${GAIA_PORT}657

# init
gaiad init $NODENAME --chain-id $GAIA_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.gaia/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/gaia/gaia_genesis.json"

# set peers and seeds
SEEDS=""
PEERS="ec829f12f6d513384e6c5ae79220455e0d80163c@104.208.67.175:23656n88f9b658a77a1ed7376adbc6d0584da8c1a35f6f@176.124.213.56:23656nb8948a13a8953f864ff43fa31ede14a21e44efdc@88.208.57.200:26656nb3dee7da18fc03c8f9481bad25a06138c7badd8c@86.48.2.74:23656nb7716bc446bd0c636ccb343c408065af71fbb576@159.65.20.94:23656n4f0e774fdf629771045fc95e74145d04e899af92@134.122.96.36:23656na3720d1999a88056ef74fdb923e27dfd9c24c01d@40.114.118.113:23656n8f7058c8d3ba5b889c9895ed4525cb89e64f0a8b@75.119.133.19:23656nb767515dca0be232fc287e0d274831a8c80fcac7@5.9.147.22:26256nc3c32094135bc9d9148dbcbac52fdace8d01d62c@51.77.108.119:23656na3b3668f967de210ae31ce779deed03f91074038@185.249.225.35:23656nd241b443f87c613d8e7039acd64ff7c296166b99@38.242.134.205:23656n8e2cf0c23b69924a8442b8102951778bd5254773@38.242.233.25:23656n4e6ba3223ba24e27eccffede205e4cffcbae903a@38.242.135.66:23656n9c86d46e33566001c89d274e2559932a4e98e406@20.90.88.145:23656nccadfbc7c6204887edc9a6eba5f9beed78ffe9de@149.102.137.76:23656nc24fecd05c85385aaa84e587557285e7dfe38d54@217.160.207.56:23656nc6dcce40e8b8a00f353a642ef0ee3623a333c067@20.230.133.117:23656n964f3d7398196238acd9e26cc96ad7787c7513f6@45.130.104.89:23656nff3a2a2022b2d53541efc0403af302eae2775da5@51.159.182.149:23656n6567e116f975eb36be8e15598f10917dab831c35@31.207.44.66:23656n853174f1ca8b78fbbfdefd32af7cc1f3fc424ce3@185.182.187.33:23656n6fd97df135f806249b55789d314b1482df38d366@20.213.53.251:23656n2101d45204248d9a8b825a23950370029d5e136e@195.88.87.43:23656n75c0154117e46f29b1eee482d740f0cc73ef76ed@164.92.80.118:23656nf6149bcd125f8972b0dc333c84cfef6fc3b9b54a@20.193.154.140:23656n6b85c6a0b2cdcf05d0ce5b2f6a78728b510fcb01@131.255.179.4:23656n87c1cebe140dbde04644e62a31af7863fa1b4fc5@157.245.0.168:23656na64faaf6fe45425352524341d2f390ce6c603c09@139.162.2.113:23656n712f37d4e5f080452759bb6f4c7ed1716270584f@20.25.144.37:23656n23e60781c1e71968d7412cb6f45aa7d5648f2517@52.234.146.133:23656naa3aa0e1244c0503b6d94d7a2ab4554ba0e3fd79@173.212.233.187:23656n7f248115c0636860cfcdfaec5a20f42bc6d622a2@38.242.222.136:23656nc5291f693b9b4117c28067sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gaia/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${GAIA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${GAIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${GAIA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${GAIA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${GAIA_PORT}660\"%" $HOME/.gaia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${GAIA_PORT}317\"%; s%^address = \":8080\"%address = \":${GAIA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${GAIA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${GAIA_PORT}091\"%" $HOME/.gaia/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gaia/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uatom\"/" $HOME/.gaia/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.gaia/config/config.toml

# reset
gaiad tendermint unsafe-reset-all --home $HOME/.gaia

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/gaiad.service > /dev/null <<EOF
[Unit]
Description=gaia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gaiad) start --home $HOME/.gaia
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable gaiad
sudo systemctl restart gaiad

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u gaiad -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${GAIA_PORT}657/status | jq .result.sync_info\e[0m"
