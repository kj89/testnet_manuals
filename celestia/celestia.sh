#!/usr/bin/env bash
. ~/.bashrc
if [ ! $CELESTIA_NODENAME ]; then
	read -p "Enter node name: " CELESTIA_NODENAME
	echo 'export CELESTIA_NODENAME='$CELESTIA_NODENAME >> $HOME/.bash_profile
	. ~/.bash_profile
fi

echo 'export CELESTIA_WALLET=wallet' >> $HOME/.bash_profile
echo 'export CELESTIA_CHAIN=devnet-2' >> $HOME/.bash_profile

echo '==================================='
echo 'Your node name: ' $CELESTIA_NODENAME
echo 'Your node name: ' $CELESTIA_WALLET
echo 'Your node name: ' $CELESTIA_CHAIN
echo '==================================='

sleep 2
export DEBIAN_FRONTEND=noninteractive
apt-get update && 
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes &&
    apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -q -y --force-yes
sleep 3
sudo apt-get install build-essential -y && sudo apt-get install jq -y
sleep 1

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

go version

cd $HOME
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app/
make install

cd $HOME
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
make install

cd $HOME
git clone https://github.com/celestiaorg/networks.git

# do init
celestia-appd init $CELESTIA_NODENAME --chain-id $CELESTIA_CHAIN

# get network configs
cp ~/networks/$CELESTIA_CHAIN/genesis.json  ~/.celestia-app/config/

#update seeds
seeds='"74c0c793db07edd9b9ec17b076cea1a02dca511f@46.101.28.34:26656"'
echo $seeds
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/" $HOME/.celestia-app/config/config.toml

# Run as service
sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-appd.service
[Unit]
Description=celestia-appd Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/celestia-appd start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-appd
sudo systemctl daemon-reload
sudo systemctl restart celestia-appd

echo 'Node status:'$(sudo service celestia-appd status | grep active)