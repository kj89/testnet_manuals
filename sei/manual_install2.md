<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/169664551-39020c2e-fa95-483b-916b-c52ce4cb907c.png">
</p>

# Manual node setup
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
<MY_MONIKER_NAME_GOES_HERE>
```
NODENAME=kjnodes
WALLET=wallet
CHAIN_ID=sei-testnet-2
APP_NAME=seid
APP_HOME=$HOME/.sei
APP_DENOM=usei
```

Save and import variables into system
```
echo "export SEI_NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export SEI_WALLET=$WALLET" >> $HOME/.bash_profile
echo "export SEI_CHAIN_ID=$CHAIN_ID" >> $HOME/.bash_profile
echo "export SEI_APP_NAME=${APP_NAME}" >> $HOME/.bash_profile
echo "export SEI_APP_HOME=$APP_HOME" >> $HOME/.bash_profile
echo "export SEI_APP_DENOM=$APP_DENOM" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl build-essential git wget jq make gcc tmux -y
```

## Install go
```
ver="1.18.1"
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
rm sei-chain -rf
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.2beta
make install 
mv ~/go/bin/seid /usr/local/bin/seid
```

## Config app
```
$SEI_APP_NAME config chain-id $SEI_CHAIN_ID
$SEI_APP_NAME config keyring-backend file
```

## Init app
```
$SEI_APP_NAME init $SEI_$NODENAME --chain-id $SEI_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $SEI_APP_HOME/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/genesis.json"
wget -qO $SEI_APP_HOME/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/addrbook.json"
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$SEI_APP_DENOM\"/" $SEI_APP_HOME/config/app.toml
```

## Set seeds and peers
```
SEEDS=""
PEERS="c4c6ead7b3d5ddf85e62704d56746c2d4be88bee@65.21.181.135:26656,38b4d78c7d6582fb170f6c19330a7e37e6964212@194.163.189.114:46656,5b5ec09067a5fcaccf75f19b45ab29ce07e0167c@18.118.159.154:26656,b20fa6b0a283e153c446fd58dd1e1ae56b09a65d@159.69.110.238:26656,613f6f5a67c4f0625599ca74b98b7d722f908262@159.65.195.25:36376,1c384cbe9421957813f49865bb8db8c190a90415@139.59.38.171:36376,8b5d1f7d5422e373b00c129ccda14556b69e2a61@167.235.21.137:26656,8c4ec366b5ebd182ffe463e3e1a3a6a345d7d1eb@80.82.215.233:26656,214d45c890cccc09ee725bd101a60dcd690cd554@49.12.215.72:26676,d87dcc1d6b5517b4da9a1ca48717a68ee3bd1d6a@89.163.215.204:26656,fed3ec8e12ddde3fc8e90efc1746e55d10a623f0@65.109.11.114:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $SEI_APP_HOME/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $SEI_APP_HOME/config/config.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $SEI_APP_HOME/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $SEI_APP_HOME/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $SEI_APP_HOME/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $SEI_APP_HOME/config/app.toml
```

## Reset chain data
```
$SEI_APP_NAME tendermint unsafe-reset-all
```

## Create service
```
tee /etc/systemd/system/$SEI_APP_NAME.service > /dev/null <<EOF
[Unit]
Description=$SEI_APP_NAME
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $SEI_APP_NAME) start
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
sudo systemctl enable $SEI_APP_NAME
sudo systemctl restart $SEI_APP_NAME
```
