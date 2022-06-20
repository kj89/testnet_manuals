<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/164164767-0a9590e5-b018-44de-8a3e-4ebdd905dfbc.png">
</p>

# Archway node setup for Incentivized Testnet — Torii-1
All information about testnet incentives and challenges you can find [here](https://philabs.notion.site/philabs/Archway-Incentivized-Testnet-Torii-1-9e70a8f431c041618c6932e70d46ccdd)

Official documentation:
>- https://docs.archway.io/docs/validator/running-a-validator-node
>- https://philabs.notion.site/Validator-Setup-Guide-10502472842e4ad8bf7fb7ec68afe07a

## Usefull tools and references
> To generate gentx for torii-1 testnet please navigate to [Generate gentx for torii-1 incentivized testnet](https://github.com/kj89/testnet_manuals/blob/main/archway/gentx/README.md)
>
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for Archway validator](https://github.com/kj89/testnet_manuals/blob/main/archway/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/archway/migrate_validator.md)

## Set up your archway fullnode
### Option 1 (automatic)
You can setup your archway fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O archway.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/archway.sh && chmod +x archway.sh && ./archway.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/archway/manual_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
archwayd status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
archwayd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
archwayd keys add $WALLET --recover
```

To get current list of wallets
```
archwayd keys list
```

### Save wallet info
Add wallet address
```
WALLET_ADDRESS=$(archwayd keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(archwayd keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Top up your wallet balance using faucet
Currently there are two options of getting tokens in torii-1 testnet

1. Get 3 torii using your twitter account
* navigate to https://stakely.io/en/faucet/archway-testnet
* input your wallet address and click verify
* then press tweet button and wait for faucet to process your tweet
> Please note: to mitigate against spam accounts, the Stakely faucet will discard requests from users with Twitter accounts with very little activity or that are too new!

2. Get 3 torii using your twitter account
* navigate to https://faucet.torii-1.archway.tech/ui/
* input your wallet address and click `Get Fund`

### Create validator
Before creating validator please make sure that you have at least 1 torii (1 torii is equal to 1000000 utorii) and your node is synchronized

To check your wallet balance:
```
archwayd query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
archwayd tx staking create-validator \
  --amount 1000000utorii \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(archwayd tendermint show-validator) \
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
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for Archway validator](https://github.com/kj89/testnet_manuals/blob/main/archway/monitoring/README.md)

## Usefull commands
### Service management
Check logs
```
journalctl -fu archwayd -o cat
```

Start service
```
systemctl start archwayd
```

Stop service
```
systemctl stop archwayd
```

Restart service
```
systemctl restart archwayd
```

### Node info
Synchronization info
```
archwayd status 2>&1 | jq .SyncInfo
```

Validator info
```
archwayd status 2>&1 | jq .ValidatorInfo
```

Node info
```
archwayd status 2>&1 | jq .NodeInfo
```

Show node id
```
archwayd tendermint show-node-id
```

### Wallet operations
List of wallets
```
archwayd keys list
```

Recover wallet
```
archwayd keys add $WALLET --recover
```

Delete wallet
```
archwayd keys delete $WALLET
```

Get wallet balance
```
archwayd query bank balances $WALLET_ADDRESS
```

Transfer funds
```
archwayd tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000utorii
```

### Staking, Delegation and Rewards
Delegate stake
```
archwayd tx staking delegate $VALOPER_ADDRESS 10000000utorii --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
archwayd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utorii --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
archwayd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
archwayd tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
archwayd tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
archwayd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
systemctl stop archwayd
systemctl disable archwayd
rm /etc/systemd/system/archway* -rf
rm $(which archwayd) -rf
rm $HOME/.archway* -rf
rm $HOME/archway -rf
```
