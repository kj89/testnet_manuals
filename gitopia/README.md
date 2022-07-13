## gitopia node setup

### explorer
https://explorer.gitopia.com/

### official guide
https://docs.gitopia.com/validator-setup/index.html

### set up your node using binaries
```
wget -O gitopia.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/gitopia/gitopia.sh && chmod +x gitopia.sh && ./gitopia.sh
```

### load variables
```
source $HOME/.bash_profile
```

### create wallet. don’t forget to save the mnemonic
```
gitopiad keys add $WALLET
```
or
### recover your wallet from seed phrase
```
gitopiad keys add $WALLET --recover
```

### create validator
```
gitopiad tx staking create-validator \
  --amount 1000000utlore \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(gitopiad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID
```

### (OPTIONAL) save wallet info
```
WALLET_ADDRESS=$(gitopiad keys show $WALLET -a)
VALOPER_ADDRESS=$(gitopiad keys show $WALLET --bech val -a)
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Usefull commands
To check sync status
```
curl -s localhost:26657/status | jq .result.sync_info
```

### Service commands
To view logs
```
journalctl -fu gitopiad -o cat
```

To stop
```
systemctl stop gitopiad
```

To start
```
systemctl start gitopiad
```

To restart
```
systemctl restart gitopiad
```

### Cosmos commands
Bond more tokens (if you want increase your validator stake you should bond more to your valoper address):
```
gitopiad tx staking delegate $VALOPER_ADDRESS 10000000utlore --from $WALLET --chain-id $CHAIN_ID --fees 5000utlore
```

Redelegate
```
gaiad tx staking redelegate $VALOPER_ADDRESS <dst-validator-operator-addr> 100000000utlore --from=$WALLET --chain-id=$CHAIN_ID
```

Withdraw rewards
```
gitopiad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID
```

Get wallet address
```
gitopiad keys show $WALLET --bech val -a
```

Get wallet balance
```
gitopiad query bank balances $WALLET_ADDRESS
```

Change commision
```
gitopiad tx staking edit-validator --commission-rate "0.02" --moniker=$NODENAME --chain-id=$CHAIN_ID --from=$WALLET
```

Edit validator
```
gitopiad tx staking edit-validator \
--moniker=$NODENAME \
--identity=<your_keybase_id> \
--website="<your_website>" \
--details="<your_validator_description>" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
gitopiad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto \
  --gas-adjustment=1.4
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
systemctl stop gitopiad
systemctl disable gitopiad
rm /etc/systemd/system/gitopia* -rf
rm $(which gitopiad) -rf
rm $HOME/.gitopia* -rf
rm $HOME/gitopia -rf
sed -i '/GITOPIA_/d' ~/.bash_profile
```
