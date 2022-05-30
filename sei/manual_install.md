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
```
NODENAME=<MY_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=sei-testnet-1" >> $HOME/.bash_profile
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
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.0beta
go build -o build/seid ./cmd/sei-chaind
chmod +x ./build/seid && sudo mv ./build/seid /usr/local/bin/seid
```

## Config app
```
seid config chain-id $CHAIN_ID
seid config keyring-backend file
```

## Init app
```
seid init $NODENAME --chain-id $CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.sei-chain/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-1/genesis.json"
wget -qO $HOME/.sei-chain/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-1/addrbook.json"
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usei\"/" $HOME/.sei-chain/config/app.toml
```

## Set seeds and peers
```
SEEDS=""
PEERS="585727dac5df8f8662a8ff42052a9584a1f7ee95@165.22.25.77:26656,2f047e234cb8b99fe8b9fee0059a5bc45042bc97@95.216.84.188:26656,bab4849cf3918c37b04cd3714984d1765616a4b2@49.12.76.255:36656,ab955dc7f70d8613ab4b554868d4658fd70b797b@217.79.180.194:26656,39c4bcaded0d1d886f2788ae955f1939406f3e7d@65.108.198.54:26696,9db58dba3b6354177fb428caccf5167c616ad4a1@167.235.28.18:26656,2f2804434afda302c86eb89eca27503e49a8a260@65.21.131.215:26696,38b4d78c7d6582fb170f6c19330a7e37e6964212@194.163.189.114:46656,7c5ee0d66a15013f0a771055378c5316331f17ba@95.216.101.84:25646,6f71bcbe347069fc4df9b607f6b843226e8deb71@95.217.221.201:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sei-chain/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sei-chain/config/config.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sei-chain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sei-chain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sei-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sei-chain/config/app.toml
```

## Reset chain data
```
seid unsafe-reset-all
```

## Create service
```
tee /etc/systemd/system/seid.service > /dev/null <<EOF
[Unit]
Description=seid
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which seid) start
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
sudo systemctl enable seid
sudo systemctl restart seid
```
