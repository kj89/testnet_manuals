## Sentry setup

### Run script bellow to prepare your RPC server
```
wget -O agoric_mainnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/agoric/agoric_mainnet.sh && chmod +x agoric_mainnet.sh && ./agoric_mainnet.sh
```

## Validator setup and modify
Amounts of uBLD to BLD are 1 to 1 000 000
Create validator
```
chainName=`curl https://main.agoric.net/network-config | jq -r .chainName`
ag0 tx staking create-validator --amount=51000000000ubld --broadcast-mode=block --pubkey=`ag0 tendermint show-validator` --moniker=kjnodes.com --website="http://kjnodes.com" --details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" --commission-rate="0.07" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1" --from=agoric-wallet --chain-id=$chainName --gas-adjustment=1.4 --fees=5001ubld
```

Modify validator
```
chainName=`curl https://main.agoric.net/network-config | jq -r .chainName`
ag0 tx staking edit-validator --moniker="kjnodes.com" --website="http://kjnodes.com" --details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" --chain-id=$chainName --from=agoric-wallet
```

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node

It measures average blocks per minute that are being synchronized for period of 10 minutes and then gives you results
```
wget -O agoric_synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/agoric/agoric_synctime.py && python3 ./agoric_synctime.py
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu agoricd.service
```

Stop agoric service
```
service agoricd stop
```

Start agoric service
```
service agoricd start
```

Restart agoric service
```
service agoricd restart
```

Configuration file
```
vim ~/.agoric/config/config.toml
```

Check consensus state
```
curl -s 127.0.0.1:26657/consensus_state | jq .result.round_state.height_vote_set[0].prevotes_bit_array
```

Check voting status
```
curl -s http://localhost:26657/dump_consensus_state | jq '.result.round_state.votes[0].prevotes' | grep $(curl -s http://localhost:26657/status | jq -r '.result.validator_info.address[:12]')
```

Check connected peers
```
curl -sS http://localhost:26657/net_info | jq -r '.result.peers[] | "\(.node_info.moniker)"' | wc -l
```

### Node info
Synchronization info
```
ag0 status 2>&1 | jq .SyncInfo
```

Validator info
```
ag0 status 2>&1 | jq .ValidatorInfo
```

Node info
```
ag0 status 2>&1 | jq .NodeInfo
```

Show node id
```
ag0 tendermint show-node-id
```

### Wallet operations
Send funds
```
ag0 tx bank send <address1> <address2> 5000000ubld
```

Recover wallet
```
ag0 keys add agoric-wallet --recover
```

Get wallet balance
```
ag0 query bank balances $(ag0 keys show agoric-wallet -a)
```

List of wallets
```
ag0 keys list
```

Delete wallet
```
ag0 keys delete agoric-wallet
```

### Configruation reset
Reset configs
```
ag0 unsafe-reset-all
```

### Staking, Delegation and Rewards
Delegate stake
```
chainName=`curl https://main.agoric.net/network-config | jq -r .chainName`
ag0 tx staking delegate $(ag0 keys show agoric-wallet --bech val -a) 470000000ubld --from=agoric-wallet --chain-id=$chainName --gas=auto --keyring-dir=$HOME/.agoric
```

Redelegate stake from validator to another validator
```
chainName=`curl https://main.agoric.net/network-config | jq -r .chainName`
ag0 tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 5000000ubld --from=agoric-wallet --chain-id=$chainName --gas=auto --keyring-dir=$HOME/.agoric
```

Withdraw rewards
```
chainName=`curl https://main.agoric.net/network-config | jq -r .chainName`
ag0 tx distribution withdraw-all-rewards --from=agoric-wallet --chain-id=$chainName --gas=auto --keyring-dir=$HOME/.agoric
```

### Agoric SDK update
```
sudo systemctl stop agoricd
cd $HOME
rm -rf ag0
git clone https://github.com/Agoric/ag0.git
cd ag0
git pull origin
git checkout agoric-upgrade-5
make install
make build
. $HOME/.bash_profile
cp $HOME/ag0/build/ag0 /usr/local/bin
ag0 version
# HEAD-a2a0dc089ca98b9eae50802d8ed866bf8c209b06
systemctl restart agoricd.service
# check logs
journalctl -u agoricd -f -n 100
```

### Migrate Agoric validator to another VPS
1. First of all you have to backup your configuration files on your old validator node located in `~/.agoric/config/`
2. Set up new VPS
3. Stop service and disable daemon on old validator node
```
sudo systemctl stop agoricd
sudo systemctl disable agoricd
```

_(Be sure that your ag-chain-cosmos is not running on the old machine. If it is, you will be slashed for double-signing.)_

4. Use guide for validator node setup - [Validator Guide for Incentivized Testnet](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Incentivized-Testnet)
>When you reach step [Syncing Your Node](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Incentivized-Testnet#syncing-your-node) you have to copy and replace configuration files located in `~/.agoric/config/` with those we saved in step 1
5. Finish setup by synchronizing your node with network
6. After your node catch up you have to restore your key. For that you will need 24-word mnemonic you saved on key creation
>To recover your key follow this guide - [How do I recover a key?](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Devnet#how-do-i-recover-a-key)
7. Make sure your validator is not jailed
>To unjail use this guide - [How do I unjail my validator?](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide#how-do-i-unjail-my-validator)
8. After you ensure your validator is producing blocks in explorer and is healthy you can shut down old validator server

## Security

### Use public keys for SSH authentication 
```
# /etc/ssh/sshd_config
AuthenticationMethods publickey
PasswordAuthentication no
PermitRootLogin prohibit-password
```

```
systemctl restart sshd.service
```

### Basic Firewall security

Start by checking the status of ufw.
```
sudo ufw status
```

Sets the default to allow outgoing connections, deny all incoming except ssh and 26656. Limit SSH login attempts
```
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 26656
sudo ufw enable
```

## Monitoring
## Monitoring node
Install docker
```
apt update
apt upgrade -y
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install   apt-transport-https   ca-certificates   curl   gnupg   lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Install docker compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

Clone the node_tooling repo and decend into the monitoring folder:
```
git clone https://github.com/Xiphiar/node_tooling.git
cd ./node_tooling/monitoring
```

In the prometheus folder, modify cosmos.yaml, replace NODE_IP with the IP of your node
```
nano ./prometheus/cosmos.yaml
```

Replace the default prometheus config with the modified cosmos.yaml
```
mv ./prometheus/prometheus.yml ./prometheus/prometheus.yml.orig
cp ./prometheus/cosmos.yaml ./prometheus/prometheus.yml
```

Start the contrainers deploying the monitoring stack (Grafana + Prometheus + Node Exporter):
```
docker-compose --profile monitor up -d
```

### Setup cosmos-exporter
First of all, you need to download the latest release from the [releases page](https://github.com/solarlabsteam/cosmos-exporter/releases/)
```
wget https://github.com/solarlabsteam/cosmos-exporter/releases/download/v0.2.2/cosmos-exporter_0.2.2_Linux_x86_64.tar.gz
tar xvfz cosmos-exporter*
sudo cp ./cosmos-exporter /usr/bin
rm cosmos-exporter* -rf
```

Create user for service
```
sudo useradd -rs /bin/false cosmos_exporter
```

Run as service
```
sudo tee <<EOF >/dev/null /etc/systemd/system/cosmos-exporter.service
[Unit]
Description=Cosmos Exporter
After=network-online.target

[Service]
User=cosmos_exporter
Group=cosmos_exporter
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=cosmos-exporter --denom BLD --denom-coefficient 1000000 --bech-prefix agoric
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
```

Add service to autostart
```
sudo systemctl enable cosmos-exporter
sudo systemctl start cosmos-exporter
sudo systemctl status cosmos-exporter
```

Allow 9500 cosmos-exporter port
```
sudo ufw allow 9500
```

See logs
```
sudo journalctl -u cosmos-exporter -f --output cat
```

### Setup node-exporter
get latest release of node-exporter -> https://github.com/prometheus/node_exporter/releases
```
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/
rm node_exporter-* -rf

sudo useradd -rs /bin/false node_exporter

sudo tee <<EOF >/dev/null /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
```

allow 9300 node-exporter port
```
sudo ufw allow 9300
```
