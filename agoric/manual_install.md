<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/167032367-fee4380e-7678-43e0-9206-36d72b32b8ae.png">
</p>

# Manual node  setup
If you want to setup fullnode manually follow the steps below

## Save network configuration to file
```
curl https://devnet.agoric.net/network-config > $HOME/chain.json
```

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<MY_MONIKER_NAME_GOES_HERE>
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

## Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=$(jq -r .chainName < $HOME/chain.json)" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Install node.js
```
curl https://deb.nodesource.com/setup_14.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt upgrade -y
sudo apt install nodejs=14.* yarn build-essential jq -y
```

## Install go
```
sudo rm -rf /usr/local/go
curl https://go.dev/dl/go1.18.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf -
tee $HOME/.bash_profile > /dev/null <<EOF
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile
```

## Download and build binaries
```
cd $HOME
git clone https://github.com/Agoric/agoric-sdk -b $CHAIN_ID
cd agoric-sdk
yarn install
yarn build
(cd packages/cosmic-swingset && make)
```

## Config app
```
agd config chain-id $CHAIN_ID
agd config keyring-backend file
```

## Init app
```
agd init $NODENAME --chain-id $CHAIN_ID
```

## Download genesis file
```
wget -qO $HOME/.agoric/config/genesis.json "curl https://devnet.agoric.net/genesis.json > $HOME/.agoric/config/genesis.json"
```

## Set seeds and peers
```
peers=$(jq '.peers | join(",")' < chain.json)
seeds=$(jq '.seeds | join(",")' < chain.json)
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml
```

# Fix `Error: failed to parse log level`
```
sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.agoric/config/config.toml
```

# (OPTIONAL) config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.agoric/config/app.toml
```

## Reset chain data
```
agd unsafe-reset-all
```

## Create service
```
tee /etc/systemd/system/agd.service > /dev/null <<EOF
[Unit]
Description=Agoric Cosmos daemon
After=network-online.target

[Service]
# OPTIONAL: turn on JS debugging information.
#SLOGFILE=.agoric/data/chain.slog
User=$USER
# OPTIONAL: turn on Cosmos nondeterminism debugging information
#ExecStart=$(which agd) start --log_level=info --trace-store=.agoric/data/kvstore.trace
ExecStart=$(which agd) start --log_level=warn
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable agd
sudo systemctl restart agd
```
