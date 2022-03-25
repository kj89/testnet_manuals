#!/usr/bin/env bash
# wget -q -O agoric_devnet.sh https://api.nodes.guru/agoric_devnet.sh && chmod +x agoric_devnet.sh && sudo /bin/bash agoric_devnet.sh
. ~/.bashrc
if [ ! $AGORIC_NODENAME ]; then
	read -p "Enter node name: " AGORIC_NODENAME
	echo 'export AGORIC_NODENAME='$AGORIC_NODENAME >> $HOME/.bash_profile
	. ~/.bash_profile
fi

echo 'Your node name: ' $AGORIC_NODENAME
sleep 2
sudo dpkg --configure -a
sudo apt update
sudo apt install curl -y < "/dev/null"
sleep 1

curl https://deb.nodesource.com/setup_14.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
export DEBIAN_FRONTEND=noninteractive
apt-get update && 
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --allow-change-held-packages &&
    apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -q -y --allow-change-held-packages
sudo apt install nodejs=14.* yarn build-essential jq git -y < "/dev/null"
sleep 1

wget -O go1.17.1.linux-amd64.tar.gz https://golang.org/dl/go1.17.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz && rm go1.17.1.linux-amd64.tar.gz
cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version

git clone https://github.com/Agoric/agoric-sdk -b agoricdev-8
cd agoric-sdk

# Install and build Agoric Javascript packages
yarn install
yarn build

# Install and build Agoric Cosmos SDK support
(cd packages/cosmic-swingset && make)

curl https://devnet.agoric.net/network-config > chain.json
chainName=`jq -r .chainName < chain.json`
echo $chainName

agd init --chain-id $chainName $AGORIC_NODENAME
curl https://devnet.agoric.net/genesis.json > $HOME/.agoric/config/genesis.json 
agd unsafe-reset-all
peers=$(jq '.peers | join(",")' < chain.json)
seeds=$(jq '.seeds | join(",")' < chain.json)
echo $peers
echo $seeds
sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml
sudo tee <<EOF >/dev/null /etc/systemd/system/agoricd.service
[Unit]
Description=Agoric Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which agd) start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
. ~/.bash_profile
sed -i '/\[telemetry\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.agoric/config/app.toml
sed -i "s/prometheus-retention-time = 0/prometheus-retention-time = 60/g" $HOME/.agoric/config/app.toml
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025ubld\"/;" $HOME/.agoric/config/app.toml
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.agoric/config/config.toml
sudo systemctl enable agoricd
sudo systemctl daemon-reload
sudo systemctl restart agoricd
echo 'Node status:'$(sudo service agoricd status | grep active)