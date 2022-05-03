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
echo "export CHAIN_ID=umee-1" >> $HOME/.bash_profile
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
# install packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu net-tools -y

# install go 1.17.7
ver="1.17.7"
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
git clone https://github.com/umee-network/umee.git
cd umee
git pull
git checkout tags/v1.0.3
make build
sudo cp $HOME/umee/build/umeed /usr/local/bin

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# init
umeed init $NODENAME --chain-id $CHAIN_ID

# config
umeed config chain-id $CHAIN_ID
umeed config keyring-backend file

# download genesis
wget -O $HOME/.umee/config/genesis.json "https://github.com/umee-network/mainnet/raw/main/genesis.json"

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001uumee\"/" $HOME/.umee/config/app.toml

# enable api and grpc
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.umee/config/app.toml

# update peers and allow external connections
peers="f1dc58164af33f2db6c5a5bd6b2646399b18bbb4@35.187.48.177:26656,6b785fc3a088de3a5e8d222a980936f2187b8c56@34.65.213.164:26656"
sed -i -e "s/^external_address = \"\"/external_address = \"0.0.0.0:26656\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.umee/config/config.toml

# reset
umeed unsafe-reset-all

# create service
tee /etc/systemd/system/umeed.service > /dev/null <<EOF
[Unit]
  Description=Crescent Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which umeed) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable umeed
sudo systemctl restart umeed

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32m umeed -f -o cat\e[0m'
echo -e 'To check sync status: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info\e[0m'
