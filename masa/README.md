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

_Press CTRL+D to exit_

### backup node key
please backup masa node key
```
cat $HOME/masa-node-v1.0/data/geth/nodekey
```

### restore node key
to restore masa node key just insert it into _$HOME/masa-node-v1.0/data/geth/nodekey_ and restart service afterwards
