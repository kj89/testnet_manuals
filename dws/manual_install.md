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
git clone https://github.com/defund-labs/defund
cd defund
make install
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
wget -qO $HOME/.defund/config/genesis.json "https://raw.githubusercontent.com/defund-labs/defund/163e2669b6870aa26b73d843312b22c9948b29c6/testnet/private/genesis.json"
wget -qO $HOME/.defund/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/defund/addrbook.json"
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0udws\"/" $HOME/.defund/config/app.toml
```

## Set seeds and peers
```
SEEDS="8e1590558d8fede2f8c9405b7ef550ff455ce842@51.79.30.9:26656,bfffaf3b2c38292bd0aa2a3efe59f210f49b5793@51.91.208.71:26656,106c6974096ca8224f20a85396155979dbd2fb09@198.244.141.176:26656"
PEERS="79a1ca999264d15653e359742ecc696ff783e057@49.12.246.112:22256,5b10a67cad723fd13060761f8955f371fb1810a2@80.64.208.121:26656,cd3a17a6920bba732f1b2a4b3a12a435ac0845ac@49.12.225.248:26656,0409ad6d8ceef8ab01f4df458dbd58dd9ac32295@121.37.242.170:26656,6c80295b4c221e19cab7dfab496e9c15891f55ba@65.108.151.86:26656,2ef9373a0e8b5487b6fbf100d90faa641242899d@154.12.244.137:26656,1bf56637dcb950453c370ef7726da74436d21a61@95.214.52.200:26656,b9acccdd67617e15c361ea0d6fd2e16c1b9c9efc@209.145.48.178:26656,111ba4e5ae97d5f294294ea6ca03c17506465ec5@208.68.39.221:26656,0409ad6d8ceef8ab01f4df458dbd58dd9ac32295@121.37.242.170:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.defund/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.defund/config/config.toml
```

# config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.defund/config/app.toml
```

## Reset chain data
```
dewebd tendermint unsafe-reset-all
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
