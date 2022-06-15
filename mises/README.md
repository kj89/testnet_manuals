<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://www.mises.site/static/images/index/logo@2x.png">
</p>

# mises node setup for Testnet — mainnet

Official documentation:
> [Validator setup instructions](https://github.com/mises-id/mises-tm)
> [Discord](https://discord.gg/fkneTvDE) | [Telegram](https://t.me/Misesofficial)

## Usefull tools I have created for mises
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for mises validator](https://github.com/kj89/testnet_manuals/blob/main/mises/monitoring/README.md)

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 40GB Disk (we are using statesync, so disk requirements are low)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Set up your mises fullnode
### Option 1 (automatic)
You can setup your mises fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O mises.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/mises/mises.sh && chmod +x mises.sh && ./mises.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/mises/manual_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
misestmd status 2>&1 | jq .SyncInfo
```

To check logs
```
journalctl -u misestmd -f -o cat
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
misestmd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
misestmd keys add $WALLET --recover
```

To get current list of wallets
```
misestmd keys list
```

### Save wallet info
Add wallet address
```
WALLET_ADDRESS=$(misestmd keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(misestmd keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
N/A

### Create validator
Before creating validator please make sure that you have at least 1 mis (1 mis is equal to 1000000 umis) and your node is synchronized

To check your wallet balance:
```
misestmd query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
misestmd tx staking create-validator \
  --amount 1000000umis \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(misestmd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID
```

### Get list of validators
```
misestmd q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
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
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for mises validator](https://github.com/kj89/testnet_manuals/blob/main/mises/monitoring/README.md)

## Usefull commands
### Service management
Check logs
```
journalctl -fu misestmd -o cat
```

Start service
```
systemctl start misestmd
```

Stop service
```
systemctl stop misestmd
```

Restart service
```
systemctl restart misestmd
```

### Node info
Synchronization info
```
misestmd status 2>&1 | jq .SyncInfo
```

Validator info
```
misestmd status 2>&1 | jq .ValidatorInfo
```

Node info
```
misestmd status 2>&1 | jq .NodeInfo
```

Show node id
```
misestmd tendermint show-node-id
```

### Wallet operations
List of wallets
```
misestmd keys list
```

Recover wallet
```
misestmd keys add $WALLET --recover
```

Delete wallet
```
misestmd keys delete $WALLET
```

Get wallet balance
```
misestmd query bank balances $WALLET_ADDRESS
```

Transfer funds
```
misestmd tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000umis
```

### Staking, Delegation and Rewards
Delegate stake
```
misestmd tx staking delegate $VALOPER_ADDRESS 10000000umis --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --gas-adjustment 1.4
```

Redelegate stake from validator to another validator
```
misestmd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000umis --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --gas-adjustment 1.4
```

Withdraw all rewards
```
misestmd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --gas-adjustment 1.4
```

Withdraw rewards with commision
```
misestmd tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
misestmd tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
misestmd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto --gas-adjustment 1.4
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
systemctl stop misestmd
systemctl disable misestmd
rm /etc/systemd/system/mises* -rf
rm $(which misestmd) -rf
rm $HOME/.mises* -rf
rm $HOME/mises-tm -rf
```
