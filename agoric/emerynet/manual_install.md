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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/167032367-fee4380e-7678-43e0-9206-36d72b32b8ae.png">
</p>

# Manual node setup
If you want to setup fullnode manually follow the steps below

## Save network configuration to file
```
curl https://emerynet.agoric.net/network-config > $HOME/chain.json
```

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

## Save and import variables into system
```
AGORIC_PORT=27
if [ ! $NODENAME ]; then
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export AGORIC_CHAIN_ID=$(jq -r .chainName < $HOME/chain.json)" >> $HOME/.bash_profile
echo "export AGORIC_PORT=${AGORIC_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Install node.js
```
if ! [ -x "$(command -v node)" ]; then
curl https://deb.nodesource.com/setup_14.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt upgrade -y
sudo apt install nodejs=14.* yarn build-essential jq -y
sleep 1
fi
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

## Download binary
```
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-upgrade-7
make build
. $HOME/.bash_profile
sudo cp $HOME/ag0/build/ag0 /usr/local/bin
```

## Config app
```
ag0 config chain-id $AGORIC_CHAIN_ID
ag0 config keyring-backend test
ag0 config node tcp://localhost:${AGORIC_PORT}657
```

## Init app
```
ag0 init $NODENAME --chain-id $AGORIC_CHAIN_ID
```

## Download genesis file
```
curl https://emerynet.rpc.agoric.net/genesis | jq .result.genesis > $HOME/.agoric/config/genesis.json 
```

## Set seeds and peers
```
PEERS=$(jq '.peers | join(",")' < $HOME/chain.json)
SEEDS=$(jq '.seeds | join(",")' < $HOME/chain.json)
sed -i -e "s/^seeds *=.*/seeds = $SEEDS/; s/^persistent_peers *=.*/persistent_peers = $PEERS/" $HOME/.agoric/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${AGORIC_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${AGORIC_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${AGORIC_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${AGORIC_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${AGORIC_PORT}660\"%" $HOME/.agoric/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${AGORIC_PORT}317\"%; s%^address = \":8080\"%address = \":${AGORIC_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${AGORIC_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${AGORIC_PORT}091\"%" $HOME/.agoric/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.agoric/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.agoric/config/config.toml
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025ubld\"/" $HOME/.agoric/config/app.toml
```

## Reset chain data
```
ag0 tendermint unsafe-reset-all --home $HOME/.agoric
```

## Create service
```
sudo tee /etc/systemd/system/agoricd.service > /dev/null <<EOF
[Unit]
Description=agoric
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ag0) start --home $HOME/.agoric
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
sudo systemctl enable agoricd
sudo systemctl restart agoricd
```