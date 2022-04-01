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
cd $HOME/aptos
docker compose down
wget -O genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -O waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
docker volume rm aptos_db -f
docker compose up -d
```

## update seeds
```
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq
wget -O seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml seeds.yaml
docker restart aptos-fullnode-1
```

Get your node information:
```
wget -O aptos_identity.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_identity.sh && chmod +x aptos_identity.sh && ./aptos_identity.sh
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
mkdir $HOME/aptos_backup
cp $HOME/aptos/identity/private-key.txt $HOME/aptos_backup/private-key.txt
cp $HOME/aptos/identity/id.json $HOME/aptos_backup/id.json
```

### recover key from backup files
```
cd $HOME/aptos
docker compose down
docker volume rm aptos_db -f
cp $HOME/aptos_backup/* $HOME/aptos/identity/
PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
PEER_ID=$(cat $HOME/aptos/identity/id.json | jq -r '.. | .keys?  | select(.)[]')
yq e -i '.full_node_networks[0].identity.key="'$PRIVATE_KEY'"' $HOME/aptos/public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' $HOME/aptos/public_full_node.yaml
docker compose up -d
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
wget -O seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/.aptos/config/public_full_node.yaml seeds.yaml
systemctl restart aptosd
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

### backup keys
```
mkdir $HOME/aptos_backup
cp ~/.aptos/key/private-key.txt $HOME/aptos_backup/private-key.txt
cp ~/.aptos/config/peer-info.yaml $HOME/aptos_backup/id.json
```

### recover key from backup files
```
systemctl stop aptosd
rm -rf /opt/aptos/data/*
PRIVATE_KEY=$(cat $HOME/aptos_backup/private-key.txt)
PEER_ID=$(cat $HOME/aptos_backup/id.json | jq -r '.. | .keys?  | select(.)[]')
yq e -i '.full_node_networks[0].identity.key="'$PRIVATE_KEY'"' $HOME/aptos/public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' $HOME/aptos/public_full_node.yaml
systemctl start aptosd
```
