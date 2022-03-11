# masa node setup

## run script below to install your masa node
```
wget -O masa.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/masa/masa.sh && chmod +x masa.sh && ./masa.sh
```

## check node status

### check masa node logs
you have to see blocks comming
```
journalctl -u masad -f | grep "new block"
```

### check eth node status
to check eth node synchronization status first of all you have to open geth
```
geth attach ipc:$HOME/masa-node-v1.0/data/geth.ipc
```

after that you can use commands below inside geth (eth.syncing should = false and net.peerCount have to be > than 0)
```
# show synchronization status
eth.syncing
# show synchronization percentage
eth.syncing.currentBlock * 100 / eth.syncing.highestBlock
# show connected peer count
net.peerCount
```

_Press CTRL+D to exit_
