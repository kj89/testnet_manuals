<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/170463282-576375f8-fa1e-4fce-8350-6312b415b50d.png">
</p>

# Install Validator node
To setup validator node follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=mamaki" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y
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
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app
APP_VERSION=$(curl -s https://api.github.com/repos/celestiaorg/celestia-app/releases/latest | jq -r ".tag_name")
git checkout tags/$APP_VERSION -b $APP_VERSION
make install
```

## Download network tools
```
cd $HOME
rm -rf networks
git clone https://github.com/celestiaorg/networks.git
```

## Config app
```
celestia-appd config chain-id $CHAIN_ID
celestia-appd config keyring-backend test
```

## Init app
```
celestia-appd init $NODENAME --chain-id $CHAIN_ID
```

## Update genesis
```
cp $HOME/networks/$CHAIN_ID/genesis.json $HOME/.celestia-app/config
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utia\"/" $HOME/.celestia-app/config/app.toml
```

## Use custom settings
```
use_legacy="false"
pex="true"
max_connections="90"
peer_gossip_sleep_duration="2ms"
sed -i.bak -e "s/^use-legacy *=.*/use-legacy = \"$use_legacy\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^pex *=.*/pex = \"$pex\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^max-connections *=.*/max-connections = \"$max_connections\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^peer-gossip-sleep-duration *=.*/peer-gossip-sleep-duration = \"$peer_gossip_sleep_duration\"/" $HOME/.celestia-app/config/config.toml
```

## Set seeds, peers and boot nodes
```
BOOTSTRAP_PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/bootstrap-peers.txt | tr -d '\n')
MY_PEER=$(celestia-appd tendermint show-node-id)@$(curl -s ifconfig.me)$(grep -A 9 "\[p2p\]" ~/.celestia-app/config/config.toml | egrep -o ":[0-9]+")
PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mamaki/peers.txt | tr -d '\n' | head -c -1 | sed s/"$MY_PEER"// | sed "s/,,/,/g")
sed -i.bak -e "s/^bootstrap-peers *=.*/bootstrap-peers = \"$BOOTSTRAP_PEERS\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^persistent-peers *=.*/persistent-peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.celestia-app/config/config.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="5000"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.celestia-app/config/app.toml
```

## Set timeouts
```
sed -i.bak -e "s/^timeout-commit *=.*/timeout-commit = \"25s\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^timeout-propose *=.*/timeout-propose = \"3s\"/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^skip-timeout-commit *=.*/skip-timeout-commit = false/" $HOME/.celestia-app/config/config.toml
```

## Increse peer connections
```
sed -i.bak -e "s/^max-connections *=.*/max-connections = 150/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^max-num-inbound-peers *=.*/max-num-inbound-peers = 100/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^max-num-outbound-peers *=.*/max-num-outbound-peers = 50/" $HOME/.celestia-app/config/config.toml
sed -i.bak -e "s/^max-incoming-connection-attempts *=.*/max-incoming-connection-attempts = 20/" $HOME/.celestia-app/config/config.toml
```

## Set validator mode
```
sed -i.bak -e "s/^mode *=.*/mode = \"validator\"/" $HOME/.celestia-app/config/config.toml
```

## (OPTIONAL) Use Quick Sync by restoring data from snapshot
```
cd $HOME
rm -rf ~/.celestia-app/data
mkdir -p ~/.celestia-app/data
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | egrep -o ">mamaki.*tar" | tr -d ">")
wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - -C ~/.celestia-app/data/
```

## Create service
```
tee /etc/systemd/system/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=celestia-appd
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which celestia-appd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl restart celestia-appd
```

# Install Bridge node
To setup bridge node follow the steps below

## Install Celestia Node
```
cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node
make install
```

## Initialize bridge node
```
celestia bridge init --core.remote tcp://localhost:26657 --core.grpc tcp://localhost:9090
```

## Create bridge service
```
tee /etc/systemd/system/celestia-bridge.service > /dev/null <<EOF
[Unit]
Description=celestia-bridge Cosmos daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$HOME/go/bin/celestia bridge start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Register and start bridge service
```
sudo systemctl daemon-reload
sudo systemctl enable celestia-bridge
sudo systemctl restart celestia-bridge
```
