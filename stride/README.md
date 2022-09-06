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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/183283696-d1c4192b-f594-45bb-b589-15a5e57a795c.png">
</p>

# stride node setup for mainnet — stride-1

Official documentation:
>- [Validator setup instructions](https://github.com/Stride-Labs/testnet)

Explorer:
>-  https://stride.explorers.guru

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for stride validator](https://github.com/kj89/testnet_manuals/blob/main/stride/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/stride/migrate_validator.md)

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.

### Minimum Hardware Requirements
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 100GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

### Recommended Hardware Requirements 
 - 8x CPUs; the faster clock speed the better
 - 64GB RAM
 - 1TB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Set up your stride fullnode
### Option 1 (automatic)
You can setup your stride fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O stride.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/stride/stride.sh && chmod +x stride.sh && ./stride.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/stride/manual_install.md) if you better prefer setting up node manually

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
strided status 2>&1 | jq .SyncInfo
```

### (OPTIONAL) State Sync
You can state sync your node in minutes by running commands below
```
N/A
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
strided keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
strided keys add $WALLET --recover
```

To get current list of wallets
```
strided keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
STRIDE_WALLET_ADDRESS=$(strided keys show $WALLET -a)
STRIDE_VALOPER_ADDRESS=$(strided keys show $WALLET --bech val -a)
echo 'export STRIDE_WALLET_ADDRESS='${STRIDE_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export STRIDE_VALOPER_ADDRESS='${STRIDE_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 strd (1 strd is equal to 1000000 ustrd) and your node is synchronized

To check your wallet balance:
```
strided query bank balances $STRIDE_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
strided tx staking create-validator \
  --amount 10000000ustrd \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(strided tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $STRIDE_CHAIN_ID
```

## Operations with liquid stake
### Add liquid stake 
Liquid stake your ATOM on Stride for stATOM. Here's an example of how to liquid stake
```
strided tx stakeibc liquid-stake 1000 uatom --from $WALLET --chain-id $STRIDE_CHAIN_ID
```
> Note: if you liquid stake 1000 uatom, you might only get 990 (could be more or less) stATOM in return! This is due to the way our exchange rate works. Your 990 stATOM are still worth 1000 uatom (or more, as you accrue staking rewards!)

### Redeem stake
After accruing some staking rewards, you can unstake your tokens. Currently, the unbonding period on our Gaia (Cosmos Hub) testnet is around 30 minutes.
```
strided tx stakeibc redeem-stake 1000 GAIA <COSMOS_ADDRESS_YOU_WANT_TO_REDEEM_TO> --chain-id $STRIDE_CHAIN_ID --from $WALLET
```

### Check if tokens are claimable
If you'd like to see whether your tokens are ready to be claimed, look for your `UserRedemptionRecord` keyed by `<your_stride_account>`. 
```
strided q records list-user-redemption-record --limit 10000 --output json | jq --arg WALLET_ADDRESS "$STRIDE_WALLET_ADDRESS" '.UserRedemptionRecord | map(select(.sender == $WALLET_ADDRESS))'
```
If your record has the attribute `isClaimable=true`, they're ready to be claimed!

### Claim tokens
After your tokens have unbonded, they can be claimed by triggering the claim process. 
```
wget -qO claim.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/stride/tools/claim.sh && chmod +x claim.sh
./claim.sh $STRIDE_WALLET_ADDRESS
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
sudo ufw allow ${STRIDE_PORT}656,${STRIDE_PORT}660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for stride validator](https://github.com/kj89/testnet_manuals/blob/main/stride/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/stride/tools/synctime.py && python3 ./synctime.py
```

### Check your validator key
```
[[ $(strided q staking validator $STRIDE_VALOPER_ADDRESS -oj | jq -r .consensus_pubkey.key) = $(strided status | jq -r .ValidatorInfo.PubKey.value) ]] && echo -e "\n\e[1m\e[32mTrue\e[0m\n" || echo -e "\n\e[1m\e[31mFalse\e[0m\n"
```

### Get list of validators
```
strided q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${STRIDE_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu strided -o cat
```

Start service
```
sudo systemctl start strided
```

Stop service
```
sudo systemctl stop strided
```

Restart service
```
sudo systemctl restart strided
```

### Node info
Synchronization info
```
strided status 2>&1 | jq .SyncInfo
```

Validator info
```
strided status 2>&1 | jq .ValidatorInfo
```

Node info
```
strided status 2>&1 | jq .NodeInfo
```

Show node id
```
strided tendermint show-node-id
```

### Wallet operations
List of wallets
```
strided keys list
```

Recover wallet
```
strided keys add $WALLET --recover
```

Delete wallet
```
strided keys delete $WALLET
```

Get wallet balance
```
strided query bank balances $STRIDE_WALLET_ADDRESS
```

Transfer funds
```
strided tx bank send $STRIDE_WALLET_ADDRESS <TO_STRIDE_WALLET_ADDRESS> 10000000ustrd
```

### Voting
```
strided tx gov vote 1 yes --from $WALLET --chain-id=$STRIDE_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
strided tx staking delegate $STRIDE_VALOPER_ADDRESS 10000000ustrd --from=$WALLET --chain-id=$STRIDE_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
strided tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ustrd --from=$WALLET --chain-id=$STRIDE_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
strided tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$STRIDE_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
strided tx distribution withdraw-rewards $STRIDE_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$STRIDE_CHAIN_ID
```

### Validator management
Edit validator
```
strided tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$STRIDE_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
strided tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$STRIDE_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop strided
sudo systemctl disable strided
sudo rm /etc/systemd/system/stride* -rf
sudo rm $(which strided) -rf
sudo rm $HOME/.stride* -rf
sudo rm $HOME/stride -rf
sed -i '/STRIDE_/d' ~/.bash_profile
```

### Pruning for state sync node
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="2000"
pruning_interval="50"
snapshot_interval="2000"
snapshot_keep_recent="5"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"$snapshot_interval\"/" $HOME/.stride/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"$snapshot_keep_recent\"/" $HOME/.stride/config/app.toml
```
