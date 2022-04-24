<p align="center">
  <img width="150" height="auto" src="https://user-images.githubusercontent.com/50621007/164164767-0a9590e5-b018-44de-8a3e-4ebdd905dfbc.png">
</p>

# defund node setup for Incentivized Testnet — Torii-1
All information about testnet incentives and challenges you can find [here](https://philabs.notion.site/philabs/defund-Incentivized-Testnet-Torii-1-9e70a8f431c041618c6932e70d46ccdd)

Official documentation:
>- https://docs.defund.io/docs/validator/running-a-validator-node
>- https://philabs.notion.site/Validator-Setup-Guide-10502472842e4ad8bf7fb7ec68afe07a

## Usefull tools I have created for defund
> To generate gentx for torii-1 testnet please navigate to [Generate gentx for torii-1 incentivized testnet](https://github.com/kj89/testnet_manuals/blob/main/defund/gentx/README.md)
>
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for defund validator](https://github.com/kj89/testnet_manuals/blob/main/defund/monitoring/README.md)

## Set up your defund fullnode
You can setup your defund fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O defund.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/defund/defund.sh && chmod +x defund.sh && ./defund.sh
```

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
defundd status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
defundd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
defundd keys add $WALLET --recover
```

To get current list of wallets
```
defundd keys list
```

### Save wallet info
Add wallet address
```
WALLET_ADDRESS=$(defundd keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(defundd keys show $WALLET --bech val -a)
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
* navigate to https://stakely.io/en/faucet/defund-testnet
* input your wallet address and click verify
* then press tweet button and wait for faucet to process your tweet
> Please note: to mitigate against spam accounts, the Stakely faucet will discard requests from users with Twitter accounts with very little activity or that are too new!

2. Get 3 torii using your twitter account
* navigate to https://faucet.torii-1.defund.tech/ui/
* input your wallet address and click `Get Fund`

### Create validator
Before creating validator please make sure that you have at least 1 torii (1 torii is equal to 1000000 utorii) and your node is synchronized

To check your wallet balance:
```
defundd query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
defundd tx staking create-validator \
  --amount 1000000utorii \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(defundd tendermint show-validator) \
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
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for defund validator](https://github.com/kj89/testnet_manuals/blob/main/defund/monitoring/README.md)

## Usefull commands
### Service management
Check logs
```
journalctl -fu defundd -o cat
```

Start service
```
systemctl start defundd
```

Stop service
```
systemctl stop defundd
```

Restart service
```
systemctl restart defundd
```

### Node info
Synchronization info
```
defundd status 2>&1 | jq .SyncInfo
```

Validator info
```
defundd status 2>&1 | jq .ValidatorInfo
```

Node info
```
defundd status 2>&1 | jq .NodeInfo
```

Show node id
```
defundd tendermint show-node-id
```

### Wallet operations
List of wallets
```
defundd keys list
```

Recover wallet
```
defundd keys add $WALLET --recover
```

Delete wallet
```
defundd keys delete $WALLET
```

Get wallet balance
```
defundd query bank balances $WALLET_ADDRESS
```

Transfer funds
```
defundd tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000utorii
```

### Staking, Delegation and Rewards
Delegate stake
```
defundd tx staking delegate $VALOPER_ADDRESS 10000000utorii --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
defundd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utorii --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
defundd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
defundd tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
defundd tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
defundd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto
```
