# umee node setup

## run script below to install your umee node
```
wget -O umee.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/umee/umee.sh && chmod +x umee.sh && ./umee.sh
```

### sync blocks using [stakeangle snapshot](https://stakeangle.com/state-sync/umee)
Stop existing service and reset db
```
sudo systemctl stop umeed
umeed unsafe-reset-all
```

Fill variables with data for State Sync
```
RPC="https://umee-rpc.stakeangle.com:443"
RECENT_HEIGHT=$(curl -s $RPC/block | jq -r .result.block.header.height)
TRUST_HEIGHT=$((RECENT_HEIGHT - 2000))
TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)
PEER="c12ac110e0249f0cef55599b335892444e4a21ac@142.132.198.227:26656"
```

Add variable values to config.toml
```
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC,$RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$TRUST_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.umee/config/config.toml
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEER\"/" $HOME/.umee/config/config.toml
```

Start service and open journal
```
sudo systemctl restart umeed
sudo journalctl -u umeed -f -o cat
```

### load variables
```
source $HOME/.bash_profile
```

### create wallet. don’t forget to save the mnemonic
```
umeed keys add $WALLET
```

### save wallet info
```
WALLET_ADDRESS=$(umeed keys show $WALLET -a)
VALOPER_ADDRESS=$(umeed keys show $WALLET --bech val -a)
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### create validator
```
umeed tx staking create-validator \
  --amount 9000000uumee \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.1" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey  $(umeed tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID \
  --gas 300000 \
  --fees 3uumee
```

## Usefull commands
To check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```

To view logs
```
journalctl -fu umeed -o cat
```

To stop
```
systemctl stop umeed
```

To start
```
systemctl start umeed
```

To restart
```
systemctl restart umeed
```

Bond more tokens (if you want increase your validator stake you should bond more to your valoper address):
```
umeed tx staking delegate $VALOPER_ADDRESS 10000000uumee --from $WALLET --chain-id $CHAIN_ID --fees 5000uumee
```

Restore wallet key
```
umeed keys add $WALLET --recover
```

Edit validator
```
umeed tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=WALLET$
```

## Run geth client
### Install geth
```
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.17-25c9b49f.tar.gz
tar -xvf geth-linux-amd64-1.10.17-25c9b49f.tar.gz
cp geth-linux-amd64-1.10.17-25c9b49f/geth /usr/bin
rm geth-linux-amd64-1.10.17-25c9b49f* -rf

sudo tee <<EOF >/dev/null /etc/systemd/system/geth.service
[Unit]
Description=Geth node
After=online.target

[Service]
Type=root
User=root
ExecStart=/usr/bin/geth --syncmode "light" --http
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start geth
```

### geth logs
```
journalctl -fu geth -o cat
```

### Create eth account
```
geth account new
```

### save wallet info
```
ETH_ADDRESS=$(geth attach ipc:/root/.ethereum/geth.ipc --exec web3.personal.listWallets[0].accounts[0].address | jq -r)
echo 'export ETH_ADDRESS='${ETH_ADDRESS} >> $HOME/.bash_profile
source ~/.bash_profile
```

### check eth node status
to check eth node synchronization status first of all you have to open geth
```
geth attach ipc:$HOME/.ethereum/geth.ipc
```

after that you can use commands below inside geth (eth.syncing should = false and net.peerCount have to be > than 0)
```
# node data directory with configs and keys
admin.datadir
# check if node is connected
net.listening
# show synchronization status
eth.syncing
# node status (difficulty should be equal to current block height)
admin.nodeInfo
# show synchronization percentage
eth.syncing.currentBlock * 100 / eth.syncing.highestBlock
# list of all connected peers (short list)
admin.peers.forEach(function(value){console.log(value.network.remoteAddress+"\t"+value.name)})
# list of all connected peers (long list)
admin.peers
# show connected peer count
net.peerCount
```

## Run peggo orchistrator
> Do not use the same address for the validator and orchestrator

### save orc address
```
ORC_WALLET="umee-orc"
echo 'export ORC_WALLET='${ORC_WALLET} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create seperate umee wallet for orchistratror
```
umeed keys add $ORC_WALLET
```

### save orchistrator wallet info
```
ORC_ADDRESS=$(umeed keys show $ORC_WALLET -a)
echo 'export ORC_ADDRESS='${ORC_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create alchemy account and get your ws link
1. go to https://www.alchemy.com/
2. create free account and get your ws endpoint. It will look like this `wss://eth-mainnet.alchemyapi.io/v2/UTvcOxxxxxxxxxxxxxxxxxxxxxxx`
3. save your ws url
```
ALCHEMY_WS="wss://eth-mainnet.alchemyapi.io/v2/UTvcOxxxxxxxxxxxxxxxxxxxxxxx"
echo 'export ALCHEMY_WS='${ALCHEMY_WS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Install peggo
```
PEGGO_VERSION=v0.2.6
wget https://github.com/umee-network/peggo/releases/download/$PEGGO_VERSION/peggo-$PEGGO_VERSION-linux-amd64.tar.gz
tar xvf peggo-$PEGGO_VERSION-linux-amd64.tar.gz
mv peggo-$PEGGO_VERSION-linux-amd64/peggo /usr/local/bin
rm peggo-$PEGGO_VERSION-linux-amd64* -rf
```

### Configrure peggo keys
> To send transaction below, your node must be synced with the `umee-1` network
```
umeed tx gravity set-orchestrator-address $VALOPER_ADDRESS $ORC_ADDRESS $ETH_ADDRESS --chain-id=$CHAIN_ID --from=$WALLET
```

### Update configuration variables for peggo
```
PEGGO_ETH_PK="ETHEREUM_ADDRESS_PRIVATE_KEY"
ETH_RPC="http://localhost:8545"
BRIDGE_ADDR="0xb564ac229e9d6040a9f1298b7211b9e79ee05a2c"
START_HEIGHT="14211966"
ORCHESTRATOR_WALLET_NAME=$ORC_WALLET
ORCHESTRATOR_WALLET_PASSWORD="ORCHESTRATOR_ADDRESS_WALLET_PASSWORD"
ALCHEMY_ENDPOINT=$ALCHEMY_WS
```

### move all configruation to profile file
```
echo 'export PEGGO_ETH_PK='${PEGGO_ETH_PK} >> $HOME/.bash_profile
echo 'export ETH_RPC='${ETH_RPC} >> $HOME/.bash_profile
echo 'export BRIDGE_ADDR='${BRIDGE_ADDR} >> $HOME/.bash_profile
echo 'export START_HEIGHT='${START_HEIGHT} >> $HOME/.bash_profile
echo 'export ORCHESTRATOR_WALLET_NAME='${ORCHESTRATOR_WALLET_NAME} >> $HOME/.bash_profile
echo 'export ORCHESTRATOR_WALLET_PASSWORD='${ORCHESTRATOR_WALLET_PASSWORD} >> $HOME/.bash_profile
echo 'export ALCHEMY_ENDPOINT='${ALCHEMY_ENDPOINT} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create peggo service
```
sudo tee <<EOF >/dev/null /etc/systemd/system/peggod.service
[Unit]
Description=Peggo Service
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/peggo orchestrator $BRIDGE_ADDR \
  --bridge-start-height="$START_HEIGHT" \
  --eth-rpc="$ETH_RPC" \
  --relay-batches=true \
  --valset-relay-mode=none \
  --cosmos-chain-id=$CHAIN_ID \
  --cosmos-keyring-dir="$HOME/.umee" \
  --cosmos-from="$ORCHESTRATOR_WALLET_NAME" \
  --cosmos-from-passphrase="$ORCHESTRATOR_WALLET_PASSWORD" \
  --eth-alchemy-ws="$ALCHEMY_ENDPOINT" \
  --cosmos-keyring="os" \
  --log-level debug \
  --log-format text
Environment="PEGGO_ETH_PK=$PEGGO_ETH_PK"
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### run peggod service
```
sudo systemctl daemon-reload
sudo systemctl enable peggod
sudo systemctl restart peggod
```

### check logs
```
journalctl -u peggod -f -o cat
```

