<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/176226900-aae9149d-a186-4fd5-a9aa-fc3ce8b082b3.png">
</p>

# Peaq node setup for Agung Testnet

Official documentation:
- Official manual: https://docs.peaq.network/node-operators/run-an-agung-node-peaq-testnet
- Block explorer: https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/explorer
- EVM Explorer: https://scout.agung.peaq.network/

Additional tasks:
- [Transfer tokens between Ethereum and substrate wallets](https://github.com/kj89/testnet_manuals/blob/main/peaq/token_transfer.md)

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

## Check connected peer count
```
curl -s -X POST http://localhost:9933 -H "Content-Type: application/json" --data '{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}' | jq .result.peers
```

## Update the node
To upgrade your node to new binaries, please run the coommand below:
```
cd $HOME && sudo rm -rf peaq-node
APP_VERSION=$(curl -s https://api.github.com/repos/peaqnetwork/peaq-network-node/releases/latest | jq -r ".tag_name")
wget -O peaq-node.tar.gz https://github.com/peaqnetwork/peaq-network-node/releases/download/${APP_VERSION}/peaq-node-${APP_VERSION}.tar.gz
sudo tar zxvf peaq-node.tar.gz
sudo rm peaq-node.tar.gz
sudo chmod +x peaq-node
sudo mv peaq-node /usr/local/bin/
sudo systemctl restart peaqd
```

## Reset the node
If you were running a node previously, and want to switch to a new snapshot, please perform these steps and then follow the guideline again:
```
peaq-node purge-chain --chain agung --base-path /chain-data -y
sudo systemctl restart peaqd
```

## Usefull commands
Check node version
```
peaq-node --version
```

Check node status
```
sudo service peaqd status
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
sudo rm -rf /etc/systemd/system/peaqd*
sudo rm -rf /usr/local/bin/peaq*
sudo rm -rf /chain-data
```
