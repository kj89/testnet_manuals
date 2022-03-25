# aptos node setup

> current block height can be found [here](https://status.devnet.aptos.dev)
> check the status of your node [here](https://www.nodex.run/aptos_test). On this site you can also create a wallet and test sending transactions.

## installation docker

Use script below for a quick installation:
```
wget -O aptos_docker.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_docker.sh && chmod +x aptos_docker.sh && ./aptos_docker.sh
```

## update aptos
```
systemctl stop aptos-fullnode
rm -rf /opt/aptos/data/*
cd aptos
wget -O genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -O waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
sed -i.bak -e "s/from_config: ".*"/from_config: "$(cat waypoint.txt)"/" public_full_node.yaml
```

## update seeds
```
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq
wget https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml seeds.yaml
```

## useful commands
### check aptos node logs
```
docker logs -f aptos-fullnode-1 --tail 100
```

### check sync status
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
```

### check private key
```
cat $HOME/aptos/identity/private-key.txt
```

### check public key
```
cat $HOME/aptos/identity/id.json
```

### restart service
```
docker restart aptos-fullnode-1
```

### backup keys
```
cp $HOME/aptos/identity/private-key.txt $HOME/aptos_backup/private-key.txt
cp $HOME/aptos/identity/id.json $HOME/aptos_backup/peer-info.yaml
```

### recover key from backup files
```
PRIVKEY=$(cat $HOME/aptos_backup/private-key.txt)
PEER=$(sed -n 2p $HOME/aptos_backup/peer-info.yaml | sed 's/.$//')
sed -i '/network_id: "public"$/a\
    identity:\
        type: "from_config"\
        key: "'$PRIVKEY'"\
        peer_id: "'$PEER'"' $HOME/aptos/public_full_node.yaml
docker restart aptos-fullnode-1
```

## installation binary

Installation can take more than 10 minutes, it is recommended to run in a screen session:
```
screen -S aptos
```

Use script below for a quick installation:
```
wget -O aptos.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos.sh && chmod +x aptos.sh && ./aptos.sh
```

## update aptos
```
systemctl stop aptosd
rm -rf /opt/aptos/data/*
wget -O /opt/aptos/data/genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -O ~/.aptos/waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
sed -i.bak -e "s/from_config: ".*"/from_config: "$(cat ~/.aptos/waypoint.txt)"/" $HOME/.aptos/config/public_full_node.yaml
systemctl restart aptosd
```

## update seeds
```
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq
wget https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/.aptos/config/public_full_node.yaml seeds.yaml
```

## useful commands
### check aptos node logs
```
journalctl -u aptosd -f -o cat
```

### check sync status
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
```

### check private key
```
cat $HOME/.aptos/key/private-key.txt
```

### check public key
```
cat $HOME/.aptos/config/peer-info.yaml
```

### restart service
```
systemctl restart aptosd
```

### recover key from backup files
```
PRIVKEY=$(cat $HOME/aptos_backup/private-key.txt)
PEER=$(sed -n 2p $HOME/aptos_backup/peer-info.yaml | sed 's/.$//')
sed -i '/network_id: "public"$/a\
    identity:\
        type: "from_config"\
        key: "'$PRIVKEY'"\
        peer_id: "'$PEER'"' $HOME/.aptos/config/public_full_node.yaml
sudo systemctl restart aptosd
```
