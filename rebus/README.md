<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/177221972-75fcf1b3-6e95-44dd-b43e-e32377685af8.png">
</p>

# rebus node setup for mainnet — rebus

Official documentation:
>- [Validator setup instructions](https://github.com/rebus-Labs/testnet)

Explorer:
>-  https://rebus.explorers.guru

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for rebus validator](https://github.com/kj89/testnet_manuals/blob/main/rebus/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/rebus/migrate_validator.md)

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.

### Minimum Hardware Requirements
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 100GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during mainnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

### Recommended Hardware Requirements 
 - 4x CPUs; the faster clock speed the better
 - 32GB RAM
 - 200GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during mainnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Set up your rebus fullnode
### Option 1 (automatic)
You can setup your rebus fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O rebus.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/rebus/rebus.sh && chmod +x rebus.sh && ./rebus.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/rebus/manual_install.md) if you better prefer setting up node manually

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
rebusd status 2>&1 | jq .SyncInfo
```

### (OPTIONAL) Disable and cleanup indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.rebusd/config/config.toml
sudo systemctl restart rebusd
sleep 3
sudo rm -rf $HOME/.rebusd/data/tx_index.db
```

### (OPTIONAL) State Sync
You can state sync your node in minutes by running commands below
```
SNAP_RPC1="rebus-node1.poolparty.rebusdnet.co:26657" \
&& SNAP_RPC2="rebus-node1.poolparty.rebusdnet.co:26657"
LATEST_HEIGHT=$(curl -s $SNAP_RPC2/block | jq -r .result.block.header.height) \
&& BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)) \
&& TRUST_HASH=$(curl -s "$SNAP_RPC2/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC1,$SNAP_RPC2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.rebusd/config/config.toml
rebusd tendermint unsafe-reset-all --home $HOME/.rebusd
sudo systemctl restart rebusd && journalctl -fu rebusd -o cat
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
rebusd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
rebusd keys add $WALLET --recover
```

To get current list of wallets
```
rebusd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
REBUS_WALLET_ADDRESS=$(rebusd keys show $WALLET -a)
REBUS_VALOPER_ADDRESS=$(rebusd keys show $WALLET --bech val -a)
echo 'export REBUS_WALLET_ADDRESS='${REBUS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export REBUS_VALOPER_ADDRESS='${REBUS_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
To top up your wallet join [rebus discord server](https://discord.gg/97qe8u7t) and navigate to:
- **#faucet** to request test tokens

To request a faucet grant:
```
$faucet:<YOUR_WALLET_ADDRESS>
```

To check wallet balance:
```
$balance:<YOUR_WALLET_ADDRESS>
```

### Create validator
Before creating validator please make sure that you have at least 1 strd (1 strd is equal to 1000000 ustrd) and your node is synchronized

To check your wallet balance:
```
rebusd query bank balances $REBUS_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
rebusd tx staking create-validator \
  --amount 10000000ustrd \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(rebusd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $REBUS_CHAIN_ID
```

## Operations with liquid stake
### Add liquid stake 
Liquid stake your ATOM on rebus for stATOM. Here's an example of how to liquid stake
```
rebusd tx stakeibc liquid-stake 1000 uatom --from $WALLET --chain-id $REBUS_CHAIN_ID
```
> Note: if you liquid stake 1000 uatom, you might only get 990 (could be more or less) stATOM in return! This is due to the way our exchange rate works. Your 990 stATOM are still worth 1000 uatom (or more, as you accrue staking rewards!)

### Redeem stake
After accruing some staking rewards, you can unstake your tokens. Currently, the unbonding period on our Gaia (Cosmos Hub) testnet is around 30 minutes.
```
rebusd tx stakeibc redeem-stake 999 GAIA <cosmos_address_you_want_to_redeem_to> --chain-id $REBUS_CHAIN_ID --from $WALLET
```

### Check if tokens are claimable
If you'd like to see whether your tokens are ready to be claimed, look for your `UserRedemptionRecord` keyed by `<your_REBUS_account>`. 
```
rebusd q records list-user-redemption-record --output json | jq --arg WALLET_ADDRESS "$REBUS_WALLET_ADDRESS" '.UserRedemptionRecord | map(select(.sender == $WALLET_ADDRESS))'
```
If your record has the attribute `isClaimable=true`, they're ready to be claimed!

### Claim tokens
After your tokens have unbonded, they can be claimed by triggering the claim process. 
```
rebusd tx stakeibc claim-undelegated-tokens GAIA 5 --chain-id $REBUS_CHAIN_ID --from $WALLET
```
> Note: this function triggers claims in a FIFO queue, meaning if your claim is 20th in line, you'll have process other claims before seeing your tokens appear in your account.

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
sudo ufw allow ${REBUS_PORT}656,${REBUS_PORT}660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for rebus validator](https://github.com/kj89/testnet_manuals/blob/main/rebus/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/rebus/tools/synctime.py && python3 ./synctime.py
```

### Check your validator key
```
[[ $(rebusd q staking validator $REBUS_VALOPER_ADDRESS -oj | jq -r .consensus_pubkey.key) = $(rebusd status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Get list of validators
```
rebusd q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${REBUS_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu rebusd -o cat
```

Start service
```
sudo systemctl start rebusd
```

Stop service
```
sudo systemctl stop rebusd
```

Restart service
```
sudo systemctl restart rebusd
```

### Node info
Synchronization info
```
rebusd status 2>&1 | jq .SyncInfo
```

Validator info
```
rebusd status 2>&1 | jq .ValidatorInfo
```

Node info
```
rebusd status 2>&1 | jq .NodeInfo
```

Show node id
```
rebusd tendermint show-node-id
```

### Wallet operations
List of wallets
```
rebusd keys list
```

Recover wallet
```
rebusd keys add $WALLET --recover
```

Delete wallet
```
rebusd keys delete $WALLET
```

Get wallet balance
```
rebusd query bank balances $REBUS_WALLET_ADDRESS
```

Transfer funds
```
rebusd tx bank send $REBUS_WALLET_ADDRESS <TO_REBUS_WALLET_ADDRESS> 10000000ustrd
```

### Voting
```
rebusd tx gov vote 1 yes --from $WALLET --chain-id=$REBUS_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
rebusd tx staking delegate $REBUS_VALOPER_ADDRESS 10000000ustrd --from=$WALLET --chain-id=$REBUS_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
rebusd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ustrd --from=$WALLET --chain-id=$REBUS_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
rebusd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$REBUS_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
rebusd tx distribution withdraw-rewards $REBUS_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$REBUS_CHAIN_ID
```

### Validator management
Edit validator
```
rebusd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$REBUS_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
rebusd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$REBUS_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop rebusd
sudo systemctl disable rebusd
sudo rm /etc/systemd/system/rebus* -rf
sudo rm $(which rebusd) -rf
sudo rm $HOME/.rebusd* -rf
sudo rm $HOME/rebus -rf
sed -i '/REBUS_/d' ~/.bash_profile
```
