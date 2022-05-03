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
echo "export CHAIN_ID=devnet-2" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$CHAIN_ID\e[0m"
echo -e '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y

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

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app/
git checkout tags/v0.1.0 -b v0.1.0
make install

# setup p2p networks
cd $HOME
rm -rf networks
git clone https://github.com/celestiaorg/networks.git

# config
celestia-appd config chain-id $CHAIN_ID
celestia-appd config keyring-backend file

# init
celestia-appd init $NODENAME --chain-id $CHAIN_ID

# download genesis and addr book
cp $HOME/networks/devnet-2/genesis.json $HOME/.celestia-app/config
wget -O $HOME/.celestia-app/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/addrbook.json"

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0celes\"/" $HOME/.celestia-app/config/app.toml

# set peers and seeds
SEEDS="74c0c793db07edd9b9ec17b076cea1a02dca511f@46.101.28.34:26656"
PEERS="34d4bfec8998a8fac6393a14c5ae151cf6a5762f@194.163.191.41:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml

# enable prometheus
sed -i.bak -e "s/prometheus = false/prometheus = true/" $HOME/.celestia-app/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.celestia-app/config/app.toml

# reset
celestia-appd unsafe-reset-all

# set quicksync
function quickSync {
cd $HOME
rm -rf ~/.celestia-app/data; \
mkdir -p ~/.celestia-app/data; 
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | egrep -o ">devnet-2.*tar" | tr -d ">"); wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - -C ~/.celestia-app/data/
}

# let uset choose sync mode
while true; do
read -p "Do you want use Quick Sync for rapid data synchronization? (y/n) " yn
case $yn in 
	[yY] ) echo -e '\n\e[31mDownloading data using Quick Sync...\e[39m' && sleep 1
	quickSync
	    break;;
	[nN] ) echo -e '\n\e[31mSkipping Quick Sync...\e[39m' && sleep 1
		exit;;
	* ) echo invalid response;;
esac
done

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
tee $HOME/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=celestia-appd
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which celestia-appd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/celestia-appd.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl restart celestia-appd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u celestia-appd -f -o cat \e[0m'
echo -e 'To check sync status: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info \e[0m'
