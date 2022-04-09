<p align="center">
  <img width="300" height="auto" src="https://user-images.githubusercontent.com/50621007/162568594-c423847a-f1ff-42de-84d7-110bb0077b4d.png">
</p>

# APTOS FULLNODE SETUP GUIDE

> current block height can be found [here](https://status.devnet.aptos.dev)

> check the status of your node [here](https://www.nodex.run/aptos_test). On this site you can also create a wallet and test sending transactions.

> another node tester website with nice metric visualizer [here](http://node-tools.net/aptos/tester/)

## INSTALLATION USING DOCKER

Use script below for a quick installation
```
wget -O aptos_docker.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_docker.sh && chmod +x aptos_docker.sh && ./aptos_docker.sh
```

Update Aptos Fullnode version
```
wget -O aptos_docker_update.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_docker_update.sh && chmod +x aptos_docker_update.sh && ./aptos_docker_update.sh
```

(OPTIONAL) Update seeds
```
wget -O aptos_docker_seeds.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_docker_seeds.sh && chmod +x aptos_docker_seeds.sh && ./aptos_docker_seeds.sh
```

## USEFUL COMMANDS

### Get your node identity and upstrem details
```
wget -O aptos_identity.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_identity.sh && chmod +x aptos_identity.sh && ./aptos_identity.sh
```

### Check Aptos logs
```
docker logs -f aptos-fullnode-1 --tail 100
```

### Check sync status
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
```

### Check private key
```
cat $HOME/aptos/identity/private-key.txt
```

### Check public key
```
cat $HOME/aptos/identity/id.json
```

### Restart service
```
docker restart aptos-fullnode-1
```

## BACKUP AND RESTORE
### Backup your identity files
In order to back up your keys please save identity files located in `$HOME/aptos/identity` to safe location

### Recover your identity keys
Place your saved identity keys back into `$HOME/aptos/identity` and run script below
```
wget -O aptos_docker_restore.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_docker_restore.sh && chmod +x aptos_docker_restore.sh && ./aptos_docker_restore.sh
```
