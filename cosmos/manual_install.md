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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/193048818-f9bc0c71-eeb8-40b2-95c1-a068ee47c116.png">
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
COSMOS_PORT=34
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export COSMOS_CHAIN_ID=cosmoshub-4" >> $HOME/.bash_profile
echo "export COSMOS_PORT=${COSMOS_PORT}" >> $HOME/.bash_profile
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
git clone https://github.com/cosmos/gaia.git
cd gaia
git checkout v7.0.0
make install
```

## Config app
```
gaiad config chain-id $COSMOS_CHAIN_ID
gaiad config keyring-backend test
gaiad config node tcp://localhost:${COSMOS_PORT}657
```

## Init app
```
gaiad init $NODENAME --chain-id $COSMOS_CHAIN_ID
```

## Download genesis and addrbook
```
wget -O genesis.cosmoshub-4.json.gz https://raw.githubusercontent.com/cosmos/mainnet/master/genesis/genesis.cosmoshub-4.json.gz
gzip -d genesis.cosmoshub-4.json.gz
mv genesis.cosmoshub-4.json ~/.gaia/config/genesis.json
```

## Set seeds and peers
```
SEEDS="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:14956"
PEERS="d22c2dcbc9acab44e807f78c798c9e47ea22e72b@95.217.228.124:14956,d5514fbd55cc97055341f1da252189ba62983c01@65.108.137.38:26656,dd274ecbfb77fa00b71b81665ebd8bc312370eab@65.21.188.183:26615,36a282f4d7b0542e4fa691b303c4636909779c4e@95.216.240.248:26656,df65b335f668b9feae5f8807ec899f96acd15d79@165.227.138.32:26656,aec26b2723dd70a0bbc7ca717ee358a4128e67b1@162.55.131.238:15603,d731ed6fd63a8fede820c4a853d2e70e1a06d701@142.132.155.174:26656,6b3cd4f36112a1ef566974fb31e2998d2bc480b9@65.109.17.57:26656,ab2c973c34603b0f4d5495a9429b7d80bcaecfde@54.247.128.194:26656,e0ab6c5cc86959853f499236b8297344802ac5f4@5.161.139.201:26656,61afb0f37c02031f285f6b27ead2a3e7a97cc28a@34.150.176.251:26656,a60ca46722fbe9cda7a401767a323633d5427227@3.15.30.80:26656,30d9cdef07cdb54e9ada05132688231831f3156b@3.144.211.227:26656,8c7cbbd0d769df38e85f5489b008326fafed6649@46.137.71.32:26656,c6f03336e99b15b104048a1af056063107389441@18.142.7.52:26656,1045cff0d1666f1bcc722551369e842cd6ac94f7@178.128.88.67:26656,2db4db5e13338bbc9fe2af1faca8540e409e24f1@65.108.105.155:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gaia/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${COSMOS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${COSMOS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${COSMOS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${COSMOS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${COSMOS_PORT}660\"%" $HOME/.gaia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${COSMOS_PORT}317\"%; s%^address = \":8080\"%address = \":${COSMOS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${COSMOS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${COSMOS_PORT}091\"%" $HOME/.gaia/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gaia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gaia/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uatom\"/" $HOME/.gaia/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.gaia/config/config.toml
```

## Reset chain data
```
gaiad tendermint unsafe-reset-all --home $HOME/.gaia
```

## Create service
```
sudo tee /etc/systemd/system/gaiad.service > /dev/null <<EOF
[Unit]
Description=gaia
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gaiad) start --home $HOME/.gaia
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
sudo systemctl enable gaiad
sudo systemctl restart gaiad && sudo journalctl -u gaiad -f -o cat
```
