#!/usr/bin/env bash
. ~/.bashrc

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=mooncat-1-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Your node name: ' $NODENAME
echo 'Your wallet name: ' $WALLET
echo 'Your chain name: ' $CHAIN_ID
echo '================================================='
sleep 2

# update
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

# download binary
git clone https://github.com/crescent-network/crescent
cd crescent
git checkout v1.0.0-rc1
make install

chmod +x crescentd
sudo mv crescentd /usr/local/bin/

# init
crescentd init ${NODENAME} --chain-id $CHAIN_ID

# config
crescentd config chain-id $CHAIN_ID
crescentd config keyring-backend file

# download addrbook and genesis
wget -qO $HOME/.crescent/config/genesis.json "http://5.9.119.23/snapshots/crescent/genesis.json"

# set peers and seeds
SEEDS="1fe40daaf2643fd3857e30f86ff30ea82bf1c03b@54.169.204.99:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.crescent/config/config.toml

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
