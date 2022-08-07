<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
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
- Official manual: https://docs.sui.io/build/fullnode
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
curl --location --request POST 'http://127.0.0.1:9000/' --header 'Content-Type: application/json' \
--data-raw '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }' | jq .
```

### Get details about a specific transaction
```
curl --location --request POST 'http://127.0.0.1:9000/' --header 'Content-Type: application/json' \
--data-raw '{ "jsonrpc":"2.0", "id":1, "method":"sui_getTransaction", "params":["<RECENT_TXN_FROM_ABOVE>"] }' | jq .
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

## Generate wallet
```
echo -e "y\n" | sui client
```
> !Please backup your wallet key files located in `$HOME/.sui/sui_config/` directory!

## Top up your wallet
1. Get your wallet address:
```
sui client active-address
```

2. Navigate to [Sui Discord](https://discord.gg/sui) `#devnet-faucet` channel and top up your wallet
```
!faucet <YOUR_WALLET_ADDRESS>
```

![image](https://user-images.githubusercontent.com/50621007/180215182-cbb7fc6c-aba3-4834-ad05-f79e1c26b40c.png)

3. Wait until bot sends tokens to your wallet

![image](https://user-images.githubusercontent.com/50621007/180222321-1dc5323b-1174-41c8-b632-6ac2ce639ce1.png)

4. You can check your balance at `https://explorer.devnet.sui.io/addresses/<YOUR_WALLET_ADDRESS>`

![image](https://user-images.githubusercontent.com/50621007/180222644-d06af8ea-f0e7-4775-a341-f7b5cdda18af.png)

5. If you expand `Coins` than you can find that your wallet contains `5 unique objects` with `50000` token balances

![image](https://user-images.githubusercontent.com/50621007/180223173-a24a6211-5388-4d18-8d88-a873f8565352.png)
![image](https://user-images.githubusercontent.com/50621007/180224381-ba4aec00-1176-4ae9-98a5-4de730822d88.png)

Also you can get list of objects in your console by using command
```
sui client gas
```

![image](https://user-images.githubusercontent.com/50621007/180225024-795427bb-77b7-4110-b829-0eb1ba5b6a62.png)

## Operations with objects
Now lets do some operations with objects

### Merge two objects into one
```
JSON=$(sui client gas --json | jq -r)
FIRST_OBJECT_ID=$(echo $JSON | jq -r .[0].info.id)
SECOND_OBJECT_ID=$(echo $JSON | jq -r .[1].info.id)
sui client merge-coin --primary-coin ${FIRST_OBJECT_ID} --coin-to-merge ${SECOND_OBJECT_ID} --gas-budget 1000
```

You should see output like this:
```
----- Certificate ----
Transaction Hash: t3BscscUH2tMnMRfzYyc4Nr9HZ65nXuaL87BicUwXVo=
Transaction Signature: OCIYOWRPLSwpLG0bAmDTMixvE3IcyJgcRM5TEXJAOWvDv1xDmPxm99qQEJJQb0iwCgEfDBl74Q3XI6yD+AK7BQ==@U6zbX7hNmQ0SeZMheEKgPQVGVmdE5ikRQZIeDKFXwt8=
Signed Authorities Bitmap: RoaringBitmap<[0, 2, 3]>
Transaction Kind : Call
Package ID : 0x2
Module : coin
Function : join
Arguments : ["0x530720be83c5e8dffde5f602d2f36e467a24f6de", "0xb66106ac8bc9bf8ec58a5949da934febc6d7837c"]
Type Arguments : ["0x2::sui::SUI"]
----- Merge Coin Results ----
Updated Coin : Coin { id: 0x530720be83c5e8dffde5f602d2f36e467a24f6de, value: 100000 }
Updated Gas : Coin { id: 0xc0a3fa96f8e52395fa659756a6821c209428b3d9, value: 49560 }
```

Lets yet again check list of objects
```
sui client gas
```

We can see that two first objects are now merged into one and gas has been payed by third object

![image](https://user-images.githubusercontent.com/50621007/180228094-10b563f4-ea6f-42cd-b560-6abeda47c2df.png)

>This is only one example of transactions that can be made at the moment. Other examples can be found at the [official website](https://docs.sui.io/build/wallet)

## Usefull commands for sui fullnode
Check sui node status
```
systemctl status suid
```

Check node logs
```
journalctl -fu suid -o cat
```

Check sui client version
```
sui --version
```

Update sui version
```
wget -qO update.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/sui/tools/update.sh && chmod +x update.sh && ./update.sh
```

## Recover your keys
Copy your keys into `$HOME/.sui/sui_config/` directory and restart the node

## Delete your node
```
systemctl stop suid
systemctl disable suid
rm -rf $HOME/.sui /usr/local/bin/sui*
```