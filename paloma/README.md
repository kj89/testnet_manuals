<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/172488614-7d93b016-5fe4-4a51-99e2-67da5875ab7a.png">
</p>

# Paloma node setup for Testnet — paloma

Official documentation:
>- [Validator setup instructions](https://github.com/palomachain/paloma)

Explorer:
>-  https://paloma.explorers.guru/

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for paloma validator](https://github.com/kj89/testnet_manuals/blob/main/paloma/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/paloma/migrate_validator.md)

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.

### Minimum Hardware Requirements
 - 3x CPUs; the faster clock speed the better
 - 4GB RAM
 - 80GB Disk
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

### Recommended Hardware Requirements 
 - 4x CPUs; the faster clock speed the better
 - 16GB RAM
 - 200GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Set up your paloma fullnode
### Option 1 (automatic)
You can setup your paloma fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O paloma.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/paloma/paloma.sh && chmod +x paloma.sh && ./paloma.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/paloma/manual_install.md) if you better prefer setting up node manually

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
palomad status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
palomad keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
palomad keys add $WALLET --recover
```

To get current list of wallets
```
palomad keys list
```

### Save wallet info
Add wallet and valoper address and load variables into the system
```
PALOMA_WALLET_ADDRESS=$(palomad keys show $WALLET -a)
PALOMA_VALOPER_ADDRESS=$(palomad keys show $WALLET --bech val -a)
echo 'export PALOMA_WALLET_ADDRESS='${PALOMA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export PALOMA_VALOPER_ADDRESS='${PALOMA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
```
JSON=$(jq -n --arg addr "$PALOMA_WALLET_ADDRESS" '{"denom":"ugrain","address":$addr}') && curl -X POST --header "Content-Type: application/json" --data "$JSON" https://backend.faucet.palomaswap.com/claim
```

### Create validator
Before creating validator please make sure that you have at least 1 paloma (1 paloma is equal to 1000000 ugrain) and your node is synchronized

To check your wallet balance:
```
palomad query bank balances $PALOMA_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
palomad tx staking create-validator \
  --amount 1000000ugrain \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(palomad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $PALOMA_CHAIN_ID
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
sudo ufw allow ${PALOMA_PORT}656,${PALOMA_PORT}660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for paloma validator](https://github.com/kj89/testnet_manuals/blob/main/paloma/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/paloma/tools/synctime.py && python3 ./synctime.py
```

### Get list of validators
```
palomad q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${PALOMA_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu palomad -o cat
```

Start service
```
sudo systemctl start palomad
```

Stop service
```
sudo systemctl stop palomad
```

Restart service
```
sudo systemctl restart palomad
```

### Node info
Synchronization info
```
palomad status 2>&1 | jq .SyncInfo
```

Validator info
```
palomad status 2>&1 | jq .ValidatorInfo
```

Node info
```
palomad status 2>&1 | jq .NodeInfo
```

Show node id
```
palomad tendermint show-node-id
```

### Wallet operations
List of wallets
```
palomad keys list
```

Recover wallet
```
palomad keys add $WALLET --recover
```

Delete wallet
```
palomad keys delete $WALLET
```

Get wallet balance
```
palomad query bank balances $PALOMA_WALLET_ADDRESS
```

Transfer funds
```
palomad tx bank send $PALOMA_WALLET_ADDRESS <TO_PALOMA_WALLET_ADDRESS> 10000000ugrain
```

### Voting
```
palomad tx gov vote 1 yes --from $WALLET --chain-id=$PALOMA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
palomad tx staking delegate $PALOMA_VALOPER_ADDRESS 10000000ugrain --from=$WALLET --chain-id=$PALOMA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
palomad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ugrain --from=$WALLET --chain-id=$PALOMA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
palomad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$PALOMA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
palomad tx distribution withdraw-rewards $PALOMA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$PALOMA_CHAIN_ID
```

### Validator management
Edit validator
```
palomad tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=1C5ACD2EEF363C3A \
  --website="http://kjnodes.com" \
  --details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
  --chain-id=$PALOMA_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
palomad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$PALOMA_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop palomad
sudo systemctl disable palomad
sudo rm /etc/systemd/system/paloma* -rf
sudo rm $(which palomad) -rf
sudo rm $HOME/.paloma* -rf
sudo rm $HOME/paloma -rf
```
