#!/usr/bin/env bash
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

# install go 1.17.2
ver="1.17.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# build binary
cd $HOME
rm -rf masa-node-v1.0
git clone https://github.com/masa-finance/masa-node-v1.0

cd masa-node-v1.0/src
git checkout v1.03
make all

# copy binaries
cd $HOME/masa-node-v1.0/src/build/bin
sudo cp * /usr/local/bin

# init
cd $HOME/masa-node-v1.0
geth --datadir data init ./network/testnet/genesis.json

# load bootnodes
cd $HOME
wget https://raw.githubusercontent.com/kj89/testnet_manuals/main/masa/bootnodes.txt
MASA_BOOTNODES=$(sed ':a; N; $!ba; s/\n/,/g' bootnodes.txt)

# create masad service
tee $HOME/masad.service > /dev/null <<EOF
[Unit]
Description=MASA
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which geth) \
  --identity ${MASA_NODENAME} \
  --datadir $HOME/masa-node-v1.0/data \
  --port 30300 \
  --syncmode full \
  --verbosity 3 \
  --emitcheckpoints \
  --istanbul.blockperiod 10 \
  --mine \
  --miner.threads 1 \
  --networkid 190260 \
  --http --http.corsdomain "*" --http.vhosts "*" --http.addr 127.0.0.1 --http.port 8545 \
  --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul \
  --maxpeers 50 \
  --bootnodes ${MASA_BOOTNODES}
Restart=on-failure
RestartSec=10
LimitNOFILE=4096
Environment="PRIVATE_CONFIG=ignore"
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/masad.service /etc/systemd/system

# Start service
sudo systemctl daemon-reload
sudo systemctl enable masad
sudo systemctl restart masad

# get node configs
MASA_NODEKEY=$(cat $HOME/masa-node-v1.0/data/geth/nodekey)
MASA_ENODE=$(geth attach ipc:$HOME/masa-node-v1.0/data/geth.ipc --exec web3.admin.nodeInfo.enode | sed 's/^.//;s/.$//')
echo 'export MASA_NODEKEY='$MASA_NODEKEY >> $HOME/.bash_profile
echo 'export MASA_ENODE='$MASA_ENODE >> $HOME/.bash_profile
source ~/.bash_profile


echo -e "\e[1m\e[32mMasa started \e[0m"
echo "=================================================="
echo -e "Your node name: \e[32m$MASA_NODENAME\e[39m"
echo -e "Your enode: \e[32m$MASA_ENODE\e[39m"
echo -e "Your node key: \e[32m$MASA_NODEKEY\e[39m"
echo "=================================================="

echo -e "\e[1m\e[32mTo open geth: \e[0m" 
echo -e "\e[1m\e[39m    geth attach ipc:$HOME/masa-node-v1.0/data/geth.ipc \n \e[0m" 

echo -e "\e[1m\e[32mTo view logs: \e[0m" 
echo -e "\e[1m\e[39m    journalctl -u masad -f \n \e[0m" 

echo -e "\e[1m\e[32mTo restart: \e[0m" 
echo -e "\e[1m\e[39m    systemctl restart masad.service \n \e[0m" 

echo -e "Please make sure you have backed up your masa nodekey: \e[32m$MASA_NODEKEY\e[39m"
echo -e "To restore on other server please insert your node key into \e[32m$HOME/masa-node-v1.0/data/geth/nodekey\e[39m and restart service"
