<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/171283906-5ed9f51f-90bf-4e81-81c7-dc54ea6ea820.jpg">
</p>

# Subspace node setup for Gemini Incentivized Testnet

Official documentation:
- Official manual: https://github.com/subspace/subspace/blob/main/docs/farming.md

Polkadot Wallet setup:
- https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Feu.gemini-1a.subspace.network%2Fws#/accounts

## Set up your Subspace node
### Option 1 (automatic)
You can setup your Subspace node in few minutes by using automated script below
```
wget -O celestia_mamaki.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/celestia_mamaki.sh && chmod +x celestia_mamaki.sh && ./celestia_mamaki.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/celestia/manual_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
celestia-appd status 2>&1 | jq .SyncInfo
```

To check validator logs
```
journalctl -u celestia-appd -f -o cat
```

To check bridge logs
```
journalctl -u celestia-bridge -f -o cat
```

### If your node often mis blocks try enabling legacy p2p layer
```
sed -i.bak -e "s/^use-legacy *=.*/use-legacy = \"true\"/" $HOME/.celestia-app/config/config.toml
systemctl restart celestia-appd
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
celestia-appd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
celestia-appd keys add $WALLET --recover
```

To get current list of wallets
```
celestia-appd keys list
```

### Save wallet info
Add wallet address
```
WALLET_ADDRESS=$(celestia-appd keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(celestia-appd keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
To top up your wallet join [Celestia discord server](https://discord.gg/QAsD8j4Z) and navigate to **#faucet** channel under **NODE OPERATORS** category

To request a faucet grant:
```
$request <YOUR_WALLET_ADDRESS>
```

### Create validator
Before creating validator please make sure that you have at least 1 tia (1 tia is equal to 1000000 utia) and your node is synchronized

To check your wallet balance:
```
celestia-appd query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
celestia-appd tx staking create-validator \
  --amount 10000000utia \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(celestia-appd tendermint show-validator) \
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
sudo ufw allow 26656,26657,26660,9090/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for celestia validator](https://github.com/kj89/testnet_manuals/blob/main/celestia/monitoring/README.md)

## Usefull commands
### Service management
Check logs
```
journalctl -fu celestia-appd -o cat
```

Start service
```
systemctl start celestia-appd
```

Stop service
```
systemctl stop celestia-appd
```

Restart service
```
systemctl restart celestia-appd
```

### Node info
Synchronization info
```
celestia-appd status 2>&1 | jq .SyncInfo
```

Validator info
```
celestia-appd status 2>&1 | jq .ValidatorInfo
```

Node info
```
celestia-appd status 2>&1 | jq .NodeInfo
```

Show node id
```
celestia-appd tendermint show-node-id
```

### Wallet operations
List of wallets
```
celestia-appd keys list
```

Recover wallet
```
celestia-appd keys add $WALLET --recover
```

Delete wallet
```
celestia-appd keys delete $WALLET
```

Get wallet balance
```
celestia-appd query bank balances $WALLET_ADDRESS
```

Transfer funds
```
celestia-appd tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000utia
```

### Staking, Delegation and Rewards
Delegate stake
```
celestia-appd tx staking delegate $VALOPER_ADDRESS 10000000utia --from=$WALLET --chain-id=$CHAIN_ID
```

Redelegate stake from validator to another validator
```
celestia-appd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utia --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
celestia-appd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
celestia-appd tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
celestia-appd tx staking edit-validator \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
celestia-appd tx slashing unjail \
  --from=$WALLET \
  --chain-id=$CHAIN_ID
```

### Delete celestia validator and bridge node
To completely remove celesia node from server use command below (please make sure you have saved your validator key located in `~/.celestia-app/config/priv_validator_key.json`)
```
sudo systemctl stop celestia-appd
sudo systemctl disable celestia-appd
rm /etc/systemd/system/celestia-appd.service
sudo systemctl stop celestia-bridge
sudo systemctl disable celestia-bridge
rm /etc/systemd/system/celestia-bridge.service
sudo systemctl daemon-reload
cd $HOME
rm -rf .celestia-app .celestia-bridge celestia-app networks
```
