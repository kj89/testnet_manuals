<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/EY35ZzXY" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
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
echo "export KUJIRA_CHAIN_ID=kaiyo-1" >> $HOME/.bash_profile
echo "export KUJIRA_PORT=${KUJIRA_PORT}" >> $HOME/.bash_profile
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
git clone https://github.com/Team-Kujira/core.git --branch v0.4.1
cd core
make install
```

## Config app
```
kujirad config chain-id $KUJIRA_CHAIN_ID
kujirad config keyring-backend file
kujirad config node tcp://localhost:${KUJIRA_PORT}657
```

## Init app
```
kujirad init $NODENAME --chain-id $KUJIRA_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.kujira/config/genesis.json "https://raw.githubusercontent.com/Team-Kujira/networks/master/mainnet/kaiyo-1.json"
```

## Set seeds and peers
```
SEEDS="5a70fdcf1f51bb38920f655597ce5fc90b8b88b8@136.244.29.116:41656"
PEERS="9813378d0dceb86e57018bfdfbade9d863f6f3c8@3.38.73.119:26656,ccffabe81f2de8a81e171f93fe1209392bf9993f@65.108.234.59:26656,7878121e8fa201c836c8c0a95b6a9c7ac6e5b101@141.95.151.171:26656,0743497e30049ac8d59fee5b2ab3a49c3824b95c@198.244.200.196:26656,2efead362f0fc7b7fce0a64d05b56c5b28d5c2b4@164.92.209.72:36347,d24ee4b38c1ead082a7bcf8006617b640d3f5ab9@91.196.166.13:26656,5d0f0bc1c2d60f1d273165c5c8cefc3965c3d3c9@65.108.233.175:26656,5a70fdcf1f51bb38920f655597ce5fc90b8b88b8@136.244.29.116:41656,35af92154fdb2ac19f3f010c26cca9e5c175d054@65.108.238.61:27656,e65c2e27ea06b795a25f3ce813ed2062371705b8@213.239.212.121:13657,f6d0d3ac0c748a343368705c37cf51140a95929b@146.59.81.204:36657"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.kujira/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${KUJIRA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${KUJIRA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${KUJIRA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${KUJIRA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${KUJIRA_PORT}660\"%" $HOME/.kujira/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${KUJIRA_PORT}317\"%; s%^address = \":8080\"%address = \":${KUJIRA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${KUJIRA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${KUJIRA_PORT}091\"%" $HOME/.kujira/config/app.toml
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
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00125ukuji,0.00125ibc/295548A78785A1007F232DE286149A6FF512F180AF5657780FC89C009E2C348F,0.00125ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2,0.000125ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23,0.00125ibc/EFF323CC632EC4F747C61BCE238A758EFDB7699C3226565F7C20DA06509D59A5\"/" $HOME/.kujira/config/app.toml
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
