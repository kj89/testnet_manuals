# aptos node setup

## run script below to install your aptos node
```
wget -O aptos_devnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_devnet.sh && chmod +x aptos_devnet.sh && ./aptos_devnet.sh
```

## update seeds
```
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq
wget https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml seeds.yaml
```

## check node status

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
