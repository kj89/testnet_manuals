<p align="center">
  <img height="100" height="auto" src="https://github.com/tendermint/tendermint/assets/50621007/55e537e9-3a40-4e44-98cc-b172e385c93d">
</p>

# Avail node setup for goldberg Testnet

Official documentation:
- Official manual: https://docs.availproject.org/category/operate-a-node/
- Block explorer: https://goldberg.avail.tools/#/explorer
- Telemetry: http://telemetry.avail.tools
- Wallet: https://goldberg.avail.tools/

## Minimum Specifications
- CPU: 2 CPU
- Memory: 4 GB RAM
- Disk: 50 GB SSD Storage (to start)

## Recommended hardware requirements
- CPU: 4 CPU
- Memory: 8 GB RAM
- Disk: 100 GB SSD Storage (to start)

## Required ports
No ports needed to be opened if you will be connecting to the node on localhost.
For RPC and WebSockets the following should be opened: `9933/TCP, 9944/TCP`

## Setting up vars
>Replace `YOUR_NODENAME` below with the name of your node
```
NODENAME=<YOUR_NODENAME>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Install avail node
To setup avail node follow the steps below

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl jq ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y
```

## Update executables
```
cd $HOME
sudo rm -rf data-avail
APP_VERSION=$(curl -s https://api.github.com/repos/availproject/avail/releases/latest | jq -r ".tag_name")
wget -O data-avail.tar.gz https://github.com/availproject/avail/releases/download/${APP_VERSION}/x86_64-ubuntu-2204-data-avail.tar.gz
sudo tar zxvf data-avail.tar.gz
sudo rm -rf data-avail.tar.gz
sudo chmod +x data-avail
sudo mv data-avail /usr/local/bin/
```

## Create chain data directory
```
sudo mkdir ~/avail-node
sudo chmod 0777 ~/avail-node
```

## Create data-avail service
```
sudo tee <<EOF >/dev/null /etc/systemd/system/availd.service
[Unit]
Description=Avail Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which data-avail) \\
--base-path ~/avail-node/data \\
--chain goldberg \\
--validator \\
--name $NODENAME
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Run avail services
```
sudo systemctl daemon-reload
sudo systemctl enable availd
sudo systemctl start availd
```

## Check node logs
```
journalctl -fu availd -o cat
```


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
cd $HOME && sudo rm -rf data-avail
APP_VERSION=$(curl -s https://api.github.com/repos/availproject/avail/releases/latest | jq -r ".tag_name")
wget -O data-avail.tar.gz https://github.com/availproject/avail/releases/download/${APP_VERSION}/x86_64-ubuntu-2204-data-avail.tar.gz
sudo tar zxvf data-avail.tar.gz
sudo rm -rf data-avail.tar.gz
sudo chmod +x data-avail
sudo mv data-avail /usr/local/bin/
sudo systemctl restart availd
```

## Reset the node
If you were running a node previously, and want to switch to a new snapshot, please perform these steps and then follow the guideline again:
```
data-avail purge-chain --chain goldberg --base-path ~/avail-node/data -y
sudo systemctl restart availd
```

## Usefull commands
Check node version
```
data-avail --version
```

Check node status
```
sudo service availd status
```

Check node logs
```
journalctl -u availd -f -o cat
```

You should see something similar in the logs:
```
Jun 28 16:40:32 paeq-01 systemd[1]: Started Avail Node.
Jun 28 16:40:32 paeq-01 data-avail[27357]: 2022-06-28 16:40:32 PEAQ Node
Jun 28 16:40:32 paeq-01 data-avail[27357]: 2022-06-28 16:40:32 ✌️  version 3.0.0-polkadot-v0.9.16-6f72704-x86_64-linux-gnu
Jun 28 16:40:32 paeq-01 data-avail[27357]: 2022-06-28 16:40:32 ❤️  by peaq network <https://github.com/peaqnetwork>, 2021-2022
Jun 28 16:40:32 paeq-01 data-avail[27357]: 2022-06-28 16:40:32 📋 Chain specification: goldberg-network
Jun 28 16:40:32 paeq-01 data-avail[27357]: 2022-06-28 16:40:32 🏷  Node name: ro_full_node_0
Jun 28 16:40:32 paeq-01 data-avail[27357]: 2022-06-28 16:40:32 👤 Role: FULL
Jun 28 16:40:32 paeq-01 data-avail[27357]: 2022-06-28 16:40:32 💾 Database: RocksDb at .~/avail-node/data/chains/goldberg-substrate-testnet/db/full
Jun 28 16:40:32 paeq-01 data-avail[27357]: 2022-06-28 16:40:32 ⛓  Native runtime: data-avail-3 (data-avail-1.tx1.au1)
Jun 28 16:40:36 paeq-01 data-avail[27357]: 2022-06-28 16:40:36 🔨 Initializing Genesis block/state (state: 0x72d3…181f, header-hash: 0xf496…909f)
Jun 28 16:40:36 paeq-01 data-avail[27357]: 2022-06-28 16:40:36 👴 Loading GRANDPA authority set from genesis on what appears to be first startup.
Jun 28 16:40:40 paeq-01 data-avail[27357]: 2022-06-28 16:40:40 Using default protocol ID "sup" because none is configured in the chain specs
Jun 28 16:40:40 paeq-01 data-avail[27357]: 2022-06-28 16:40:40 🏷  Local node identity is: 12D3KooWD4hyKVKe3v99KJadKVVUEXKEw1HNp5d6EXpzyVFDwQtq
Jun 28 16:40:40 paeq-01 data-avail[27357]: 2022-06-28 16:40:40 📦 Highest known block at #0
Jun 28 16:40:40 paeq-01 data-avail[27357]: 2022-06-28 16:40:40 〽️ Prometheus exporter started at 127.0.0.1:9615
Jun 28 16:40:40 paeq-01 data-avail[27357]: 2022-06-28 16:40:40 Listening for new connections on 127.0.0.1:9944.
Jun 28 16:40:40 paeq-01 data-avail[27357]: 2022-06-28 16:40:40 🔍 Discovered new external address for our node: /ip4/138.201.118.10/tcp/1033/ws/p2p/12D3KooWD4hyKVKe3v99KJadKVVUEXKEw1HNp5d6EXpzyVFDwQtq
Jun 28 16:40:45 paeq-01 data-avail[27357]: 2022-06-28 16:40:45 ⚙️  Syncing, target=#1180121 (13 peers), best: #3585 (0x40f3…2548), finalized #3584 (0x292b…1fee), ⬇ 386.2kiB/s ⬆ 40.1kiB/s
Jun 28 16:40:50 paeq-01 data-avail[27357]: 2022-06-28 16:40:50 ⚙️  Syncing 677.6 bps, target=#1180122 (13 peers), best: #6973 (0x6d89…9f39), finalized #6656 (0xaff8…65d9), ⬇ 192.5kiB/s ⬆ 7.8kiB/s
Jun 28 16:40:55 paeq-01 data-avail[27357]: 2022-06-28 16:40:55 ⚙️  Syncing 494.6 bps, target=#1180123 (13 peers), best: #9446 (0xe7e2…c2d9), finalized #9216 (0x1951…dc01), ⬇ 188.7kiB/s ⬆ 5.8kiB/s
```

To delete node
```
sudo systemctl stop availd
sudo systemctl disable availd
sudo rm -rf /etc/systemd/system/availd*
sudo rm -rf /usr/local/bin/data-avail
sudo rm -rf ~/avail-node
```
