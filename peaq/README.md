<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/176226900-aae9149d-a186-4fd5-a9aa-fc3ce8b082b3.png">
</p>

# peaq node setup for Gemini Incentivized Testnet

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

## Create Polkadot.js wallet
To create polkadot wallet:
1. Download and install [Browser Extension](https://polkadot.js.org/extension/)
2. Navigate to [peaq Explorer](https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/accounts) and press `Add account` button
3. Save `mnemonic` and create wallet
4. This will generate wallet address that you will have to use later. Example of wallet address: `5HTBxt66esFrqyFDraQvxWuiHfPbS5t6FLLTPEN37sZu6T5A`

### Option 1 (automatic)
You can setup your peaq full node in few minutes by using automated script below
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
2022-02-03 10:52:23 peaq
2022-02-03 10:52:23 ✌️  version 0.1.0-35cf6f5-x86_64-ubuntu
2022-02-03 10:52:23 ❤️  by peaq Labs <https://peaq.network>, 2021-2022
2022-02-03 10:52:23 📋 Chain specification: peaq Gemini 1
2022-02-03 10:52:23 🏷  Node name: YOUR_FANCY_NAME
2022-02-03 10:52:23 👤 Role: AUTHORITY
2022-02-03 10:52:23 💾 Database: RocksDb at /home/X/.local/share/peaq-node-x86_64-ubuntu-20.04-snapshot-2022-jan-05/chains/peaq_test/db/full
2022-02-03 10:52:23 ⛓  Native runtime: peaq-100 (peaq-1.tx1.au1)
2022-02-03 10:52:23 🔨 Initializing Genesis block/state (state: 0x22a5…17ea, header-hash: 0x6ada…0d38)
2022-02-03 10:52:24 ⏱  Loaded block-time = 1s from block 0x6ada0792ea62bf3501abc87d92e1ce0e78ddefba66f02973de54144d12ed0d38
2022-02-03 10:52:24 Starting archiving from genesis
2022-02-03 10:52:24 Archiving already produced blocks 0..=0
2022-02-03 10:52:24 🏷  Local node identity is: 12D3KooWBgKtea7MVvraeNyxdPF935pToq1x9VjR1rDeNH1qecXu
2022-02-03 10:52:24 🧑‍🌾 Starting peaq Authorship worker
2022-02-03 10:52:24 📦 Highest known block at #0
2022-02-03 10:52:24 〽️ Prometheus exporter started at 127.0.0.1:9615
2022-02-03 10:52:24 Listening for new connections on 0.0.0.0:9944.
2022-02-03 10:52:26 🔍 Discovered new external address for our node: /ip4/176.233.17.199/tcp/30333/p2p/12D3KooWBgKtea7MVvraeNyxdPF935pToq1x9VjR1rDeNH1qecXu
2022-02-03 10:52:29 ⚙️  Syncing, target=#215883 (2 peers), best: #55 (0xafc7…bccf), finalized #0 (0x6ada…0d38), ⬇ 850.1kiB/s ⬆ 1.5kiB/s
```

To delete node
```
sudo systemctl stop peaqd
sudo systemctl disable peaqd
rm -rf ~/.local/share/peaq*
rm -rf /etc/systemd/system/peaqd*
rm -rf /usr/local/bin/peaq*
```
