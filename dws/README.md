<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/166676803-ee125d04-dfe2-4c92-8f0c-8af357aad691.png">
</p>

# DWS node setup for Testnet — deweb-testnet-1

Official documentation:
>- [Validator setup instructions](https://docs.deweb.services/guides/validator-setup-guide)

Explorer:
>-  https://dws.explorers.guru/

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for DWS validator](https://github.com/kj89/testnet_manuals/blob/main/dws/monitoring/README.md)
>
> To migrate your valitorator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/dws/migrate_validator.md)

## Set up your dws fullnode
### Option 1 (automatic)
You can setup your dws fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O dws.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/dws/dws.sh && chmod +x dws.sh && ./dws.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/dws/manual_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
dewebd status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
dewebd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
dewebd keys add $WALLET --recover
```

To get current list of wallets
```
dewebd keys list
```

### Save wallet info
Add wallet address
```
WALLET_ADDRESS=$(dewebd keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(dewebd keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
To top up your wallet join DWS discord server and navigate to:
- **#faucet** for DWS tokens

To request a faucet grant:
```
$request <YOUR_WALLET_ADDRESS> menkar
```

### Create validator
Before creating validator please make sure that you have at least 1 dws (1 dws is equal to 1000000 udws) and your node is synchronized

To check your wallet balance:
```
dewebd query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
dewebd tx staking create-validator \
  --amount 1000000udws \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(dewebd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID \
  --gas auto \
  --gas-adjustment 1.5 \
  --gas-prices 0.001udws
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
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for dws validator](https://github.com/kj89/testnet_manuals/blob/main/dws/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/dws/tools/synctime.py && python3 ./synctime.py
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:26657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu dewebd -o cat
```

Start service
```
systemctl start dewebd
```

Stop service
```
systemctl stop dewebd
```

Restart service
```
systemctl restart dewebd
```

### Node info
Synchronization info
```
dewebd status 2>&1 | jq .SyncInfo
```

Validator info
```
dewebd status 2>&1 | jq .ValidatorInfo
```

Node info
```
dewebd status 2>&1 | jq .NodeInfo
```

Show node id
```
dewebd tendermint show-node-id
```

### Wallet operations
List of wallets
```
dewebd keys list
```

Recover wallet
```
dewebd keys add $WALLET --recover
```

Delete wallet
```
dewebd keys delete $WALLET
```

Get wallet balance
```
dewebd query bank balances $WALLET_ADDRESS
```

Transfer funds
```
dewebd tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000udws
```

### Staking, Delegation and Rewards
Delegate stake
```
dewebd tx staking delegate $VALOPER_ADDRESS 10000000udws --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --fees=200udws
```

Redelegate stake from validator to another validator
```
dewebd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000udws --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --fees=200udws
```

Withdraw all rewards
```
dewebd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto --fees=200udws
```

Withdraw rewards with commision
```
dewebd tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
dewebd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=1C5ACD2EEF363C3A \
  --website="http://kjnodes.com" \
  --details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
  --chain-id=$CHAIN_ID \
  --from=$WALLET \
  --fees=200udws
```

Unjail validator
```
dewebd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto \
  --fees=200udws
```
