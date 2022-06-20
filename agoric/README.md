<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/167032367-fee4380e-7678-43e0-9206-36d72b32b8ae.png">
</p>

# agoric node setup for devnet — agoricdev-11

Official documentation:
> [Validator Guide for Devnet](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Devnet)

Explorer:
> https://devnet.explorer.agoric.net/

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for agoric validator](https://github.com/kj89/testnet_manuals/blob/main/agoric/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/agoric/migrate_validator.md)

## Set up your agoric fullnode
### Option 1 (automatic)
You can setup your agoric fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O agoric_devnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/agoric/agoric_devnet.sh && chmod +x agoric_devnet.sh && ./agoric_devnet.sh
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
agd status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
agd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
agd keys add $WALLET --recover
```

To get current list of wallets
```
agd keys list
```

### Save wallet info
Add wallet address
```
WALLET_ADDRESS=$(agd keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(agd keys show $WALLET --bech val -a)
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
agd query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
agd tx staking create-validator \
  --amount 1000000ubld \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(agd show-validator) \
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
sudo ufw allow 26656,26660,26657,1317/tcp
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
journalctl -fu agd -o cat
```

Start service
```
systemctl start agd
```

Stop service
```
systemctl stop agd
```

Restart service
```
systemctl restart agd
```

### Node info
Synchronization info
```
agd status 2>&1 | jq .SyncInfo
```

Validator info
```
agd status 2>&1 | jq .ValidatorInfo
```

Node info
```
agd status 2>&1 | jq .NodeInfo
```

Show node id
```
agd show-node-id
```

### Wallet operations
List of wallets
```
agd keys list
```

Recover wallet
```
agd keys add $WALLET --recover
```

Delete wallet
```
agd keys delete $WALLET
```

Get wallet balance
```
agd query bank balances $WALLET_ADDRESS
```

Transfer funds
```
agd tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000ubld
```

### Voting
```
agd tx gov vote 1 yes --from $WALLET --chain-id=$CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
agd tx staking delegate $VALOPER_ADDRESS 10000000ubld --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
agd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ubld --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
agd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
agd tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
agd tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
agd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
systemctl stop agd
systemctl disable agd
rm /etc/systemd/system/agd.service -rf
rm $(which agd) -rf
rm $HOME/.agoric* -rf
rm $HOME/agoric-sdk -rf
```
