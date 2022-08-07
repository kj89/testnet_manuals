<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/fRVzvPBh" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/181202199-ec65c529-8f92-4083-9841-77e48e47ba03.png">
</p>

# juno node setup for testnet — uni-3

Official documentation:
>- [Validator setup instructions](https://github.com/juno-Labs/testnet)

Explorer:
>-  https://testnet.juno.explorers.guru/

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for juno validator](https://github.com/kj89/testnet_manuals/blob/main/juno/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/juno/migrate_validator.md)

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

## Set up your juno fullnode
### Option 1 (automatic)
You can setup your juno fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O juno.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/juno/juno.sh && chmod +x juno.sh && ./juno.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/juno/manual_install.md) if you better prefer setting up node manually

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
junod status 2>&1 | jq .SyncInfo
```

### (OPTIONAL) Disable and cleanup indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.juno/config/config.toml
sudo systemctl restart junod
sleep 3
sudo rm -rf $HOME/.juno/data/tx_index.db
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
junod keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
junod keys add $WALLET --recover
```

To get current list of wallets
```
junod keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
JUNO_WALLET_ADDRESS=$(junod keys show $WALLET -a)
JUNO_VALOPER_ADDRESS=$(junod keys show $WALLET --bech val -a)
echo 'export JUNO_WALLET_ADDRESS='${JUNO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export JUNO_VALOPER_ADDRESS='${JUNO_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
To top up your wallet join [juno discord server](https://discord.gg/8F59kZfw) and navigate to:
- **#faucet** to request test tokens

To request a faucet grant:
```
$request <YOUR_WALLET_ADDRESS>
```

### Create validator
Before creating validator please make sure that you have at least 1 junox (1 junox is equal to 1000000 ujunox) and your node is synchronized

To check your wallet balance:
```
junod query bank balances $JUNO_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
junod tx staking create-validator \
  --amount 10000000ujunox \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(junod tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $JUNO_CHAIN_ID
```

## Operations with liquid stake
### Add liquid stake 
Liquid stake your ATOM on juno for stATOM. Here's an example of how to liquid stake
```
junod tx stakeibc liquid-stake 1000 uatom --from $WALLET --chain-id $JUNO_CHAIN_ID
```
> Note: if you liquid stake 1000 uatom, you might only get 990 (could be more or less) stATOM in return! This is due to the way our exchange rate works. Your 990 stATOM are still worth 1000 uatom (or more, as you accrue staking rewards!)

### Redeem stake
After accruing some staking rewards, you can unstake your tokens. Currently, the unbonding period on our Gaia (Cosmos Hub) testnet is around 30 minutes.
```
junod tx stakeibc redeem-stake 999 GAIA <cosmos_address_you_want_to_redeem_to> --chain-id $JUNO_CHAIN_ID --from $WALLET
```

### Check if tokens are claimable
If you'd like to see whether your tokens are ready to be claimed, look for your `UserRedemptionRecord` keyed by `<your_JUNO_account>`. 
```
junod q records list-user-redemption-record --output json | jq --arg WALLET_ADDRESS "$JUNO_WALLET_ADDRESS" '.UserRedemptionRecord | map(select(.sender == $WALLET_ADDRESS))'
```
If your record has the attribute `isClaimable=true`, they're ready to be claimed!

### Claim tokens
After your tokens have unbonded, they can be claimed by triggering the claim process. 
```
junod tx stakeibc claim-undelegated-tokens GAIA 5 --chain-id $JUNO_CHAIN_ID --from $WALLET
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
sudo ufw allow ${JUNO_PORT}656,${JUNO_PORT}660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for juno validator](https://github.com/kj89/testnet_manuals/blob/main/juno/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/juno/tools/synctime.py && python3 ./synctime.py
```

### Check your validator key
```
[[ $(junod q staking validator $JUNO_VALOPER_ADDRESS -oj | jq -r .consensus_pubkey.key) = $(junod status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Get list of validators
```
junod q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${JUNO_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu junod -o cat
```

Start service
```
sudo systemctl start junod
```

Stop service
```
sudo systemctl stop junod
```

Restart service
```
sudo systemctl restart junod
```

### Node info
Synchronization info
```
junod status 2>&1 | jq .SyncInfo
```

Validator info
```
junod status 2>&1 | jq .ValidatorInfo
```

Node info
```
junod status 2>&1 | jq .NodeInfo
```

Show node id
```
junod tendermint show-node-id
```

### Wallet operations
List of wallets
```
junod keys list
```

Recover wallet
```
junod keys add $WALLET --recover
```

Delete wallet
```
junod keys delete $WALLET
```

Get wallet balance
```
junod query bank balances $JUNO_WALLET_ADDRESS
```

Transfer funds
```
junod tx bank send $JUNO_WALLET_ADDRESS <TO_JUNO_WALLET_ADDRESS> 10000000ujunox
```

### Voting
```
junod tx gov vote 1 yes --from $WALLET --chain-id=$JUNO_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
junod tx staking delegate $JUNO_VALOPER_ADDRESS 10000000ujunox --from=$WALLET --chain-id=$JUNO_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
junod tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ujunox --from=$WALLET --chain-id=$JUNO_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
junod tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$JUNO_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
junod tx distribution withdraw-rewards $JUNO_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$JUNO_CHAIN_ID
```

### Validator management
Edit validator
```
junod tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$JUNO_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
junod tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$JUNO_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop junod
sudo systemctl disable junod
sudo rm /etc/systemd/system/juno* -rf
sudo rm $(which junod) -rf
sudo rm $HOME/.juno* -rf
sudo rm $HOME/juno -rf
sed -i '/JUNO_/d' ~/.bash_profile
```
