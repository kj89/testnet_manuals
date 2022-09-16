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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/190717698-486153c1-5d81-4e57-9363-cead70c13cc8.png">
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
OSMOSIS_PORT=29
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OSMOSIS_CHAIN_ID=osmosis-1" >> $HOME/.bash_profile
echo "export OSMOSIS_PORT=${OSMOSIS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y
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
git clone https://github.com/osmosis-labs/osmosis.git -B v11.0.1
cd osmosis
make install
```

## Config app
```
osmosisd config chain-id $OSMOSIS_CHAIN_ID
osmosisd config keyring-backend file
osmosisd config node tcp://localhost:${OSMOSIS_PORT}657
```

## Init app
```
osmosisd init $NODENAME --chain-id $OSMOSIS_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.osmosisd/config/genesis.json https://github.com/osmosis-labs/networks/raw/main/osmosis-1/genesis.json
wget -qO $HOME/.osmosisd/config/addrbook.json https://snapshots1.polkachu.com/addrbook/osmosis/addrbook.json
```

## Set seeds and peers
```
SEEDS=""
PEERS="d589eb77d7dfebec659ce8bce9f903250301c8ba@116.202.216.57:26656,a72323512ddedf580affb0e0ba0bb32218ae8e6d@34.105.148.8:26656,f225f8a168ec794d334d7100994b62e5e7648072@35.234.158.17:26656,e3a17384a87cfca72b2cb5a0d642d1192fb3749e@65.108.110.206:26656,85082964a2d06ec99f2bb0787aed8ff7cb05d68f@141.95.110.187:26656,a2ead216394ea406b311e79998d562264411d592@5.161.124.187:26656,1e77db4642bf0f399b72bc01620e015ec05e14ce@51.81.155.97:26656,a22b249c21ad0c50e471520b3f3bb38a7fe246e2@155.138.144.222:26656,ef30bc7dbac63eb868e66bad497368f2cd0924e1@141.98.217.102:26656,f352d93fda033b62d403daf40bd6df95cf5057e8@35.86.226.142:26656,fe5ba77a8ce8937875c5064093f5d63ba32abacf@45.77.52.17:26656,797094953d830f8727f3b5175f2b205df16d5867@45.77.212.231:26656,2048e1bc1f020fa210fb475e7a0ec0948919609f@185.217.125.64:26656,b69e57cd6f796ac5d6efb1a834163365c37cbfa8@78.46.69.29:26656,c094d4bb9e38ac0b1b50a866499b47604c749e5b@74.118.139.212:26656,43785e5ffd8783393ea8094f77efcee5bdbcdce3@78.141.244.18:26656,7f4b9aca876a03c426208bfddbc6509cbf24b39d@209.250.243.8:26656,"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.osmosisd/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OSMOSIS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OSMOSIS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OSMOSIS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OSMOSIS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OSMOSIS_PORT}660\"%" $HOME/.osmosisd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OSMOSIS_PORT}317\"%; s%^address = \":8080\"%address = \":${OSMOSIS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OSMOSIS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OSMOSIS_PORT}091\"%" $HOME/.osmosisd/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.osmosisd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.osmosisd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.osmosisd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.osmosisd/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uosmo\"/" $HOME/.osmosisd/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.osmosisd/config/config.toml
```

## Reset chain data
```
osmosisd tendermint unsafe-reset-all --home $HOME/.osmosisd
```

## Download and extract latest pruned snapshot
```
curl -o - -L https://snapshots1.polkachu.com/snapshots/osmosis/osmosis_6028617.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.osmosisd
```

## Create service
```
sudo tee /etc/systemd/system/osmosisd.service > /dev/null <<EOF
[Unit]
Description=osmosis
After=network-online.target

[Service]
User=$USER
ExecStart=$(which osmosisd) start --home $HOME/.osmosisd
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
sudo systemctl enable osmosisd
sudo systemctl restart osmosisd && sudo journalctl -u osmosisd -f -o cat
```
