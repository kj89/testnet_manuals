<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/165246332-1bb9cb35-edc7-4531-ac84-8479784af471.png">
</p>

# Cosmic-Horizon node setup for Testnet — darkenergy-1 (v0.1)

Official documentation:
>- [Validator setup instructions](https://github.com/cosmic-horizon/testnets/blob/main/darkenergy-1/README.md)

Explorer:
>-  [Nodes Guru Coho Explorer](https://coho.explorers.guru/)

## Cosmic-Horizon fullnode system requirements
Here are the minimal hardware configs required for running a validator/sentry node
- 4 vCPU
- 8 GB RAM
- 200 GB Disk space

## Usefull tools I have created for coho
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for coho validator](https://github.com/kj89/testnet_manuals/blob/main/coho/monitoring/README.md)

## Set up your coho fullnode
### Option 1 (automatic)
You can setup your coho fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O coho_testnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/coho/coho_testnet.sh && chmod +x coho_testnet.sh && ./coho_testnet.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/coho/manual_install.md) if you better prefer setting up node manually

## Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
cohod status 2>&1 | jq .SyncInfo
```

To check logs
```
journalctl -u cohod -f -o cat
```

## Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
cohod keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
cohod keys add $WALLET --recover
```

To get current list of wallets
```
cohod keys list
```

## Save wallet info
Add wallet address
```
WALLET_ADDRESS=$(cohod keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(cohod keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Top up your wallet balance using faucet
To get 20 free tokens in defund-private-1 testnet:
* navigate to https://bitszn.com/faucets.html
* switch to `COSMOS` tab and select `Cosmic Horizon Testnet`
* input your wallet address and click `Request`

## Create validator
Before creating validator please make sure that you have at least 1 coho (1 coho is equal to 1000000 ucoho) and your node is synchronized

To check your wallet balance:
```
cohod query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
cohod tx staking create-validator \
  --amount 1000000ucoho \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(cohod tendermint show-validator) \
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
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for coho validator](https://github.com/kj89/testnet_manuals/blob/main/coho/monitoring/README.md)

## Usefull commands
### Service management
Check logs
```
journalctl -fu cohod -o cat
```

Start service
```
systemctl start cohod
```

Stop service
```
systemctl stop cohod
```

Restart service
```
systemctl restart cohod
```

### Node info
Synchronization info
```
cohod status 2>&1 | jq .SyncInfo
```

Validator info
```
cohod status 2>&1 | jq .ValidatorInfo
```

Node info
```
cohod status 2>&1 | jq .NodeInfo
```

Show node id
```
cohod tendermint show-node-id
```

### Wallet operations
List of wallets
```
cohod keys list
```

Recover wallet
```
cohod keys add $WALLET --recover
```

Delete wallet
```
cohod keys delete $WALLET
```

Get wallet balance
```
cohod query bank balances $WALLET_ADDRESS
```

Transfer funds
```
cohod tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000ucoho
```

### Staking, Delegation and Rewards
Delegate stake
```
cohod tx staking delegate $VALOPER_ADDRESS 10000000ucoho --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
cohod tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ucoho --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
cohod tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
cohod tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
cohod tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
cohod tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto
```
