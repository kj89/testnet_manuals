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
echo "export PALOMA_CHAIN_ID=paloma" >> $HOME/.bash_profile
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
wget -O - https://github.com/palomachain/paloma/releases/download/v0.2.1-prealpha/paloma_0.2.1-prealpha_Linux_x86_64v3.tar.gz | \
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
wget -qO ~/.paloma/config/genesis.json https://raw.githubusercontent.com/palomachain/testnet/master/passerina/genesis.json
wget -qO ~/.paloma/config/addrbook.json https://raw.githubusercontent.com/palomachain/testnet/master/passerina/addrbook.json
```

## Set seeds and peers
```
SEEDS=""
PEERS="30d92940f03052f942401165689b2e70e041fc8e@167.235.243.186:26656,02c92c5ebd44822d26dc88f6e1a333cf692cf802@95.31.16.222:26656,8e365511d7cd078ae8f0acf771dc3642f6eaa077@20.127.7.19:36416,0f4411c257bfe7bf191c2c3fd32b385a363487cf@167.71.247.34:26656,fae84ec72a6f686d76096053e0532a65b69e5228@143.198.169.111:26656,a70cab8943a70171272d62e6e3e2eaf704b9693c@149.102.148.127:26656,f5fd79e1086ebd5503e0ab19314746a7b1b8e220@144.91.77.189:36776,7980e25d5a9f8370969676808e4be7244b5d6a67@134.209.95.202:26656,cbef1c2d365c1b087e22e5d1c3ebdd10250e34d2@159.65.14.48:26656,dcc02e5e4e9aa8bec92a27bb148a20232d913420@5.161.111.18:26656,fd12957ba333022359b5a7c2285aa158ae6af04c@195.201.235.194:26656,92cbddc9bd34904b2044d640c5da1c6da4b81877@194.163.169.166:26656,14ca25ab5cfdc7a28b6600e4ac64303035e4e65a@54.193.147.0:26656,5af8117a3b45f9611a910954735367f867530825@46.228.199.8:26656,8ec7f59d20d2155d3b0f7b09b4762248ce84f04e@74.220.22.51:26656,8bbe63d166c3c09241ba93464449e4b8009d17eb@20.240.51.154:26656,949f02a722f1d1bbb254091c77a4837df392717a@165.232.130.3:26656,c9b64b1f2e305c8f406801af891592ff1141a77d@161.97.73.185:26656,e756146a910dadb75deaed8a6dc2491fe6fe3677@143.198.179.94:26656,03d507609c6cb48998d8bd7e9c612324bcc6ff87@188.166.168.176:36416,89b9f4fed146b01044dc9f72ead13c6537367cbd@20.102.99.251:26656,a6fb5aaabe1170c5b3d3a654502e77701fdde2e4@207.244.237.70:26656,120be42c0d9061ae7ade4445159034b496240f76@20.114.129.135:26656,78b6d4fbc0ac6c4b9c0e10659ae669766d785855@65.21.151.93:26656"
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
palomad tendermint unsafe-reset-all
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
