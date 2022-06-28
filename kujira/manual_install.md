<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/172356220-b8326ceb-9950-4226-b66e-da69099aaf6e.png">
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
KUJIRA_PORT=13
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export KUJIRA_CHAIN_ID=harpoon-4" >> $HOME/.bash_profile
echo "export KUJIRA_PORT=${KUJIRA_PORT}" >> $HOME/.bash_profile
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
git clone https://github.com/Team-Kujira/core kujira-core && cd kujira-core
git checkout v0.4.0
make install
```

## Config app
```
kujirad config chain-id $KUJIRA_CHAIN_ID
kujirad config keyring-backend test
kujirad config node tcp://localhost:${KUJIRA_PORT}657
```

## Init app
```
kujirad init $NODENAME --chain-id $KUJIRA_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.kujira/config/genesis.json "https://raw.githubusercontent.com/Team-Kujira/networks/master/testnet/harpoon-4.json"
```

## Set seeds and peers
```
SEEDS=""
PEERS="4bba4fc2d07b6f8b5aa0de8668e9d10cf22f1fe8@65.108.229.56:26656,f9ee35cf9aec3010f26b02e5b3354efaf1c02d53@116.203.135.192:26656,ccd2861990a98dc6b3787451485b2213dd3805fa@185.144.99.234:26656,20f0409359fa455d7ca11b81039782a260899579@195.201.164.223:26656,1a80d041e13cb211391785cfdec25fc8ce6fb4c4@157.90.183.167:26656,06ebd0b308950d5b5a0e0d81096befe5ba07e0b3@193.31.118.143:25656,5552e4eb91dd7fe15af0dbfcbc8dad002e46d69e@188.40.140.51:40001,f5b3223131fa0b9e8ac08d4f04fd34c25b88a099@95.216.208.101:36656,c009938f56e54754a70bd6fd46b277c5c4854e56@65.108.11.180:26656,b3f4cfa9e0745f983d000994cdb171574a5cfa39@38.146.3.185:26656,"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.kujira/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${KUJIRA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${KUJIRA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${KUJIRA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${KUJIRA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${KUJIRA_PORT}660\"%" $HOME/.kujira/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${KUJIRA_PORT}317\"%; s%^address = \":8080\"%address = \":${KUJIRA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${KUJIRA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${KUJIRA_PORT}091\"%" $HOME/.kujira/config/app.toml
```

## Disable indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.kujira/config/config.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.kujira/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.kujira/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.kujira/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.kujira/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00125ukuji\"/" $HOME/.kujira/config/app.toml
sed -i -e "s/^timeout_commit *=.*/timeout_commit = \"1500ms\"/" $HOME/.kujira/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.kujira/config/config.toml
```

## Reset chain data
```
kujirad tendermint unsafe-reset-all --home $HOME/.kujira
```

## Create service
```
sudo tee /etc/systemd/system/kujirad.service > /dev/null <<EOF
[Unit]
Description=kujira
After=network-online.target

[Service]
User=$USER
ExecStart=$(which kujirad) start --home $HOME/.kujira
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
sudo systemctl enable kujirad
sudo systemctl restart kujirad && sudo journalctl -u kujirad -f -o cat
```
