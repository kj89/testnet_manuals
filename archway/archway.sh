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
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=torii-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Your node name: ' $NODENAME
echo 'Your wallet name: ' $WALLET
echo 'Your chain name: ' $CHAIN_ID
echo '================================================='
sleep 2

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# install go
ver="1.17.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# download binary
cd $HOME
git clone https://github.com/archway-network/archway
cd archway
git checkout main
make install

# config
archwayd config chain-id $CHAIN_ID
archwayd config node https://rpc.torii-1.archway.tech:443
archwayd config keyring-backend file

# init
archwayd init $NODENAME --chain-id $CHAIN_ID

# download addrbook and genesis
wget -qO $HOME/.archway/config/genesis.json "https://raw.githubusercontent.com/archway-network/testnets/main/torii-1/genesis.json"

# set minimum gas price
sed -i.bak -e "s/^minimum-gas-prices = \"\"/minimum-gas-prices = \"0utorii\"/" $HOME/.archway/config/app.toml

# set peers and seeds
SEEDS=`curl -sL https://raw.githubusercontent.com/archway-network/testnets/main/torii-1/persistent_peers.txt | awk '{print $1}' | paste -s -d, -`
PEERS="facf38daac7cbbdcbaf87f531225d6a621cea483@15.235.10.78:26656,07fd2c5b8838dfc80ff1e9c5577006b552fcb98c@206.221.181.234:46656,83b18e67dca836a838361496a7c87696a488fd05@65.108.99.224:26656,c5ca4cb89df8c194e6b404f54be0e27c1258377b@95.214.55.210:26756,ece6b901c278f91410b798edef805ba1d358c660@59.13.223.197:30273,b1cedcd284964d7657d597541ec9516fa3392cd1@185.234.69.139:26656,ce1e6c7a84ab3f8e2fd87d4aef0f95da774a5e98@159.69.11.174:26656,cb1534d2ad2fedb1168b4052f04ede5b12428068@51.250.111.252:26656,2b0c484615d9bafd6cc339c588e366dd9b000221@54.180.95.251:26656,2e422fe3956b7ea2a868dbe832e8cd9af5203ea6@65.108.75.32:26656,ca8dca9c9a475b145af9cbce135d013e060649dd@65.108.194.40:26686,5d221da2ebb37a6b37ee86581457061f17e0704e@165.232.143.157:26656,5ba7f9e0905a69003dca519da8dfed09dd12471a@157.230.121.70:26656,560b00b413aadfca41a982a4381cb1736ee9d902@54.36.109.62:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.archway/config/config.toml

# enable prometheus
sed -i.bak -e "s/prometheus = false/prometheus = true/" $HOME/.archway/config/config.toml

# add external (if dont use sentry), port is default
# external_address=$(wget -qO- eth0.me)
# sed -i.bak -e "s/^external_address = \"\"/external_address = \"$external_address:26656\"/" $HOME/.archway/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="5000"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.archway/config/app.toml

# reset
archwayd unsafe-reset-all

# create service
tee $HOME/archwayd.service > /dev/null <<EOF
[Unit]
Description=ARCHWAY
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which archwayd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/archwayd.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable archwayd
sudo systemctl restart archwayd

echo '=============== SETUP FINISHED ==================='
echo 'To check logs: journalctl -u archwayd -f -o cat'
echo 'To check sync status: curl -s localhost:26657/status'
