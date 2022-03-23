#!/usr/bin/env bash
. ~/.bashrc
if [ ! $MASA_NODENAME ]; then
	read -p "Enter node name: " MASA_NODENAME
	echo 'export MASA_NODENAME='$MASA_NODENAME >> $HOME/.bash_profile
	. ~/.bash_profile
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
sudo systemctl restart masad && journalctl -u masad -f -o cat
