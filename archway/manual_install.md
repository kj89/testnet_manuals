# Manual node  setup
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
echo "export CHAIN_ID=torii-1" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
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
git clone https://github.com/archway-network/archway
cd archway
git checkout main
make install
```

## Config app
```
archwayd config chain-id $CHAIN_ID
archwayd config keyring-backend file
```

## Init app
```
archwayd init $NODENAME --chain-id $CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.archway/config/genesis.json "https://raw.githubusercontent.com/archway-network/testnets/main/torii-1/genesis.json"
wget -qO $HOME/.archway/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/addrbook.json"
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utorii\"/" $HOME/.archway/config/app.toml
```

## Set seeds and peers
```
SEEDS=`curl -sL https://raw.githubusercontent.com/archway-network/testnets/main/torii-1/persistent_peers.txt | awk '{print $1}' | paste -s -d, -`
PEERS="2b0c484615d9bafd6cc339c588e366dd9b000221@54.180.95.251:26656,5d221da2ebb37a6b37ee86581457061f17e0704e@165.232.143.157:26656,5ba7f9e0905a69003dca519da8dfed09dd12471a@157.230.121.70:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.archway/config/config.toml
```

## Enable prometheus
```
sed -i.bak -e "s/prometheus = false/prometheus = true/" $HOME/.archway/config/config.toml
```

# config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.archway/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.archway/config/app.toml
```

## Reset chain data
```
archwayd tendermint unsafe-reset-all
```

## Create service
```
tee /etc/systemd/system/archwayd.service > /dev/null <<EOF
[Unit]
Description=archwayd
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which archwayd) start
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
sudo systemctl enable archwayd
sudo systemctl restart archwayd
```
