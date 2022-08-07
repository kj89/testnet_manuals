<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/fRVzvPBh" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/183283696-d1c4192b-f594-45bb-b589-15a5e57a795c.png">
</p>

# gaia node setup for testnet — GAIA

Official documentation:
>- [Validator setup instructions](https://github.com/Stride-Labs/testnet)

Explorer:
>- https://poolparty.stride.zone/

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.

### Minimum Hardware Requirements
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 100GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

### Recommended Hardware Requirements 
 - 4x CPUs; the faster clock speed the better
 - 32GB RAM
 - 200GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Set up your gaia fullnode
### Option 1 (automatic)
You can setup your gaia fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O gaia.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/stride/GAIA/gaia.sh && chmod +x gaia.sh && ./gaia.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/stride/GAIA/manual_install.md) if you better prefer setting up node manually

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
gaiad status 2>&1 | jq .SyncInfo
```

### (OPTIONAL) State Sync
You can state sync your node in minutes by running commands below
```
SNAP_RPC1="https://gaia.poolparty.stridenet.co:445" \
&& SNAP_RPC2="https://gaia.poolparty.stridenet.co:445"
LATEST_HEIGHT=$(curl -s $SNAP_RPC2/block | jq -r .result.block.header.height) \
&& BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)) \
&& TRUST_HASH=$(curl -s "$SNAP_RPC2/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC1,$SNAP_RPC2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.gaia/config/config.toml
gaiad tendermint unsafe-reset-all --home $HOME/.gaia
sudo systemctl restart gaiad && journalctl -fu gaiad -o cat
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
gaiad keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
gaiad keys add $WALLET --recover
```

To get current list of wallets
```
gaiad keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
GAIA_WALLET_ADDRESS=$(gaiad keys show $WALLET -a)
GAIA_VALOPER_ADDRESS=$(gaiad keys show $WALLET --bech val -a)
echo 'export GAIA_WALLET_ADDRESS='${GAIA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export GAIA_VALOPER_ADDRESS='${GAIA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
To top up your wallet join [Stride discord server](https://discord.gg/n6KrK77t) and navigate to:
- **#token-faucet** to request test tokens

To request a faucet grant:
```
$faucet-atom:<GAIA_WALLET_ADDRESS>
```

### Create validator
Before creating validator please make sure that you have at least 1 atom (1 atom is equal to 1000000 uatom) and your node is synchronized

To check your wallet balance:
```
gaiad query bank balances $GAIA_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
gaiad tx staking create-validator \
  --amount 1000000uatom \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(gaiad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $GAIA_CHAIN_ID
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
sudo ufw allow ${GAIA_PORT}656,${GAIA_PORT}660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for gaia validator](https://github.com/kj89/testnet_manuals/blob/main/gaia/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/gaia/tools/synctime.py && python3 ./synctime.py
```

### Check your validator key
```
[[ $(gaiad q staking validator $GAIA_VALOPER_ADDRESS -oj | jq -r .consensus_pubkey.key) = $(gaiad status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Get list of validators
```
gaiad q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${GAIA_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu gaiad -o cat
```

Start service
```
sudo systemctl start gaiad
```

Stop service
```
sudo systemctl stop gaiad
```

Restart service
```
sudo systemctl restart gaiad
```

### Node info
Synchronization info
```
gaiad status 2>&1 | jq .SyncInfo
```

Validator info
```
gaiad status 2>&1 | jq .ValidatorInfo
```

Node info
```
gaiad status 2>&1 | jq .NodeInfo
```

Show node id
```
gaiad tendermint show-node-id
```

### Wallet operations
List of wallets
```
gaiad keys list
```

Recover wallet
```
gaiad keys add $WALLET --recover
```

Delete wallet
```
gaiad keys delete $WALLET
```

Get wallet balance
```
gaiad query bank balances $GAIA_WALLET_ADDRESS
```

Transfer funds
```
gaiad tx bank send $GAIA_WALLET_ADDRESS <TO_GAIA_WALLET_ADDRESS> 10000000uatom
```

### Voting
```
gaiad tx gov vote 1 yes --from $WALLET --chain-id=$GAIA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
gaiad tx staking delegate $GAIA_VALOPER_ADDRESS 10000000uatom --from=$WALLET --chain-id=$GAIA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
gaiad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uatom --from=$WALLET --chain-id=$GAIA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
gaiad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$GAIA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
gaiad tx distribution withdraw-rewards $GAIA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$GAIA_CHAIN_ID
```

### Validator management
Edit validator
```
gaiad tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$GAIA_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
gaiad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$GAIA_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop gaiad
sudo systemctl disable gaiad
sudo rm /etc/systemd/system/gaia* -rf
sudo rm $(which gaiad) -rf
sudo rm $HOME/.gaia* -rf
sudo rm $HOME/gaia -rf
sed -i '/GAIA_/d' ~/.bash_profile
```
