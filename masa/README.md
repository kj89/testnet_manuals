# masa node setup

## run script bellow to prepare your node
```
wget -O masa.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/masa/masa.sh && chmod +x masa.sh && ./masa.sh
```

## usefull commands
### attach to geth
```
geth attach ipc:$HOME/masa-node-v1.0/data/geth.ipc
```

commands inside geth
```
eth.syncing
eth.syncing.currentBlock * 100 / eth.syncing.highestBlock
net.peerCount
```

_Press CTRL+D to exit_
