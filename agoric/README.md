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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/167032367-fee4380e-7678-43e0-9206-36d72b32b8ae.png">
</p>

# agoric node setup for mainnet — agoric-3


Explorer:
> https://agoric.explorers.guru

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for agoric validator](https://github.com/kj89/testnet_manuals/blob/main/agoric/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/agoric/migrate_validator.md)

## Set up your agoric fullnode
### Option 1 (automatic)
You can setup your agoric fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O agoric.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/agoric/agoric.sh && chmod +x agoric.sh && ./agoric.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/agoric/manual_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
ag0 status 2>&1 | jq .SyncInfo
```

### (OPTIONAL) Restore using snapshot provided by polkachu
```
json=$(curl -qs --request GET --get "https://polkachu.com/api/v1/chains/agoric/snapshot" --header "Content-Type: application/json" --header "Accept: application/json")
snapshot_url=$(echo $json | jq -r .snapshot.url)
snapshot_name=$(echo $json | jq -r .snapshot.name)
snapshot_block=$(echo $json | jq -r .snapshot.block_height)
echo -e "\e[1m\e[32mDownloading $snapshot_name (block height: $snapshot_block) from $snapshot_url...\e[0m"
wget -O $snapshot_name $snapshot_url
sudo systemctl stop agoricd
ag0 tendermint unsafe-reset-all --home $HOME/.agoric
lz4 -c -d $snapshot_name  | tar -x -C $HOME/.agoric
rm -v $snapshot_name
sudo systemctl start agoricd
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
ag0 keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
ag0 keys add $WALLET --recover
```

To get current list of wallets
```
ag0 keys list
```

### Save wallet info
Add wallet address
```
AGORIC_WALLET_ADDRESS=$(ag0 keys show $WALLET -a)
```

Add valoper address
```
AGORIC_VALOPER_ADDRESS=$(ag0 keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export AGORIC_WALLET_ADDRESS='${AGORIC_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export AGORIC_VALOPER_ADDRESS='${AGORIC_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 bld (1 bld is equal to 1000000 ubld) and your node is synchronized

To check your wallet balance:
```
ag0 query bank balances $AGORIC_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
ag0 tx staking create-validator \
  --amount 1000000ubld \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(ag0 show-validator) \
  --moniker $NODENAME \
  --chain-id $AGORIC_CHAIN_ID
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
sudo ufw allow 26656,26660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for agoric validator](https://github.com/kj89/testnet_manuals/blob/main/agoric/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/agoric/tools/synctime.py && python3 ./synctime.py
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${AGORIC_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu ag0 -o cat
```

Start service
```
systemctl start ag0
```

Stop service
```
systemctl stop ag0
```

Restart service
```
systemctl restart ag0
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
ag0 show-node-id
```

### Wallet operations
List of wallets
```
ag0 keys list
```

Recover wallet
```
ag0 keys add $WALLET --recover
```

Delete wallet
```
ag0 keys delete $WALLET
```

Get wallet balance
```
ag0 query bank balances $AGORIC_WALLET_ADDRESS
```

Transfer funds
```
ag0 tx bank send $AGORIC_WALLET_ADDRESS <TO_AGORIC_WALLET_ADDRESS> 10000000ubld
```

### Voting
```
ag0 tx gov vote 1 yes --from $WALLET --chain-id=$AGORIC_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
ag0 tx staking delegate $AGORIC_VALOPER_ADDRESS 10000000ubld --from=$WALLET --chain-id=$AGORIC_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
ag0 tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ubld --from=$WALLET --chain-id=$AGORIC_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
ag0 tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$AGORIC_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
ag0 tx distribution withdraw-rewards $AGORIC_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$AGORIC_CHAIN_ID
```

### Validator management
Edit validator
```
ag0 tx staking edit-validator \
--moniker=$NODENAME \
--identity=<your_keybase_id> \
--website="<your_website>" \
--details="<your_validator_description>" \
--chain-id=$AGORIC_CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
ag0 tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$AGORIC_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
systemctl stop ag0
systemctl disable ag0
rm /etc/systemd/system/ag0.service -rf
rm $(which ag0) -rf
rm $HOME/.agoric* -rf
rm $HOME/ag0 -rf
```
