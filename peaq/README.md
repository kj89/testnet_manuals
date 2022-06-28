<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/EY35ZzXY" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/176226900-aae9149d-a186-4fd5-a9aa-fc3ce8b082b3.png">
</p>

# Peaq node setup for Gemini Incentivized Testnet

Official documentation:
- Official manual: https://docs.peaq.network/node-operators/run-an-agung-node-peaq-testnet
- Telemetry: N/A
- Block explorer: https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/explorer

## Minimum Specifications
- CPU: 2 CPU
- Memory: 4 GB RAM
- Disk: 50 GB SSD Storage (to start)

## Recommended hardware requirements
- CPU: 4 CPU
- Memory: 8 GB RAM
- Disk: 50 GB SSD Storage (to start)

## Required ports
No ports needed to be opened if you will be connecting to the node on localhost.
For RPC and WebSockets the following should be opened: `9933/TCP, 9944/TCP`

### Option 1 (automatic)
You can setup your Peaq full node in few minutes by using automated script below
```
wget -O peaq.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/peaq/peaq.sh && chmod +x peaq.sh && ./peaq.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/peaq/manual_install.md) if you better prefer setting up node manually

## Check your node synchronization
If output is `false` your node is synchronized
```
curl -s -X POST http://localhost:9933 -H "Content-Type: application/json" --data '{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}' | jq .result.isSyncing
```

## Update the node
To upgrade your node to new binaries, please run the coommand below:
```
cd $HOME && sudo rm -rf peaq-node
APP_VERSION=$(curl -s https://api.github.com/repos/peaqnetwork/peaq-network-node/releases/latest | jq -r ".tag_name")
wget -O peaq-node.tar.gz https://github.com/peaqnetwork/peaq-network-node/releases/download/${APP_VERSION}/peaq-node-${APP_VERSION}.tar.gz
sudo tar zxvf peaq-node.tar.gz
sudo chmod +x peaq-node
sudo mv peaq-node /usr/local/bin/
systemctl restart peaqd
```

## Reset the node
If you were running a node previously, and want to switch to a new snapshot, please perform these steps and then follow the guideline again:
```
peaq-node purge-chain --chain agung -y
systemctl restart peaqd
```

## Usefull commands
Check node and farmer version
```
peaq-node --version
```

Check node status
```
service peaqd status
```

Check node logs
```
journalctl -u peaqd -f -o cat
```

You should see something similar in the logs:
```
Jun 28 16:40:32 paeq-01 systemd[1]: Started Peaq Node.
Jun 28 16:40:32 paeq-01 peaq-node[27357]: 2022-06-28 16:40:32 PEAQ Node
Jun 28 16:40:32 paeq-01 peaq-node[27357]: 2022-06-28 16:40:32 ✌️  version 3.0.0-polkadot-v0.9.16-6f72704-x86_64-linux-gnu
Jun 28 16:40:32 paeq-01 peaq-node[27357]: 2022-06-28 16:40:32 ❤️  by peaq network <https://github.com/peaqnetwork>, 2021-2022
Jun 28 16:40:32 paeq-01 peaq-node[27357]: 2022-06-28 16:40:32 📋 Chain specification: agung-network
Jun 28 16:40:32 paeq-01 peaq-node[27357]: 2022-06-28 16:40:32 🏷  Node name: ro_full_node_0
Jun 28 16:40:32 paeq-01 peaq-node[27357]: 2022-06-28 16:40:32 👤 Role: FULL
Jun 28 16:40:32 paeq-01 peaq-node[27357]: 2022-06-28 16:40:32 💾 Database: RocksDb at ./chain-data/chains/agung-substrate-testnet/db/full
Jun 28 16:40:32 paeq-01 peaq-node[27357]: 2022-06-28 16:40:32 ⛓  Native runtime: peaq-node-3 (peaq-node-1.tx1.au1)
Jun 28 16:40:36 paeq-01 peaq-node[27357]: 2022-06-28 16:40:36 🔨 Initializing Genesis block/state (state: 0x72d3…181f, header-hash: 0xf496…909f)
Jun 28 16:40:36 paeq-01 peaq-node[27357]: 2022-06-28 16:40:36 👴 Loading GRANDPA authority set from genesis on what appears to be first startup.
Jun 28 16:40:40 paeq-01 peaq-node[27357]: 2022-06-28 16:40:40 Using default protocol ID "sup" because none is configured in the chain specs
Jun 28 16:40:40 paeq-01 peaq-node[27357]: 2022-06-28 16:40:40 🏷  Local node identity is: 12D3KooWD4hyKVKe3v99KJadKVVUEXKEw1HNp5d6EXpzyVFDwQtq
Jun 28 16:40:40 paeq-01 peaq-node[27357]: 2022-06-28 16:40:40 📦 Highest known block at #0
Jun 28 16:40:40 paeq-01 peaq-node[27357]: 2022-06-28 16:40:40 〽️ Prometheus exporter started at 127.0.0.1:9615
Jun 28 16:40:40 paeq-01 peaq-node[27357]: 2022-06-28 16:40:40 Listening for new connections on 127.0.0.1:9944.
Jun 28 16:40:40 paeq-01 peaq-node[27357]: 2022-06-28 16:40:40 🔍 Discovered new external address for our node: /ip4/138.201.118.10/tcp/1033/ws/p2p/12D3KooWD4hyKVKe3v99KJadKVVUEXKEw1HNp5d6EXpzyVFDwQtq
Jun 28 16:40:45 paeq-01 peaq-node[27357]: 2022-06-28 16:40:45 ⚙️  Syncing, target=#1180121 (13 peers), best: #3585 (0x40f3…2548), finalized #3584 (0x292b…1fee), ⬇ 386.2kiB/s ⬆ 40.1kiB/s
Jun 28 16:40:50 paeq-01 peaq-node[27357]: 2022-06-28 16:40:50 ⚙️  Syncing 677.6 bps, target=#1180122 (13 peers), best: #6973 (0x6d89…9f39), finalized #6656 (0xaff8…65d9), ⬇ 192.5kiB/s ⬆ 7.8kiB/s
Jun 28 16:40:55 paeq-01 peaq-node[27357]: 2022-06-28 16:40:55 ⚙️  Syncing 494.6 bps, target=#1180123 (13 peers), best: #9446 (0xe7e2…c2d9), finalized #9216 (0x1951…dc01), ⬇ 188.7kiB/s ⬆ 5.8kiB/s
```

To delete node
```
sudo systemctl stop peaqd
sudo systemctl disable peaqd
rm -rf ~/.local/share/peaq*
rm -rf /etc/systemd/system/peaqd*
rm -rf /usr/local/bin/peaq*
```


# How to transfer tokens between Ethereum and substrate wallets

## Create Polkadot.js wallet
To create polkadot wallet:
1. Download and install [Browser Extension](https://polkadot.js.org/extension/)
2. Navigate to [Peaq Explorer](https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/accounts) and press `Add account` button
3. Save `mnemonic` and create wallet
4. This will generate wallet address that you will have to use later. Example of wallet address: `5HTBxt66esFrqyFDraQvxWuiHfPbS5t6FLLTPEN37sZu6T5A`

## Create an Ethereum wallet on Agung (peaq Testnet)
1. Download and install [Metamask Browser Extension](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en)
2. After adding the MetaMask plugin, connectivity needs to established with Agung network by adding:
- Network Name: PEAQ
- RPC endpoint: ​https://erpc.agung.peaq.network/
- Chain ID: 9999
- Currency Symbol: AGNG

![3](https://user-images.githubusercontent.com/50621007/176243099-129b9b0f-e037-4c15-b490-dea491b8a379.png)

3. Once connected with Agung network, the details of the wallet address are seen.

![3](https://user-images.githubusercontent.com/50621007/176243535-fe5f2557-d3dc-4651-8220-a507f56cc323.png)

4. You send your AGNG tokens now.

![image](https://user-images.githubusercontent.com/50621007/176243606-2ee867ee-f2b0-4c9b-a63d-7b64d4fd3a74.png)

## Fund your polkadot wallet
To top up your wallet join [peaq discord server](https://discord.gg/6tTJH7QT) and navigate to:
- **#agung-faucet** for AGNG tokens

To request a faucet grant:
```
!send <YOUR_WALLET_ADDRESS>
```

## Deposit tokens from a Substrate Wallet to an ETH wallet on Agung (peaq Testnet)
### Generate your deposit address
1. Copy your ETH address (Public Key)
2. Use [this website](https://hoonsubin.github.io/evm-substrate-address-converter/index.html) to calculate your deposit address for Substrate.
3. Change the address scheme to "H160".
4. Leave the "Change address prefix" at "5".
5. Enter your ETH address (Public Key) into the "Input address" field.
6. Copy the lower address which represents your deposit address.  

![image](https://user-images.githubusercontent.com/50621007/176244218-81e688ad-05d2-471f-ab3d-962fafa28059.png)

![image](https://user-images.githubusercontent.com/50621007/176244307-6169cc47-b41e-4599-83e6-a70e1dcf936f.png)

### Transfer Tokens 
1. Go to [polkadot.js](https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/accounts)
2. Select the account you want to transfer funds from and click "send":

![image](https://user-images.githubusercontent.com/50621007/176244892-d1c5e1cc-27fd-4cab-a8df-f138a3f63cbe.png)

3. Enter your generated deposit address in the "send to address" field:

![image](https://user-images.githubusercontent.com/50621007/176245009-7fbded77-8365-41f0-8001-8909705dd704.png)

4. Enter the amount you want to transfer. 
5. Click the "Make transfer" button.
6. Click the "Sign and Submit" button.
7. Check the balance on your Ethereum (Metamask) Wallet.

![image](https://user-images.githubusercontent.com/50621007/176245132-a72f7bb6-4c83-488e-9de9-94a81e0dd19f.png)

You have successfully transferred Tokens from your Substarte Wallet to your Ethereum Wallet. 

## Withdraw tokens from an ETH Wallet to a Substrate wallet on Agung (peaq Testnet)
### Generate your deposit address
1. Copy your Substrate address (Public Key)

![image](https://user-images.githubusercontent.com/50621007/176245757-c808713d-0c06-4191-9053-718da5bfd824.png)

2. Use [this website](https://www.shawntabrizi.com/substrate-js-utilities/) to calculate your withdrawal address for Substrate. \
Paste your (1) Substrate address under the AccountId to Hex text input. \
Copy the first 42 characters from the converted result, or 40 characters with exception of the "0x"

![image](https://user-images.githubusercontent.com/50621007/176245925-a139e0b3-882d-4046-bc2c-145f05c6017c.png)

3. Send AGNG from your ETH wallet to this recent copied ETH address

<img src="https://user-images.githubusercontent.com/50621007/176246164-d6283c56-525d-4c17-84c3-27b5b5293337.png" alt="drawing" width="300"/>

4. Approve and sign the transaction. Pay the calculated gas for this transaction.

<img src="https://user-images.githubusercontent.com/50621007/176246252-9d5d21f0-c526-4a6d-aabb-c40ddbdc9ac5.png" alt="drawing" width="300"/>

Your transaction is on its way. After a few seconds you should have it completed.

<img src="https://user-images.githubusercontent.com/50621007/176246300-44404b3f-f518-4699-bbc3-edf91b5a3adc.png" alt="drawing" width="300"/>

5. Go to the [Polkadot js Extrinsicts page](https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/extrinsics)

![image](https://user-images.githubusercontent.com/50621007/176246463-69c64242-cdbe-46ef-86c2-824043df2a11.png)

6. Complete the form to call an Extrinsics, like the following example:
- Using the selected account: Who is paying fees for the transaction? in this case could be your own Substrate address (if you have balance), or any of the development test accounts, like ALICE or FERDI.
- submit the following extrinsic: select evm
- source: H160: the ETH address which we recently send AGNG (0xd6fbaf5f0eafd5b1fe6911930c925f1ce4ae7363)
- value (BalanceOF): how many AGNG will I retrieve from the Extrinsic. In this case .2 AGNG = 2 + 17 zeros or 1 AGNG = 1000000000000000000 (+ 18 zeros)

![image](https://user-images.githubusercontent.com/50621007/176246599-ac5dcf87-ef1f-44ff-bb28-7950f90426b8.png)

7. Sing the transaction. Wait a few seconds for a confirmation. Your AGNG should arrive to your account.

![image](https://user-images.githubusercontent.com/50621007/176246653-f01ff9fa-3dfb-48ee-b332-b9e3f7e3f581.png)

You have successfully transferred Tokens from your ETH Wallet to your Substrate Wallet. 