<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/fRVzvPBh" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>
<p style="font-size:14px" align="right">
<a href="https://m.do.co/c/17b61545ca3a" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus for 60 days <img src="https://user-images.githubusercontent.com/50621007/183284313-adf81164-6db4-4284-9ea0-bcb841936350.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/179568169-a81fb8a8-12d2-4865-aa91-3dba7649d54e.png">
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
TERITORI_PORT=19
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export TERITORI_CHAIN_ID=teritori-testnet-v2" >> $HOME/.bash_profile
echo "export TERITORI_PORT=${TERITORI_PORT}" >> $HOME/.bash_profile
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
git clone https://github.com/TERITORI/teritori-chain
cd teritori-chain
git checkout teritori-testnet-v2
make install
```

## Config app
```
teritorid config chain-id $TERITORI_CHAIN_ID
teritorid config keyring-backend test
teritorid config node tcp://localhost:${TERITORI_PORT}657
```

## Init app
```
teritorid init $NODENAME --chain-id $TERITORI_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.teritorid/config/genesis.json "https://raw.githubusercontent.com/TERITORI/teritori-chain/main/testnet/teritori-testnet-v2/genesis.json"
wget -qO $HOME/.teritorid/config/addrbook.json "https://raw.githubusercontent.com/StakeTake/guidecosmos/main/teritori/teritori-testnet-v2/addrbook.json"
```

## Set seeds and peers
```
SEEDS=""
PEERS="96b55467792a143e0169684f0e8da9a9aeb97af4@23.88.77.188:28656,4eb8b8bed6aecc52dccf21fd1e9432e071659db2@38.242.154.39:36656,986cdc276eea5fcb205ea3c66503c0610f99895d@95.216.140.117:26656,545b1fe982b92aeb9f1eadd05ab0954b38eba402@194.163.177.240:26656,0d19829b0dd1fc324cfde1f7bc15860c896b7ac1@65.108.121.240:27656,34df38933c32ee21078c1d79787d76668f398b9e@89.163.231.30:36656,0248e2989a8a4f6ad87cbe0490c08908a2c2da7f@5.199.133.165:26656,691efb2bee7b585c1f434d934abf18428d0b8ff1@161.97.91.254:26656,cd363d841f4dab90f290aab21c97f8d80a93a028@38.242.154.35:36656,a1c845585abbd8490ecbbcc7f96ff3b027cbed88@38.242.154.40:36656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.teritorid/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${TERITORI_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${TERITORI_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${TERITORI_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${TERITORI_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${TERITORI_PORT}660\"%" $HOME/.teritorid/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${TERITORI_PORT}317\"%; s%^address = \":8080\"%address = \":${TERITORI_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${TERITORI_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${TERITORI_PORT}091\"%" $HOME/.teritorid/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.teritorid/config/app.toml
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utori\"/" $HOME/.teritorid/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.teritorid/config/config.toml
```

## Reset chain data
```
teritorid tendermint unsafe-reset-all --home $HOME/.teritorid
```

## Create service
```
sudo tee /etc/systemd/system/teritorid.service > /dev/null <<EOF
[Unit]
Description=teritori
After=network-online.target

[Service]
User=$USER
ExecStart=$(which teritorid) start --home $HOME/.teritorid
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
sudo systemctl enable teritorid
sudo systemctl restart teritorid && sudo journalctl -u teritorid -f -o cat
```
