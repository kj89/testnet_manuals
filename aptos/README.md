# masa node setup

## run script below to install your masa node
```
wget -O aptos_devnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/masa/aptos_devnet.sh && chmod +x aptos_devnet.sh && ./aptos_devnet.sh
```

## check node status

### check masa node logs
```
docker logs -f aptos-fullnode-1 --tail 100
```

### check sync status
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
```
