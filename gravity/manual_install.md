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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/184189788-a617676f-fae9-43b4-89d3-e3ab779946f7.png">
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
GRAVITY_PORT=26
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export GRAVITY_CHAIN_ID=gravity-bridge-3" >> $HOME/.bash_profile
echo "export GRAVITY_PORT=${GRAVITY_PORT}" >> $HOME/.bash_profile
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
mkdir gravity-bin && cd gravity-bin
wget -O gravityd https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.7.1/gravity-linux-amd64
wget -O gbt https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.7.1/gbt
chmod +x *
sudo mv * /usr/bin/
```

## Init app
```
gravityd init $NODENAME --chain-id $GRAVITY_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.gravity/config/genesis.json "https://raw.githubusercontent.com/Gravity-Bridge/gravity-docs/main/genesis.json"
```

## Set seeds and peers
```
SEEDS="6770e29a9224810bcde6655b742d52b8a49d51e8@65.19.136.133:26656,63e662f5e048d4902c7c7126291cf1fc17687e3c@95.211.103.175:26656"
PEERS="83e31a6af014ab5107bd847a59219ba8513c8d67@3.140.57.39:26656,23ca1bc09f400de6329db5dac5b35709dd3f0f93@65.108.72.104:36656,872d4a6598e03c578004b3e7b1ac9a5c28cf910c@51.154.19.13:26656,2b3d7fc3bf7a851b0473789550230bb8a99ac1d5@167.172.242.131:26656,57237c45adfc4dac06627107821cddb0d8f59ba3@23.88.73.114:36656,cb6ae22e1e89d029c55f2cb400b0caa19cbe5523@35.183.246.163:26603,c9981e3382850e8a09f10b5cc54b8dccd854e49a@152.32.133.115:26656,774406f9e2c9c65e084effc8d823c470b82de6d0@146.19.24.186:26656,b59a7d3575bd7873d111e33c54a85261a6560d6b@176.191.97.120:26656,f8e90b224c2f3a914f18313adb8718a9a366f6fe@65.108.140.109:26656,46f81e6009cea0a7adf68a10f2403a93fa38cd21@65.109.30.60:26656,b1345e033dc4db2f8dc55428346402a626cc9852@194.163.191.91:26656,227f29d6b819fc6d0463c2f35042c6d84b705805@97.126.21.247:26656,cc01880390b84a5ad31c9fa471748eb5a7565ee4@35.243.229.224:26656,24999897a82338f63b8e3c36ec7ec63ce32b11c1@165.232.151.62:26656,572d417e11368f588d110efdeb7102a6a3c0752d@161.35.224.108:26656,f49e5a6d0759694e314c8b627811a6f4ce818a3d@178.250.211.21:26656,67465fbef972f60c33c0051a3a31fdbde0937387@65.108.71.119:46656,ff63e904c75b1136167b8fe2729d6fabf063501b@135.181.5.219:42656,89584fecf2df7623b0d20ea0a10e59e5addbd126@94.23.23.189:30505,1c2661b9aa125a31f8618f224faf553e85f230a6@65.131.83.89:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gravity/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${GRAVITY_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${GRAVITY_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${GRAVITY_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${GRAVITY_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${GRAVITY_PORT}660\"%" $HOME/.gravity/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${GRAVITY_PORT}317\"%; s%^address = \":8080\"%address = \":${GRAVITY_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${GRAVITY_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${GRAVITY_PORT}091\"%" $HOME/.gravity/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gravity/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gravity/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gravity/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gravity/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ugraviton\"/" $HOME/.gravity/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.gravity/config/config.toml
```

## State sync
```
SNAP_RPC="https://gravity-rpc.polkachu.com:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.gravity/config/config.toml
```

## Reset chain data
```
gravityd tendermint unsafe-reset-all --home $HOME/.gravity
```

## Create service
```
sudo tee /etc/systemd/system/gravityd.service > /dev/null <<EOF
[Unit]
Description=gravity
After=network-online.target

[Service]
User=$USER
ExecStart=$(which gravityd) start --home $HOME/.gravity
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
sudo systemctl enable gravityd
sudo systemctl restart gravityd && sudo journalctl -u gravityd -f -o cat
```
