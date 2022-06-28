<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/169664551-39020c2e-fa95-483b-916b-c52ce4cb907c.png">
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
SEI_PORT=12
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export SEI_CHAIN_ID=sei-testnet-2" >> $HOME/.bash_profile
echo "export SEI_PORT=${SEI_PORT}" >> $HOME/.bash_profile
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
cd $HOME
sudo rm sei-chain -rf
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.2beta
make install 
sudo mv ~/go/bin/seid /usr/local/bin/seid
```

## Config app
```
seid config chain-id $SEI_CHAIN_ID
seid config keyring-backend test
seid config node tcp://localhost:${SEI_PORT}657
```

## Init app
```
seid init $NODENAME --chain-id $SEI_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/genesis.json"
wget -qO $HOME/.sei/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-2/addrbook.json"
```

## Set seeds and peers
```
SEEDS=""
PEERS="a31a25a812e13bbbe58a58c14db3cd529c4f870d@3.15.197.187:26656,5b5ec09067a5fcaccf75f19b45ab29ce07e0167c@18.118.159.154:26656,20528d7ab115e56660b06fbff1b95c543e19e2e3@194.163.150.25:26256,49e9d66477cd5df48ceb884b6870cccfc5fa96c5@47.156.153.124:56656,ddb046d461bd698bf2b5f0608bc9ed9ebb69821b@20.46.229.243:12656,44c4e0294f6912b130f57a0fddc5d7434b68ca37@65.108.7.120:26656,3ddc21e72f88e1d83ff2098d25fb6988f59598fa@38.242.250.253:26656,a50a2c2a39e740e18e2a3810867ce8786d64f718@75.119.155.73:12656,591b797c0a4af6d3decaaf0f14dab8ce92d7c3ae@51.120.95.14:12656,f161690e4f552194097b3e99501a526c8862c03c@20.38.38.1:12656,b1bab63a99b58cdc05e015875e426bc28eb9716c@149.102.143.141:12656,b6e9a99fb9a960fa71d36f0c9b442c2b9fba9484@51.120.1.230:12656,c89a26cf8d4812fb8873f6e46bead2363f8ab67c@147.182.203.5:12656,52517312816bf4c6ab1d99fc347647b4626064e7@52.155.104.204:26656,7886e2704b892ed032ff5091e41542216309f39c@20.249.4.115:12656,59bbe8e365c56e29ccd1d88462fe92c43bc8e173@89.163.143.208:26656,a3f055c2cd623d9d1353d8c6566b9d00e01ef0be@13.87.71.97:12656,51213fb34076bd39d7f687ea94deb6916301d118@20.118.224.134:12656,93578f85728acfc14f8d9c1f84f7d8d0548cfd15@20.40.89.41:12656,9c74bdb1f6d34e1eb45b6810e116e8033b2d7014@20.119.48.205:12656,dff3c3c5679d06166476773d2ee777b4c6dfd3eb@52.255.136.48:12656,38b4d78c7d6582fb170f6c19330a7e37e6964212@194.163.189.114:46656,1c6b5b7d880e488e87e86b0de420ad92d4cece50@149.102.158.204:12656,edf25610498e0a1192c743f39368502ece89ec8d@144.76.19.103:26656,678580163a228a8240a3d15ee128ad94fe623141@159.89.204.218:12656,cd2ce7465937c046aeefb286744c45afd1b63ebb@139.59.100.192:12656,396f45e6270f34f608ffc1727c2fc0d1955aff3b@137.184.76.160:12656,99c0a0a5bdb19a9b8be05b8f268d6e12a01e6dc3@146.19.24.34:26656,db4fa2ced59020bcec13668b3204a2fd2ac5b720@188.166.228.170:26656,bccab1003dd4f794ad8be49209700129fb86de99@38.242.221.88:26656,d4479d0bf6e543ec60fae27206ec5a70837c555e@38.242.129.240:36376,a452faddaf371e840fcbb0e44c7234551949d1b7@34.66.153.93:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sei/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SEI_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SEI_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SEI_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SEI_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SEI_PORT}660\"%" $HOME/.sei/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SEI_PORT}317\"%; s%^address = \":8080\"%address = \":${SEI_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SEI_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SEI_PORT}091\"%" $HOME/.sei/config/app.toml
```

## Disable indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.sei/config/config.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sei/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sei/config/app.toml
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usei\"/" $HOME/.sei/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sei/config/config.toml
```

## Reset chain data
```
seid tendermint unsafe-reset-all --home $HOME/.sei
```

## Create service
```
sudo tee /etc/systemd/system/seid.service > /dev/null <<EOF
[Unit]
Description=sei
After=network-online.target

[Service]
User=$USER
ExecStart=$(which seid) start --home $HOME/.sei
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
sudo systemctl enable seid
sudo systemctl restart seid && sudo journalctl -u seid -f -o cat
```
