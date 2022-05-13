<p align="center">
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/165930080-4f541b46-1ae3-461c-acc9-de72d7ab93b7.png">
</p>

# Aptos validator node setup for Incentivized Testnet (Updated 14.05.2022)
Official documents:
> [Run a Validator Node](https://aptos.dev/tutorials/validator-node/intro)

Usefull tools:
> To find latest block height use [Aptos Network Dashboard](https://status.devnet.aptos.dev/)\
> To check your node health status try [Aptos Node Informer](http://node-tools.net/aptos/tester/)\
> To migrate your fullnode to another machine read [Migrate your fullnode to another machine](https://github.com/kj89/testnet_manuals/blob/main/aptos/testnet/migrate_fullnode.md)

## Hardware requirements:
#### For running an aptos node on incentivized testnet we recommend the following:
- CPU: 4 cores (Intel Xeon Skylake or newer)
- Memory: 8GiB RAM
- Storage: 300GB (You have the option to start with a smaller size and adjust based upon demands)

## Set up your aptos fullnode
### Option 1 (automatic)
Use script below for a quick installation
```
wget -qO aptos.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/aptos.sh && chmod +x aptos.sh && ./aptos.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/aptos/testnet/manual_install.md) if you better prefer setting up node manually

## Useful commands
### Check Aptos logs
```
docker logs -f testnet-fullnode-1 --tail 50
```

### Check sync status
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
```

### Restart docker containers
```
docker compose restart
```
