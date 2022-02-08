#!/usr/bin/env bash
# wget -q -O agoric_mainnet.sh https://api.nodes.guru/agoric_mainnet.sh && chmod +x agoric_mainnet.sh && sudo /bin/bash agoric_mainnet.sh
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
wget -O nodesgurulogo https://api.nodes.guru/logo.sh
chmod +x nodesgurulogo
./nodesgurulogo
sleep 3

curl https://deb.nodesource.com/setup_14.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
export DEBIAN_FRONTEND=noninteractive
apt-get update && 
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes &&
    apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -q -y --force-yes
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

export GIT_BRANCH=agoric-3
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-3.1
make build
. $HOME/.bash_profile
cp $HOME/ag0/build/ag0 /usr/local/bin

curl https://main.agoric.net/network-config > chain.json
chainName=`jq -r .chainName < chain.json`
echo $chainName

ag0 init --chain-id $chainName $AGORIC_NODENAME
curl https://main.agoric.net/genesis.json > $HOME/.agoric/config/genesis.json 
ag0 unsafe-reset-all
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
ExecStart=$(which ag0) start --log_level=info
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