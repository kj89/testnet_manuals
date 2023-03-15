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
echo "export JACKAL_CHAIN_ID=jackal-1" >> $HOME/.bash_profile
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
  echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
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
wget -qO $HOME/.canine/config/genesis.json "https://cdn.discordapp.com/attachments/1002389406650466405/1034968352591986859/updated_genesis2.json"
```

## Set seeds and peers
```
SEEDS="ec38fb158ffb0272c4b7c951fc790a8f9849e280@198.244.212.27:26656"
PEERS="c98028a169aabe5f8555090e6cd3370308b391b3@135.181.20.44:2506,ec38fb158ffb0272c4b7c951fc790a8f9849e280@198.244.212.27:26656,ff94a29e02de8369faf37c76d3c97684bbd51bd6@185.16.38.165:17556,39b55b1c49ad0994bbead006be40d9c84b0bf2d4@78.107.253.133:28656,f90a64a0a3f3c0480360e0fe5dd0f806d7741558@207.244.127.5:26656,57d82676ab660e8e4471664d7fee18e3e2e3dd19@89.58.38.59:26656,8be44995ab4eeafcde6e0a9e196c40d483ef6d2a@51.81.155.97:10556"
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
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.002ujkl\"/" $HOME/.canine/config/app.toml
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
