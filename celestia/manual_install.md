# Manual node setup (v0.5.1)
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<MY_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=mamaki" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y
```

## Install go
```
ver="1.17.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

## Download and build binaries
```
cd $HOME
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app
APP_VERSION=$(curl -s https://api.github.com/repos/celestiaorg/celestia-app/releases/latest | jq -r ".tag_name")
git checkout tags/$APP_VERSION -b $APP_VERSION
make install
```

## setup p2p networks
```
cd $HOME
rm -rf networks
git clone https://github.com/celestiaorg/networks.git
```

## Config app
```
celestia-appd config chain-id $CHAIN_ID
celestia-appd config keyring-backend file
```

## Init app
```
celestia-appd init $NODENAME --chain-id $CHAIN_ID
```

## Update genesis
```
cp $HOME/networks/$CHAIN_ID/genesis.json $HOME/.celestia-app/config
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utia\"/" $HOME/.celestia-app/config/app.toml
```

## Set seeds, peers and boot nodes
```
BOOTSTRAP_PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/bootstrap-peers.txt | tr -d '\n')
PEERS="d0b19e4d133441fd41b4d74ac8de2138313ad49e@195.201.41.137:26656,f7b68a491bae4b10dbab09bb3a875781a01274a5@65.108.199.79:20356,853a9fbb633aed7b6a8c759ba99d1a7674b706a3@38.242.216.151:26656,42b331adaa9ece4c455b92f0d26e3382e46d43f0@161.97.180.20:36656,180378bab87c9cecea544eb406fcd8fcd2cbc21b@168.119.122.78:26656"
sed -i.bak -e "s/^bootstrap-peers *=.*/bootstrap-peers = \"$BOOTSTRAP_PEERS\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^persistent-peers *=.*/persistent-peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.celestia-app/config/config.toml
```

# Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="5000"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.celestia-app/config/app.toml
```

## Set timeouts
```
sed -i.bak -e "s/^timeout-commit *=.*/timeout-commit = \"25s\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^skip-timeout-commit *=.*/skip-timeout-commit = false/" $HOME/.celestia-app/config/config.toml
```

## Set validator mode
```
sed -i.bak -e "s/^mode *=.*/mode = \"validator\"/" $HOME/.celestia-app/config/config.toml
```

## Reset chain data
```
celestia-appd tendermint unsafe-reset-all
```

## (OPTIONAL) Use Quick Sync by restoring data from snapshot
```
cd $HOME
rm -rf ~/.celestia-app/data
mkdir -p ~/.celestia-app/data
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | egrep -o ">mamaki.*tar" | tr -d ">")
wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - -C ~/.celestia-app/data/
```

## Create service
```
tee /etc/systemd/system/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=celestia-appd
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which celestia-appd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl restart celestia-appd
```
