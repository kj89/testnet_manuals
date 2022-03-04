## Sentry setup

### Run script bellow to prepare your node
```
wget -O masa.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/masa/masa.sh && chmod +x masa.sh && ./masa.sh
```

### status ETH node
geth attach ipc:$HOME/masa-node-v1.0/data/geth.ipc

```
eth.syncing
eth.syncing.currentBlock * 100 / eth.syncing.highestBlock
net.peerCount
```

_CTRL+D to exit_
