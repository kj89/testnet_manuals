#!/usr/bin/env bash
. ~/.bashrc

# set vars
if [ ! $CRESCENT_NODENAME ]; then
	read -p "Enter node name: " CRESCENT_NODENAME
	echo 'export CRESCENT_NODENAME='$CRESCENT_NODENAME >> $HOME/.bash_profile
fi
echo "export CRESCENT_WALLET=wallet" >> $HOME/.bash_profile
echo "export CRESCENT_CHAIN=mooncat-1-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Your node name: ' $CRESCENT_NODENAME
echo 'Your wallet name: ' $CRESCENT_WALLET
echo 'Your chain name: ' $CRESCENT_CHAIN
echo '================================================='
sleep 2

# update
sudo apt update && sudo apt upgrade -y

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

# download binary
cd $HOME
mkdir crescent && cd crescent
git clone https://github.com/crescent-network/crescent
cd crescent
git checkout v1.0.0-rc3
make install

chmod +x crescentd
sudo mv crescentd /usr/local/bin/

# init
crescentd init ${CRESCENT_NODENAME} --chain-id $CRESCENT_CHAIN

# config
crescentd config chain-id $CRESCENT_CHAIN
crescentd config keyring-backend file

# download addrbook and genesis
wget -qO $HOME/.crescent/config/genesis.json "http://5.9.119.23/snapshots/crescent/genesis.json"

# set peers and seeds
SEEDS="1fe40daaf2643fd3857e30f86ff30ea82bf1c03b@54.169.204.99:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.crescent/config/config.toml

# add external (if dont use sentry), port is default
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address = \"\"/external_address = \"$external_address:26656\"/" $HOME/.crescent/config/config.toml

# enable pormetheus
sed -i.bak -e "s/prometheus = false/prometheus = true/" $HOME/.crescent/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="5000"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.crescent/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.crescent/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.crescent/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.crescent/config/app.toml

# reset
crescentd unsafe-reset-all

# create service
tee /etc/systemd/system/crescentd.service > /dev/null <<EOF
[Unit]
  Description=Crescent Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which crescentd) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable crescentd
sudo systemctl restart crescentd

echo '=============== SETUP FINISHED ==================='
echo 'To check logs: journalctl -u crescentd -f -o cat'
echo 'To check sync status: curl -s localhost:26657/status'
