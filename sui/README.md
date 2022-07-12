<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/EY35ZzXY" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/174559198-c1f612e5-bba2-4817-95a8-8a3c3659a2aa.png">
</p>

# Sui node setup for devnet

Official documentation:
- Official manual: https://github.com/MystenLabs/sui/blob/main/doc/src/build/fullnode.md
- Experiment with Sui DevNet: https://docs.sui.io/explore/devnet
- Check you node health: https://node.sui.zvalid.com/

## Minimum hardware requirements
- CPU: 2 CPU
- Memory: 4 GB RAM
- Disk: 50 GB SSD Storage

## Recommended hardware requirements
- CPU: 2 CPU
- Memory: 8 GB RAM
- Disk: 50 GB SSD Storage

> Storage requirements will vary based on various factors (age of the chain, transaction rate, etc) although we don't anticipate running a fullnode on devnet will require more than 50 GBs today given it is reset upon each release roughly every two weeks.

## Set up your Sui full node
### Option 1 (automatic)
You can setup your Sui full node in minutes by using automated script below
```
wget -O sui.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/sui/sui.sh && chmod +x sui.sh && ./sui.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/sui/manual_install.md) if you better prefer setting up node manually

## Make tests
Once the fullnode is up and running, test some of the JSON-RPC interfaces.

### Check status of your node
```
curl -s -X POST http://127.0.0.1:9000 -H 'Content-Type: application/json' -d '{ "jsonrpc":"2.0", "method":"rpc.discover","id":1}' | jq .result.info
```

You should see something similar in the output:
```json
{
  "title": "Sui JSON-RPC",
  "description": "Sui JSON-RPC API for interaction with the Sui network gateway.",
  "contact": {
    "name": "Mysten Labs",
    "url": "https://mystenlabs.com",
    "email": "build@mystenlabs.com"
  },
  "license": {
    "name": "Apache-2.0",
    "url": "https://raw.githubusercontent.com/MystenLabs/sui/main/LICENSE"
  },
  "version": "0.1.0"
}
```

### Get the five most recent transactions
```
curl --location --request POST 'http://127.0.0.1:9000/' --header 'Content-Type: application/json' --data-raw '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }' | jq .
```

### Get details about a specific transaction
```
curl --location --request POST 'http://127.0.0.1:9000/' --header 'Content-Type: application/json' --data-raw '{ "jsonrpc":"2.0", "id":1, "method":"sui_getTransaction", "params":["$RECENT_TXN_FROM_ABOVE"] }' | jq .
```

## Post installation
After setting up your Sui node you have to register it in the [Sui Discord](https://discord.gg/b5vWu33f):
1) navigate to `#📋node-ip-application` channel
2) post your node endpoint url
```
http://<YOUR_NODE_IP>:9000/
```

## Check your node health status
Enter your node IP into https://node.sui.zvalid.com/

Healthy node should look like this:

![image](https://user-images.githubusercontent.com/50621007/175829451-a36d32ff-f30f-4030-8875-7ffa4e999a24.png)

## Update Sui Fullnode version
```
wget -qO update.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/sui/tools/update.sh && chmod +x update.sh && ./update.sh
```

## Usefull commands
Check sui node status
```
docker ps -a
```

Check node logs
```
docker logs -f sui-fullnode-1 --tail 50
```

To delete node
```
cd $HOME/sui && docker-compose down --volumes
cd $HOME && rm -rf sui
```
