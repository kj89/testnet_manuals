## Celestia node setup

![image](https://user-images.githubusercontent.com/50621007/157865942-69a28d42-3161-4f38-843d-0cf8f8256aa0.png)

### Run celestia devnet-2 (rpc, bridge, light)
This script does not include validator creation as faucet for devnet is disabled and running validator is not necessary at this stage
```
wget -O celestia_devnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/celestia_devnet.sh && chmod +x celestia_devnet.sh && ./celestia_devnet.sh
```

As alternative you can setup Celestia nodes manually by following guides provided by community member mzonder
https://mzonder.notion.site/CELESTIA-8b8e89820d114c8cb9b6a63b377302ee

Options:

1) Install/Update App - Installs/Updates Celestia App software (current version 63519ec). To start installation you have to provide your node name. After installation is complete you will see current block synchronization process.
2) Install/Update Node - Installs/Updates Clestia Node software (current version v0.2.0). 
3) Initialize Bridge - Initialize Celestia Bridge node. You will have to provide rpc node ip or use default localhost if celestia rpc is runnning locally
4) Initialize Light - Initialize Celestia Light node. It is not recommended to run both types of nodes (bridge, ligt) on same VPS.
5) Sync Status - Follow synchronization status of your local rpc node.
6) Erase all - Removes all Celestia components
7) Quit - Quits menu

## Guides to install nodes
To install celestia software you have to run script above and follow instructions below

### To install local RPC node with Bridge node (currently you will need about 50GB of empty space to fully synchronize chain data)
```
press 1
input your rpc node name
press 3
choose localhost as your rpc node ip
wait until installation completes and check logs
```

### To install Bridge node with external RPC
```
press 2
press 3
input external ip as your rpc node ip (external rpc should be reachable)
wait until installation completes and check logs
```

### To install Light node
```
press 4
wait until installation completes and check logs
```

### Set up local RPC node
```
press 1
input your rpc node name
wait until installation completes and check synchronization status
```

### Update celestia app software
```
press 1
```

### Update celestia node software
```
press 2
```

### Erase all celestia data
```
press 6
```

## Usefull commands

### Check node synchronization status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```

### Check bridge node logs
```
journalctl -fu celestia-bridge -o cat
```

### Check light node logs
```
journalctl -fu celestia-light -o cat
```
