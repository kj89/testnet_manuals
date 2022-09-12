<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/JqQNcwff2e" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>
<p style="font-size:14px" align="right">
<a href="https://m.do.co/c/17b61545ca3a" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus for 60 days <img src="https://user-images.githubusercontent.com/50621007/183284313-adf81164-6db4-4284-9ea0-bcb841936350.png" width="30"/></a>
</p>
<p style="font-size:14px" align="right">
<a href="https://www.vultr.com/?ref=7418642" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus <img src="https://user-images.githubusercontent.com/50621007/183284971-86057dc2-2009-4d40-a1d4-f0901637033a.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/171398816-7e0432f4-4d39-42ad-a72e-cd8dd008028f.png">
</p>

# Subspace node setup for Gemini 2 Non-Incentivized Testnet

Official documentation:
- Official manual: https://github.com/subspace/subspace/blob/main/docs/farming.md
- Telemetry: https://telemetry.subspace.network/#list/0x43d10ffd50990380ffe6c9392145431d630ae67e89dbc9c014cac2a417759101
- Block explorer: https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Feu-1.gemini-2a.subspace.network%2Fws#/explorer

## Minimum Specifications
- CPU: 2 CPU
- Memory: 4 GB RAM
- Disk: 50 GB SSD Storage

## Recommended hardware requirements
- CPU: 4 CPU
- Memory: 8 GB RAM
- Disk: 200 GB SSD Storage

## Required ports
Currently, TCP port `30333` needs to be exposed for node to work properly.
If you have a server with no firewall, there is nothing to be done, but otherwise make sure to open TCP port `30333` for incoming connections.

## Create Polkadot.js wallet
To create polkadot wallet:
1. Download and install [Browser Extension](https://polkadot.js.org/extension/)
2. Navigate to [Subspace Explorer](https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Feu-1.gemini-2a.subspace.network%2Fws#/accounts) and press `Add account` button
3. Save `mnemonic` and create wallet
4. This will generate wallet address that you will have to use later. Example of wallet address: `st7QseTESMmUYcT5aftRJZ3jg357MsaAa93CFQL5UKsyGEk53`

## Set up your Subspace full node
Full node doesn't store the history and state of the whole blockchain, only last 1024 blocks
### Option 1 (automatic)
You can setup your Subspace full node in few minutes by using automated script below
```
wget -O subspace_fullnode.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/subspace/subspace_fullnode.sh && chmod +x subspace_fullnode.sh && ./subspace_fullnode.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/subspace/manual_install_fullnode.md) if you better prefer setting up node manually

## Check you node in the telemetry
When you have finished setting up your node and farmer:
1. Navigate to [Subspace Gemini 1 Telemetry](https://telemetry.subspace.network/#list/0x9ee86eefc3cc61c71a7751bba7f25e442da2512f408e6286153b3ccc055dccf0)
2. And start typing your node name that you privided before
3. You should see yourself in the list like in the image below

![image](https://user-images.githubusercontent.com/50621007/171700021-8997d43b-408f-4275-982f-60896b0df8fb.png)

## Check your node synchronization
If output is `false` your node is synchronized
```
curl -s -X POST http://localhost:9933 -H "Content-Type: application/json" --data '{"id":1, "jsonrpc":"2.0", "method": "system_health", "params":[]}' | jq .result.isSyncing
```

## Update the node
To upgrade your node to new binaries, please run the coommand below:
```
cd $HOME && rm -rf subspace-*
APP_VERSION=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name" | sed "s/runtime-/""/g")
wget -O subspace-node https://github.com/subspace/subspace/releases/download/${APP_VERSION}/subspace-node-ubuntu-x86_64-${APP_VERSION}
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/${APP_VERSION}/subspace-farmer-ubuntu-x86_64-${APP_VERSION}
chmod +x subspace-*
mv subspace-* /usr/local/bin/
systemctl restart subspaced
sleep 30
systemctl restart subspaced-farmer
```

## Fix error while loading shared libraries
If you see error: `error while loading shared libraries: libOpenCL.so.1: cannot open shared object file: No such file or directory`
```
sudo apt update && sudo apt install ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y
```

## Reset the node
If you were running a node previously, and want to switch to a new snapshot, please perform these steps and then follow the guideline again:
```
subspace-farmer wipe
subspace-node purge-chain --chain gemini-2a -y
systemctl restart subspaced
sleep 30
systemctl restart subspaced-farmer
```

## Usefull commands
Check node and farmer version
```
subspace-farmer --version && subspace-node --version
```

Check node status
```
service subspaced status
```

Check farmer status
```
service subspaced-farmer status
```

Check node logs
```
journalctl -u subspaced -f -o cat
```

Check farmer logs
```
journalctl -u subspaced-farmer -f -o cat
```

You should see something similar in the logs:
```
2022-02-03 10:52:23 Subspace
2022-02-03 10:52:23 ✌️  version 0.1.0-35cf6f5-x86_64-ubuntu
2022-02-03 10:52:23 ❤️  by Subspace Labs <https://subspace.network>, 2021-2022
2022-02-03 10:52:23 📋 Chain specification: Subspace Gemini 1
2022-02-03 10:52:23 🏷  Node name: YOUR_FANCY_NAME
2022-02-03 10:52:23 👤 Role: AUTHORITY
2022-02-03 10:52:23 💾 Database: RocksDb at /home/X/.local/share/subspace-node-x86_64-ubuntu-20.04-snapshot-2022-jan-05/chains/subspace_test/db/full
2022-02-03 10:52:23 ⛓  Native runtime: subspace-100 (subspace-1.tx1.au1)
2022-02-03 10:52:23 🔨 Initializing Genesis block/state (state: 0x22a5…17ea, header-hash: 0x6ada…0d38)
2022-02-03 10:52:24 ⏱  Loaded block-time = 1s from block 0x6ada0792ea62bf3501abc87d92e1ce0e78ddefba66f02973de54144d12ed0d38
2022-02-03 10:52:24 Starting archiving from genesis
2022-02-03 10:52:24 Archiving already produced blocks 0..=0
2022-02-03 10:52:24 🏷  Local node identity is: 12D3KooWBgKtea7MVvraeNyxdPF935pToq1x9VjR1rDeNH1qecXu
2022-02-03 10:52:24 🧑‍🌾 Starting Subspace Authorship worker
2022-02-03 10:52:24 📦 Highest known block at #0
2022-02-03 10:52:24 〽️ Prometheus exporter started at 127.0.0.1:9615
2022-02-03 10:52:24 Listening for new connections on 0.0.0.0:9944.
2022-02-03 10:52:26 🔍 Discovered new external address for our node: /ip4/176.233.17.199/tcp/30333/p2p/12D3KooWBgKtea7MVvraeNyxdPF935pToq1x9VjR1rDeNH1qecXu
2022-02-03 10:52:29 ⚙️  Syncing, target=#215883 (2 peers), best: #55 (0xafc7…bccf), finalized #0 (0x6ada…0d38), ⬇ 850.1kiB/s ⬆ 1.5kiB/s
```

To delete node
```
sudo systemctl stop subspaced subspaced-farmer
sudo systemctl disable subspaced subspaced-farmer
rm -rf ~/.local/share/subspace*
rm -rf /etc/systemd/system/subspaced*
rm -rf /usr/local/bin/subspace*
```
