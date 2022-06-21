<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/172488614-7d93b016-5fe4-4a51-99e2-67da5875ab7a.png">
</p>

# Manual node setup
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
PALOMA_PORT=10
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export PALOMA_CHAIN_ID=paloma-testnet-4" >> $HOME/.bash_profile
echo "export PALOMA_PORT=${PALOMA_PORT}" >> $HOME/.bash_profile
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
ver="1.18.2"
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
wget -O - https://github.com/palomachain/paloma/releases/download/v0.2.3-prealpha/paloma_0.2.3-prealpha_Linux_x86_64v3.tar.gz | \
sudo tar -C /usr/local/bin -xvzf - palomad
sudo chmod +x /usr/local/bin/palomad
sudo wget -P /usr/lib https://github.com/CosmWasm/wasmvm/raw/main/api/libwasmvm.x86_64.so
```

## Config app
```
palomad config chain-id $PALOMA_CHAIN_ID
palomad config keyring-backend test
palomad config node tcp://localhost:${PALOMA_PORT}657
```

## Init app
```
palomad init $NODENAME --chain-id $PALOMA_CHAIN_ID
```

## Download genesis and addrbook
```
wget -O ~/.paloma/config/genesis.json https://raw.githubusercontent.com/palomachain/testnet/master/paloma-testnet-4/genesis.json
wget -O ~/.paloma/config/addrbook.json https://raw.githubusercontent.com/palomachain/testnet/master/paloma-testnet-4/addrbook.json
```

## Set seeds and peers
```
SEEDS=""
PEERS="a689a738bbb3f62b9548a527a23e89e0669bf990@134.209.109.171:26656,0b1069ced6f67579fb2a4b1f1913e51869812850@173.212.238.31:26656,705367a8a361f8ce86d60d564991e0f3a95f549d@35.184.103.87:26656,4ab3e9f2f25c741d13336c8b7f4ac45694a5bc00@34.135.148.102:26656,fb465466cf245e6be9607c00b8c79bb61a7f25d5@46.101.119.246:26656,aebc4e3a1b90d546bcd5c7ee23e12bab7aed9e53@137.184.178.183:26656,5190404f478fecfd48e1e8a6ea3df2d32c85a67f@149.102.155.181:26656,301938da656d6224fdd35f806b1d2b67d94d8d36@34.69.131.169:26656,7367f20644b42f83edfaf633d62a21a2af3238ca@185.249.225.121:26656,19fa9d5f250f1b3ecef9e5d9ba1580f1ecb1a8f0@176.57.189.36:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.paloma/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PALOMA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PALOMA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PALOMA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PALOMA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PALOMA_PORT}660\"%" $HOME/.paloma/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PALOMA_PORT}317\"%; s%^address = \":8080\"%address = \":${PALOMA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PALOMA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PALOMA_PORT}091\"%" $HOME/.paloma/config/app.toml
```

## Disable indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.paloma/config/config.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.paloma/config/app.toml
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ugrain\"/" $HOME/.paloma/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.paloma/config/config.toml
```

## Reset chain data
```
palomad tendermint unsafe-reset-all --home $HOME/.paloma
```

## Create service
```
sudo tee /etc/systemd/system/palomad.service > /dev/null <<EOF
[Unit]
Description=paloma
After=network-online.target

[Service]
User=$USER
ExecStart=$(which palomad) start
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
sudo systemctl enable palomad
sudo systemctl restart palomad && sudo journalctl -u palomad -f -o cat
```
