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
BOOTSTRAP_PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/bootstrap-peers.txt | tr -d '\n' && echo $BOOTSTRAP_PEERS)
PEERS="e4429e99609c8c009969b0eb73c973bff33712f9@141.94.73.39:43656,09263a4168de6a2aaf7fef86669ddfe4e2d004f6@142.132.209.229:26656,13d8abce0ff9565ed223c5e4b9906160816ee8fa@94.62.146.145:36656,72b34325513863152269e781d9866d1ec4d6a93a@65.108.194.40:26676,322542cec82814d8903de2259b1d4d97026bcb75@51.178.133.224:26666,5273f0deefa5f9c2d0a3bbf70840bb44c65d835c@80.190.129.50:49656,7145da826bbf64f06aa4ad296b850fd697a211cc@176.57.189.212:26656,5a4c337189eed845f3ece17f88da0d94c7eb2f9c@209.126.84.147:26656,ec072065bd4c6126a5833c97c8eb2d4382db85be@88.99.249.251:26656,cd1524191300d6354d6a322ab0bca1d7c8ddfd01@95.216.223.149:26656,2fd76fae32f587eceb266dce19053b20fce4e846@207.154.220.138:26656,1d6a3c3d9ffc828b926f95592e15b1b59b5d8175@135.181.56.56:26656,fe2025284ad9517ee6e8b027024cf4ae17e320c9@198.244.164.11:26656,fcff172744c51684aaefc6fd3433eae275a2f31b@159.203.18.242:26656"
sed -i.bak -e "s/^bootstrap-peers *=.*/bootstrap-peers = \"$BOOTSTRAP_PEERS\"/; s/^persistent-peers *=.*/persistent-peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.celestia-app/config/config.toml
```

# config pruning
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

## Reset chain data
```
celestia-appd unsafe-reset-all --home $HOME/.celestia-app
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
