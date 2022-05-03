# Manual node  setup (v0.4.0)
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
echo "export CHAIN_ID=devnet-2" >> $HOME/.bash_profile
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
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app
git checkout v0.4.0
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

## Download genesis and addrbook
```
cp $HOME/networks/devnet-2/genesis.json $HOME/.celestia-app/config
wget -O $HOME/.celestia-app/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/addrbook.json"
```

## Set minimum gas price
```
sed -i.bak -e "s/^minimum-gas-prices = \"\"/minimum-gas-prices = \"0celes\"/" $HOME/.celestia-app/config/app.toml
```

## Set seeds and peers
```
SEEDS="74c0c793db07edd9b9ec17b076cea1a02dca511f@46.101.28.34:26656"
PEERS="34d4bfec8998a8fac6393a14c5ae151cf6a5762f@194.163.191.41:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml
```

## Enable prometheus
```
sed -i.bak -e "s/prometheus = false/prometheus = true/" $HOME/.celestia-app/config/config.toml
```

# config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.celestia-app/config/app.toml
```

## Reset chain data
```
celestia-appd unsafe-reset-all
```

## (OPTIONAL) Use Quick Sync by restoring data from snapshot
```
cd $HOME
rm -rf ~/.celestia-app/data; \
mkdir -p ~/.celestia-app/data; 
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | egrep -o ">devnet-2.*tar" | tr -d ">"); wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - -C ~/.celestia-app/data/
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
