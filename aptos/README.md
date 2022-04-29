<p align="center">
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/165930080-4f541b46-1ae3-461c-acc9-de72d7ab93b7.png">
</p>

# Aptos fullnode setup for Testnet
Official documentation:
> [Run a full node](https://aptos.dev/tutorials/run-a-fullnode)

Usefull tools:
> [Aptos Network Dashboard](https://status.devnet.aptos.dev/)\
> [Aptos Node Informer](http://node-tools.net/aptos/tester/)

## Set up your aptos fullnode
### Option 1 (automatic)
Use script below for a quick installation
```
wget -qO aptos.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos.sh && chmod +x aptos.sh && ./aptos.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/aptos/manual_install.md) if you better prefer setting up node manually

### Update Aptos Fullnode version
```
wget -qO update.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/tools/update.sh && chmod +x update.sh && ./update.sh
```

### (OPTIONAL) Update configs
```
wget -qO update_configs.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/tools/update_configs.sh && chmod +x update_configs.sh && ./update_configs.sh
```

## Get your node identity and upstream details
To backup your keys you have to run command below and save keys somewhere safe
```
wget -qO get_identity.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/tools/get_identity.sh && chmod +x get_identity.sh && ./get_identity.sh
```

To restore you keys simply put them into system variables and after that run installation script
```
echo "export KEY=<YOUR_KEY>" >> $HOME/.bash_profile
echo "export PEER_ID=<YOUR_PEER_ID>" >> $HOME/.bash_profile
source ./.bash_profile
```

## Useful commands
### Check Aptos logs
```
docker logs -f aptos-fullnode-1 --tail 100
```

### Check sync status
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep storage_synchronizer_operation
```

### Restart service
```
docker restart aptos-fullnode-1
```
