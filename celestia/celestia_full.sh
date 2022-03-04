#!/usr/bin/env bash
. ~/.bashrc

if [ ! $CELESTIA_VALIDATOR_IP ]; then
	read -p "Enter your validator IP or press enter use default [localhost]: " CELESTIA_VALIDATOR_IP
	CELESTIA_VALIDATOR_IP=${CELESTIA_VALIDATOR_IP:-localhost}
	echo 'export CELESTIA_VALIDATOR_IP='$CELESTIA_VALIDATOR_IP >> $HOME/.bash_profile
	. ~/.bash_profile
fi

CELESTIA_NODE_VERSION=$(curl -s "https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/latest_node.txt")
echo 'export CELESTIA_NODE_VERSION='$CELESTIA_NODE_VERSION >> $HOME/.bash_profile
source $HOME/.bash_profile

if [ "$CELESTIA_VALIDATOR_IP" != "localhost" ]; then
	##### INSTALL DEPENDENCIES #####
	# update packages
	echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
	export DEBIAN_FRONTEND=noninteractive
	apt-get update && 
		apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --allow-change-held-packages &&
		apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -q -y --allow-change-held-packages
	sleep 3
	sudo apt-get install build-essential -y && sudo apt-get install jq -y
	sleep 1
	
	# install go
	sudo rm -rf /usr/local/go
	curl https://dl.google.com/go/go1.17.2.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf -

	cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF

	. $HOME/.bash_profile

	cp /usr/local/go/bin/go /usr/bin
fi

cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout $CELESTIA_NODE_VERSION
make install

# You can use your own trusted server aka application (validator) node
# TRUSTED_SERVER="IP:PORT"
# for local node use
# TRUSTED_SERVER="localhost:26657"

# or mzonder's server (for testing purposes)
# TRUSTED_SERVER=$(curl -s "https://raw.githubusercontent.com/maxzonder/celestia/main/trusted_server.txt")

# add protocol and port
TRUSTED_SERVER="http://$CELESTIA_VALIDATOR_IP:26657"

# current block hash
TRUSTED_HASH=$(curl -s $TRUSTED_SERVER/status | jq -r .result.sync_info.latest_block_hash)

echo '==================================='
echo 'Your trusted server:' $TRUSTED_SERVER
echo 'Your trusted hash:' $TRUSTED_HASH
echo 'Your node version:' $CELESTIA_NODE_VERSION
echo '==================================='

# save vars
echo 'export TRUSTED_SERVER='${TRUSTED_SERVER} >> $HOME/.bash_profile
echo 'export TRUSTED_HASH='${TRUSTED_HASH} >> $HOME/.bash_profile
source $HOME/.bash_profile

# do init
rm -rf $HOME/.celestia-full
celestia full init --core.remote $TRUSTED_SERVER --headers.trusted-hash $TRUSTED_HASH

# config p2p
sed -i.bak -e 's/PeerExchange = false/PeerExchange = true/g' $HOME/.celestia-full/config.toml

# Run as service
sudo tee /etc/systemd/system/celestia-full.service > /dev/null <<EOF
[Unit]
Description=celestia-full node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which celestia) full start
Restart=on-failure
RestartSec=10
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-full
sudo systemctl daemon-reload
sudo systemctl restart celestia-full

echo '==================================='
echo 'Setup is finished!'
echo 'To check app logs: journalctl -fu celestia-full -o cat'
echo '==================================='
