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
echo "export CHAIN_ID=defund-private-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Your node name: ' $NODENAME
echo 'Your wallet name: ' $WALLET
echo 'Your chain name: ' $CHAIN_ID
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

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
git clone https://github.com/defund-labs/defund
cd defund
make install

# config
defundd config chain-id $CHAIN_ID
defundd config keyring-backend file

# init
defundd init $NODENAME --chain-id $CHAIN_ID

# download addrbook and genesis
wget -qO $HOME/.defund/config/genesis.json "https://raw.githubusercontent.com/defund-labs/defund/163e2669b6870aa26b73d843312b22c9948b29c6/testnet/private/genesis.json"
wget -qO $HOME/.defund/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/defund/addrbook.json"

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ufetf\"/" $HOME/.defund/config/app.toml

# set peers and seeds
SEEDS="8e1590558d8fede2f8c9405b7ef550ff455ce842@51.79.30.9:26656,bfffaf3b2c38292bd0aa2a3efe59f210f49b5793@51.91.208.71:26656,106c6974096ca8224f20a85396155979dbd2fb09@198.244.141.176:26656"
PEERS="1a4f0f016ffc8f6814835dc20f5bb7050b2eac90@38.242.239.25:26656,1bb2bee27bf4bec8d66733b21d5c83a9787ecc51@5.189.154.161:26656,5a63b4c492d05e29f7457ea995e6247c79ecf4ca@62.171.177.143:26656,d4a297941d3c3a0cb0f54c6adf1bcbdc706b15ec@62.171.162.201:26656,65296c9968fbeca4d9d2a6c1f5dc4f04f6686580@45.88.188.158:26656,2db5d89ae038a9340733584c793dd39af2287e31@65.108.201.154:2070,1211a8e7aac5a7251c390ec76b85a56a67c25fdf@94.130.200.168:36156,509e915bb4f0a7fae2071de3c126bf467736f45d@65.108.140.212:26656,0f4c9898124564b0090b2f1c59a1312e92231c71@65.108.103.236:27656,c5b45ca6d5a902bfc28a3f7ac1e8bfeb2e113961@168.119.67.71:62036"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.defund/config/config.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.defund/config/config.toml

# add external (if dont use sentry), port is default
# external_address=$(wget -qO- eth0.me)
# sed -i -e "s/^external_address = \"\"/external_address = \"$external_address:26656\"/" $HOME/.defund/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.defund/config/app.toml

# disable indexing
sed -i.bak -e "s/indexer *=.*/indexer = \"null\"/g" $HOME/.defund/config/config.toml
sed -i "s/index-events=.*/index-events=[\"tx.hash\",\"tx.height\",\"block.height\"]/g" $HOME/.defund/config/app.toml

# reset
defundd tendermint unsafe-reset-all

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
tee $HOME/defundd.service > /dev/null <<EOF
[Unit]
Description=defundd
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which defundd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/defundd.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable defundd
sudo systemctl restart defundd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u defundd -f -o cat\e[0m'
echo -e 'To check sync status: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info\e[0m'
