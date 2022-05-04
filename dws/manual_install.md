<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/166676803-ee125d04-dfe2-4c92-8f0c-8af357aad691.png">
</p>

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
echo "export CHAIN_ID=deweb-testnet-1" >> $HOME/.bash_profile
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
git clone https://github.com/deweb-services/deweb.git
cd deweb
git checkout v0.2
make build
sudo cp build/dewebd /usr/local/bin/dewebd
```

## Config app
```
dewebd config chain-id $CHAIN_ID
dewebd config keyring-backend file
```

## Init app
```
dewebd init $NODENAME --chain-id $CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.deweb/config/genesis.json "https://raw.githubusercontent.com/deweb-services/deweb/main/genesis.json"
wget -qO $HOME/.deweb/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/dws/addrbook.json"
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0udws\"/" $HOME/.deweb/config/app.toml
```

## Set seeds and peers
```
SEEDS="74d8f92c37ffe4c6393b3718ca531da8f0bf0594@seed1.deweb.services:26656"
PEERS="a0434d6b1d1fa4cb3a6f619df3f49ada83d2abb7@167.235.57.142:26656,580b1bb524717c9f9340bc4052ef99eb38a32e28@185.216.203.24:26656,da6130e91acde648d23dda2847587f2cee86fb14@213.136.92.246:46656,33aa64ec6be8d1da694c9cb89111fb7481c36a50@66.94.120.208:26656,2d9d9cc1dcffe9484826f86037d50e79c96b9419@66.94.120.207:26656,4ba39c0031d6795ac9ca4900c113c594ec1540d7@173.249.9.186:36656,c9717257204a2dc05dfd3fda01d0c7b9982ae3a7@144.126.142.139:26656,986c2116fac2d9442190a7755b29793663da530d@65.108.199.79:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.deweb/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.deweb/config/config.toml
```

# config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.deweb/config/app.toml
```

## Reset chain data
```
dewebd unsafe-reset-all
```

## Create service
```
tee /etc/systemd/system/dewebd.service > /dev/null <<EOF
[Unit]
Description=dewebd
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which dewebd) start
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
sudo systemctl enable dewebd
sudo systemctl restart dewebd
```
