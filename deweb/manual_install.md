<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/JqQNcwff2e" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>
<p style="font-size:14px" align="right">
<a href="https://m.do.co/c/17b61545ca3a" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus for 60 days <img src="https://user-images.githubusercontent.com/50621007/183284313-adf81164-6db4-4284-9ea0-bcb841936350.png" width="30"/></a>
</p>
<p style="font-size:14px" align="right">
<a href="https://www.vultr.com/?ref=7418642" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus <img src="https://user-images.githubusercontent.com/50621007/183284971-86057dc2-2009-4d40-a1d4-f0901637033a.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/166676803-ee125d04-dfe2-4c92-8f0c-8af357aad691.png">
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
DEWEB_PORT=14
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export DEWEB_CHAIN_ID=deweb-testnet-2" >> $HOME/.bash_profile
echo "export DEWEB_PORT=${DEWEB_PORT}" >> $HOME/.bash_profile
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
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi
```

## Download and build binaries
```
cd $HOME
git clone https://github.com/deweb-services/deweb.git
cd deweb
git checkout v0.3
make build
sudo cp build/dewebd /usr/local/bin/dewebd
```

## Config app
```
dewebd config chain-id $DEWEB_CHAIN_ID
dewebd config keyring-backend test
dewebd config node tcp://localhost:${DEWEB_PORT}657
```

## Init app
```
dewebd init $NODENAME --chain-id $DEWEB_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.deweb/config/genesis.json "https://raw.githubusercontent.com/deweb-services/deweb/main/genesis.json"
```

## Set seeds and peers
```
SEEDS="08b7968ec375444f86912c2d9c3d28e04a5f14c4@seed1.deweb.services:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.deweb/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${DEWEB_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${DEWEB_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${DEWEB_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DEWEB_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${DEWEB_PORT}660\"%" $HOME/.deweb/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${DEWEB_PORT}317\"%; s%^address = \":8080\"%address = \":${DEWEB_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${DEWEB_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${DEWEB_PORT}091\"%" $HOME/.deweb/config/app.toml
```

## Disable indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.deweb/config/config.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.deweb/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.deweb/config/app.toml
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0udws\"/" $HOME/.deweb/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.deweb/config/config.toml
```

## Reset chain data
```
dewebd tendermint unsafe-reset-all --home $HOME/.deweb
```

## Create service
```
sudo tee /etc/systemd/system/dewebd.service > /dev/null <<EOF
[Unit]
Description=deweb
After=network-online.target

[Service]
User=$USER
ExecStart=$(which dewebd) start --home $HOME/.deweb
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
sudo systemctl enable dewebd
sudo systemctl restart dewebd && sudo journalctl -u dewebd -f -o cat
```
