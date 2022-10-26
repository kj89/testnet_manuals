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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/198128163-97607b9a-32cf-45c3-b4bc-73f9ba4471bc.png">
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
JACKAL_PORT=37
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export JACKAL_CHAIN_ID=canine-1" >> $HOME/.bash_profile
echo "export JACKAL_PORT=${JACKAL_PORT}" >> $HOME/.bash_profile
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
git clone https://github.com/JackalLabs/canine-chain.git
cd canine-chain
git checkout v1.1.1
make install
```

## Config app
```
canined config chain-id $JACKAL_CHAIN_ID
canined config keyring-backend test
canined config node tcp://localhost:${JACKAL_PORT}657
```

## Init app
```
canined init $NODENAME --chain-id $JACKAL_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.canine/config/genesis.json "https://raw.githubusercontent.com/JackalLabs/woof/master/genesis/woof-final.json"
```

## Set seeds and peers
```
SEEDS="052c498dd1cc603b4d32f772035b6a8ca902def3@23.88.73.211:26656,0bdeaaa237b41e3b964a027a110c6ab5bf561177@209.34.206.38:26656,bf7ee27a24e7d5f45653206fbbda8c4b716b74b1@89.58.38.59:26656,9eecc498dd2542c862f5bfb84ed7d2e1e3d922ab@34.201.48.14:26656,bf62b185eef3c185f8ebf81d5cf54bdc064b21d8@85.10.216.157:26656,43e800018a5b52ba119a5410ff45cbeb63182cc8@207.244.127.5:26656,942087a9665e8235f8037d0b9d2a3f8a8c3d562b@104.207.138.181:26656,9d0094606fe8748f1c06b494f7c0cbbd44808ec6@131.153.59.6:26656,6071fe2fc7e4f49caa4b1fd1cfe19007152312e0@34.76.87.33:26656,3f58d7c35ad55ef6cea94f7aa2ffe79df1c01768@78.107.253.133:26656,46cb18ca32ad7329cb82a10316087794ef12150f@185.107.57.74:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.canine/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${JACKAL_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${JACKAL_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${JACKAL_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${JACKAL_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${JACKAL_PORT}660\"%" $HOME/.canine/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${JACKAL_PORT}317\"%; s%^address = \":8080\"%address = \":${JACKAL_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${JACKAL_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${JACKAL_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${JACKAL_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${JACKAL_PORT}546\"%" $HOME/.canine/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.canine/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.canine/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.canine/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.canine/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ujkl\"/" $HOME/.canine/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.canine/config/config.toml
```

## Reset chain data
```
canined tendermint unsafe-reset-all --home $HOME/.canine
```

## Create service
```
sudo tee /etc/systemd/system/canined.service > /dev/null <<EOF
[Unit]
Description=canine
After=network-online.target

[Service]
User=$USER
ExecStart=$(which canined) start --home $HOME/.canine
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
sudo systemctl enable canined
sudo systemctl restart canined && sudo journalctl -u canined -f -o cat
```
