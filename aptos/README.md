# APTOS FULLNODE SETUP GUIDE

> current block height can be found [here](https://status.devnet.aptos.dev)

> check the status of your node [here](https://www.nodex.run/aptos_test). On this site you can also create a wallet and test sending transactions.

> another node tester website with nice metric visualizer [here](http://node-tools.net/aptos/tester/)

## INSTALLATION USING DOCKER

Use script below for a quick installation:
```
wget -O aptos_docker.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_docker.sh && chmod +x aptos_docker.sh && ./aptos_docker.sh
```

### update aptos version
```
wget -O aptos_docker_update.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_docker_update.sh && chmod +x aptos_docker_update.sh && ./aptos_docker_update.sh
```

### update seeds
```
wget -O aptos_docker_seeds.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_docker_seeds.sh && chmod +x aptos_docker_seeds.sh && ./aptos_docker_seeds.sh
```

### get your node information:
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

### backup your identity files
In order to back up your keys please save identity files located in `$HOME/aptos/identity` to safe location

### recover your keys
Place your saved identity keys back into `$HOME/aptos/identity` and run script below
```
cd $HOME/aptos
docker compose down
docker volume rm aptos_db -f
PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
PEER_ID=$(cat $HOME/aptos/identity/id.json | jq -r '.. | .keys?  | select(.)[]')
yq e -i '.full_node_networks[0].identity.key="'$PRIVATE_KEY'"' $HOME/aptos/public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' $HOME/aptos/public_full_node.yaml
docker compose up -d
```

## INSTALLATION USING BINARIES

Installation can take more than 10 minutes, it is recommended to run in a screen session:
```
screen -S aptos
```

Use script below for a quick installation:
```
wget -O aptos.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos.sh && chmod +x aptos.sh && ./aptos.sh
```

### update aptos version
```
wget -O aptos_update.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_update.sh && chmod +x aptos_update.sh && ./aptos_update.sh
```

### update seeds
```
wget -O aptos_seeds.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_seeds.sh && chmod +x aptos_seeds.sh && ./aptos_seeds.sh
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
cp $HOME/.aptos/key/private-key.txt $HOME/aptos_backup/private-key.txt
cp $HOME/.aptos/config/peer-info.yaml $HOME/aptos_backup/id.json
```

### recover key from backup files
```
systemctl stop aptosd
rm -rf /opt/aptos/data/*
cp $HOME/aptos_backup/private-key.txt $HOME/.aptos/key/private-key.txt
cp $HOME/aptos_backup/id.json $HOME/.aptos/config/peer-info.yaml
PRIVATE_KEY=$(cat $HOME/.aptos/key/private-key.txt)
PEER_ID=$(cat $HOME/.aptos/config/peer-info.yaml | jq -r '.. | .keys?  | select(.)[]')
yq e -i '.full_node_networks[0].identity.key="'$PRIVATE_KEY'"' $HOME/.aptos/config/public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' $HOME/.aptos/config/public_full_node.yaml
systemctl start aptosd
```
