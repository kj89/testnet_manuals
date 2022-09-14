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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/177979901-4ac785e2-08c3-4d61-83df-b451a2ed9e68.png">
</p>

# aura node setup for testnet — euphoria-1

Official documentation:
>- [Validator setup instructions](https://docs.aura.app/run-a-node)

Explorer:
>- https://euphoria.aurascan.io/validators

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for aura validator](https://github.com/kj89/testnet_manuals/blob/main/aura/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/aura/migrate_validator.md)

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.

### Minimum Hardware Requirements
 - 3x CPUs; the faster clock speed the better
 - 4GB RAM
 - 80GB Disk
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

### Recommended Hardware Requirements 
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 200GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Set up your aura fullnode
### Option 1 (automatic)
You can setup your aura fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O aura.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aura/aura.sh && chmod +x aura.sh && ./aura.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/aura/manual_install.md) if you better prefer setting up node manually

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
aurad status 2>&1 | jq .SyncInfo
```

### (OPTIONAL) Disable and cleanup indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.aura/config/config.toml
sudo systemctl restart aurad
sleep 3
sudo rm -rf $HOME/.aura/data/tx_index.db
```

### (OPTIONAL) State Sync
You can state sync your node in minutes by running commands below.
```
SNAP_RPC1="https://snapshot-1.euphoria.aura.network:443" \
&& SNAP_RPC2="https://snapshot-1.euphoria.aura.network:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC2/block | jq -r .result.block.header.height) \
&& BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)) \
&& TRUST_HASH=$(curl -s "$SNAP_RPC2/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC1,$SNAP_RPC2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.aura/config/config.toml
aurad tendermint unsafe-reset-all --home $HOME/.aura
sudo systemctl restart aurad && journalctl -fu aurad -o cat
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
aurad keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
aurad keys add $WALLET --recover
```

To get current list of wallets
```
aurad keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
AURA_WALLET_ADDRESS=$(aurad keys show $WALLET -a)
```
```
AURA_VALOPER_ADDRESS=$(aurad keys show $WALLET --bech val -a)
```
Load variables into the system
```
echo 'export AURA_WALLET_ADDRESS='${AURA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export AURA_VALOPER_ADDRESS='${AURA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 kuji (1 kuji is equal to 1000000 ueaura) and your node is synchronized

To check your wallet balance:
```
aurad query bank balances $AURA_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
aurad tx staking create-validator \
  --amount 100000ueaura \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(aurad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $AURA_CHAIN_ID
```

## Security
To protect you keys please make sure you follow basic security rules

### Set up ssh keys for authentication
Good tutorial on how to set up ssh keys for authentication to your server can be found [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-20-04)

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
sudo ufw allow ${AURA_PORT}656,${AURA_PORT}660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for aura validator](https://github.com/kj89/testnet_manuals/blob/main/aura/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/aura/tools/synctime.py && python3 ./synctime.py
```

### Get list of validators
```
aurad q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${AURA_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu aurad -o cat
```

Start service
```
sudo systemctl start aurad
```

Stop service
```
sudo systemctl stop aurad
```

Restart service
```
sudo systemctl restart aurad
```

### Node info
Synchronization info
```
aurad status 2>&1 | jq .SyncInfo
```

Validator info
```
aurad status 2>&1 | jq .ValidatorInfo
```

Node info
```
aurad status 2>&1 | jq .NodeInfo
```

Show node id
```
aurad tendermint show-node-id
```

### Wallet operations
List of wallets
```
aurad keys list
```

Recover wallet
```
aurad keys add $WALLET --recover
```

Delete wallet
```
aurad keys delete $WALLET
```

Get wallet balance
```
aurad query bank balances $AURA_WALLET_ADDRESS
```

Transfer funds
```
aurad tx bank send $AURA_WALLET_ADDRESS <TO_AURA_WALLET_ADDRESS> 10000000ueaura
```

### Voting
```
aurad tx gov vote 1 yes --from $WALLET --chain-id=$AURA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
aurad tx staking delegate $AURA_VALOPER_ADDRESS 10000000ueaura --from=$WALLET --chain-id=$AURA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
aurad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ueaura --from=$WALLET --chain-id=$AURA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
aurad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$AURA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
aurad tx distribution withdraw-rewards $AURA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$AURA_CHAIN_ID
```

### Validator management
Edit validator
```
aurad tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$AURA_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
aurad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$AURA_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop aurad
sudo systemctl disable aurad
sudo rm /etc/systemd/system/aura* -rf
sudo rm $(which aurad) -rf
sudo rm $HOME/.aura* -rf
sudo rm $HOME/aura -rf
sed -i '/AURA_/d' ~/.bash_profile
```
