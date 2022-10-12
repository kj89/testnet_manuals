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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/194469665-36158a7f-b85b-4048-baa4-87199508d3f0.png">
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
NOIS_PORT=30
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export NOIS_CHAIN_ID=nois-testnet-003" >> $HOME/.bash_profile
echo "export NOIS_PORT=${NOIS_PORT}" >> $HOME/.bash_profile
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
git clone https://github.com/noislabs/full-node.git 
cd full-node/full-node/
./build.sh
mv out/noisd $HOME/go/bin/
```

## Config app
```
noisd config chain-id $NOIS_CHAIN_ID
noisd config keyring-backend test
noisd config node tcp://localhost:${NOIS_PORT}657
```

## Init app
```
noisd init $NODENAME --chain-id $NOIS_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.noisd/config/genesis.json "https://raw.githubusercontent.com/noislabs/testnets/main/nois-testnet-003/genesis.json"
```

## Set seeds and peers
```
SEEDS=""
PEERS="bf5bbdf9ac1ccd72d7b29c3fbcc7e99ff89fd053@node-0.noislabs.com:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.noisd/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NOIS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NOIS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NOIS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NOIS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NOIS_PORT}660\"%" $HOME/.noisd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NOIS_PORT}317\"%; s%^address = \":8080\"%address = \":${NOIS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NOIS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NOIS_PORT}091\"%" $HOME/.noisd/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.noisd/config/app.toml
```

## Set minimum gas price and timeout commit
```
export DENOM=unois
export CONFIG_DIR=$HOME/.noisd/config
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.05'"${DENOM}"'"/' $CONFIG_DIR/app.toml \
  && sed -i 's/^timeout_propose =.*$/timeout_propose = "2s"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_propose_delta =.*$/timeout_propose_delta = "500ms"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_prevote =.*$/timeout_prevote = "1s"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_prevote_delta =.*$/timeout_prevote_delta = "500ms"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_precommit =.*$/timeout_precommit = "1s"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_precommit_delta =.*$/timeout_precommit_delta = "500ms"/' $CONFIG_DIR/config.toml \
  && sed -i 's/^timeout_commit =.*$/timeout_commit = "2s"/' $CONFIG_DIR/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.noisd/config/config.toml
```

## Reset chain data
```
noisd tendermint unsafe-reset-all --home $HOME/.noisd
```

## Create service
```
sudo tee /etc/systemd/system/noisd.service > /dev/null <<EOF
[Unit]
Description=nois
After=network-online.target

[Service]
User=$USER
ExecStart=$(which noisd) start --home $HOME/.noisd
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
sudo systemctl enable noisd
sudo systemctl restart noisd && sudo journalctl -u noisd -f -o cat
```
