<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
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
wget -O agoric_mainnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/agoric/mainnet/agoric_mainnet.sh && chmod +x agoric_mainnet.sh && ./agoric_mainnet.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/agoric/manual_devnet_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
ag0 status 2>&1 | jq .SyncInfo
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
WALLET_ADDRESS=$(ag0 keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(ag0 keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Top up your wallet balance using faucet
To get free tokens in agoricdev-11 testnet:
* navigate to [Agoric official discord](https://agoric.com/discord)
* open `#faucet` channel under `DEVELOPMENT` category 
* input command: `!faucet client <WALLET_ADDRESS>`

### Create validator
Before creating validator please make sure that you have at least 1 bld (1 bld is equal to 1000000 ubld) and your node is synchronized

To check your wallet balance:
```
ag0 query bank balances $WALLET_ADDRESS
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
  --chain-id $CHAIN_ID
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
curl -sS http://localhost:26657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
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
ag0 query bank balances $WALLET_ADDRESS
```

Transfer funds
```
ag0 tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000ubld
```

### Voting
```
ag0 tx gov vote 1 yes --from $WALLET --chain-id=$CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
ag0 tx staking delegate $VALOPER_ADDRESS 10000000ubld --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
ag0 tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ubld --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
ag0 tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
ag0 tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
ag0 tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
ag0 tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
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
