<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
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
echo "export DEWEB_CHAIN_ID=deweb-testnet-1" >> $HOME/.bash_profile
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
git clone https://github.com/deweb-services/deweb.git
cd deweb
git checkout v0.2
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
wget -qO $HOME/.deweb/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/dws/addrbook.json"
```

## Set seeds and peers
```
SEEDS="74d8f92c37ffe4c6393b3718ca531da8f0bf0594@seed1.deweb.services:26656"
PEERS="89cece970bf29d9568aaf9ebe2646f715d0c18e0@38.242.223.192:26656,91e5db474860efd2fc5ada50717f490beb415631@34.135.218.29:26656,16a0e5a87ae4e1ecfeb48ec47b88131a86fdbdd3@95.216.101.84:23626,4172ea44cb18d7b8040c3c284d76340e9212fea7@95.214.53.225:26666,a7f27acdfefb195fb98b9968c12eec0fe7b238a5@65.108.11.6:56656,f4e513ec6bec17118fdda12cd194b07161efacc7@161.97.162.196:26656,99cade3d4cfdfb92ca20d304bd382e730f5837d1@195.3.223.11:26686,852fa40eae1abc786c51ca193e71d98b011e433e@161.97.155.94:29656,a74cf609251f198e884f02f404272514bb90c3b3@65.21.226.230:24656,314b4151773dca448a42200c6fa3996d93363dec@149.102.129.61:26656,fc3e3aa913142ad90dd981ab116de67b37b19d43@185.218.126.98:26656,26ee666d3e0076f20ed0f13cceeb39edcd91c87f@65.108.79.246:26667,315ac6f2a79d6d81df645982ab88418455880a90@38.242.247.74:26656,ce0606615a0708c71670ed7bb4bef9ccb6dcbc06@65.108.7.44:24656,aa9d11e65650928e26e794eb0ec3756bfa3b6e0d@45.85.147.13:26656,df2d08898fe65613614a615868244ffce0fcd08c@65.21.237.194:26651,107fcf1fe281ec5764927a63d8bb8d83ece2d0b9@135.181.73.170:26357,05fb7de2b6f963c8dede45fdd735682cc8453e0b@161.97.148.146:26656,0cb4f3485af08ca48990cfa5e0391a83817c1a66@135.181.31.230:26656,ae72548f31f409a92fc00e5b62b513f8261ea7ec@144.91.118.61:26656,b0ab69382b3a36b412ea0652f06bff2e95f9867b@116.203.101.248:26656,70b86766e36ef6daf670aa544f1033b0963ec720@144.91.102.79:26656,cd7b15b41b93453ee64badf89067a569fa2feff6@5.161.106.236:26656,986c2116fac2d9442190a7755b29793663da530d@65.108.199.79:26656,21d0278c12d7c12f76074eae813dcf90c986611f@94.130.79.95:26656,8afcc458fbd75c23aa9b011eccc8757910b576ec@70.34.213.142:26656,b6549b4910165cfa9ab3b4b0a380753ef415b2c9@94.130.26.96:26656,a0a23f8661720006fe181ddf98740dbe4322d5f0@65.108.75.237:2020,143b2cfba7f5f3ba38263aafc9d2fa4521ba89d9@65.109.11.243:26656,3b13b93488812f8701b0f34f19c01e859aaa5b87@172.104.136.254:26656,09b08a1fa936033acfb94d708f7fc677b5f19b58@159.65.136.242:26656,b417857edd001b1c1ca94f1a03e8d53e0b16aed5@116.203.107.228:26656,29f3fc504631f84ea71ce5a2969c370436a443e8@194.163.151.154:26656,d4ea6c4a7a4ede65d37b3ef5868b821fcf53732e@167.86.87.75:26656,a0acd6daf4f6044468fea2eca6300be8601d7f18@194.163.141.24:16656,47db2ec2cfbab72ed6a17151c3a54d28a5629e62@138.201.139.175:46656,42558363e2e153b8ad9c618d2e5335d03ff09a60@167.86.95.179:26656,4171a8155ee8e3390dc2b9f07fa9f4b991571e9d@148.251.53.155:26656,74c4fc0e9a0c34d87f5a9ef4b38fe5d441e9e559@173.249.50.126:26656,2c96f953c3af767c6da8d992a085040bbf60cc37@194.163.141.20:16656,4da16f1fe1f52e059bb11e394457f3364c1150f1@185.209.229.115:26656,31934c5277584b2a2e31a7456b23919289a50743@167.86.87.124:26656,6449a2d68fcc581313e751bba693689fb7ef1ea6@95.216.200.33:26656,3e9965c8efd48e672ffe8eeab0d774f9008fad0c@109.107.190.107:26656,f974262da91afa321b38ffebb3531a67ed3a57d5@154.53.52.32:26656,4874e9b858f04ca3370469b4f1513cb3aac49a2b@38.242.220.130:26656,9440fa39f85bea005514f0191d4550a1c9d310bb@135.181.133.37:27656,9d74ffd5649287276fa7265c73ecd8cbc2af75dc@65.108.130.189:26646"
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
dewebd unsafe-reset-all
```

## Create service
```
sudo tee /etc/systemd/system/dewebd.service > /dev/null <<EOF
[Unit]
Description=deweb
After=network-online.target

[Service]
User=$USER
ExecStart=$(which dewebd) start
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
