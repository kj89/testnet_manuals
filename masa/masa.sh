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

. ~/.bashrc
if [ ! $MASA_NODENAME ]; then
	read -p "Enter node name: " MASA_NODENAME
	echo 'export MASA_NODENAME='$MASA_NODENAME >> $HOME/.bash_profile
	source ~/.bash_profile
fi

# server update
sudo apt update && sudo apt upgrade -y

# install packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu net-tools -y

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

# build binary
cd $HOME && rm -rf masa-node-v1.0
git clone https://github.com/masa-finance/masa-node-v1.0
cd masa-node-v1.0/src
make all
cp $HOME/masa-node-v1.0/src/build/bin/* /usr/local/bin

# init
cd $HOME/masa-node-v1.0
geth --datadir data init ./network/testnet/genesis.json

# load bootnodes
cd $HOME
wget https://raw.githubusercontent.com/kj89/testnet_manuals/main/masa/bootnodes.txt
MASA_BOOTNODES=$(sed ':a; N; $!ba; s/\n/,/g' bootnodes.txt)

# create masad service
tee /etc/systemd/system/masad.service > /dev/null <<EOF
[Unit]
Description=MASA
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which geth) \
  --identity ${MASA_NODENAME} \
  --datadir $HOME/masa-node-v1.0/data \
  --bootnodes ${MASA_BOOTNODES} \
  --emitcheckpoints \
  --istanbul.blockperiod 10 \
  --mine \
  --miner.threads 1 \
  --syncmode full \
  --verbosity 5 \
  --networkid 190260 \
  --rpc \
  --rpccorsdomain "*" \
  --rpcvhosts "*" \
  --rpcaddr 127.0.0.1 \
  --rpcport 8545 \
  --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul \
  --port 30300 \
  --maxpeers 50
Restart=on-failure
RestartSec=10
LimitNOFILE=4096
Environment="PRIVATE_CONFIG=ignore"
[Install]
WantedBy=multi-user.target
EOF

# Start service
sudo systemctl daemon-reload
sudo systemctl enable masad
sudo systemctl restart masad

# wait before pulling configs
sleep 10

# get node configs
MASA_NODEKEY=$(cat $HOME/masa-node-v1.0/data/geth/nodekey)
MASA_ENODE=$(geth attach ipc:$HOME/masa-node-v1.0/data/geth.ipc --exec web3.admin.nodeInfo.enode | sed 's/^.//;s/.$//')

echo -e "\e[1m\e[32mMasa started \e[0m"

echo -e "Your node name: \e[32m$MASA_NODENAME\e[39m"
echo -e "Your enode: \e[32m$MASA_ENODE\e[39m"
echo -e "Your node key: \e[32m$MASA_NODEKEY\e[39m"


echo -e "\e[1m\e[32mTo open geth: \e[0m" 
echo -e "\e[1m\e[39m    geth attach ipc:$HOME/masa-node-v1.0/data/geth.ipc \n \e[0m" 

echo -e "\e[1m\e[32mTo view logs: \e[0m" 
echo -e "\e[1m\e[39m    journalctl -u masad -f \n \e[0m" 

echo -e "\e[1m\e[32mTo restart: \e[0m" 
echo -e "\e[1m\e[39m    systemctl restart masad.service \n \e[0m" 

echo -e "Please make sure you have backed up your masa nodekey: \e[32m$MASA_NODEKEY\e[39m"
echo -e "To restore on other server please insert your node key into \e[32m$HOME/masa-node-v1.0/data/geth/nodekey\e[39m and restart service"
