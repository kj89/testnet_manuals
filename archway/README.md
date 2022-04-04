## Archway node setup

### run script below to prepare your node
```
wget -O archway_devnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/archway_devnet.sh && chmod +x archway_devnet.sh && ./archway_devnet.sh
```

### load variables
```
source $HOME/.bash_profile
```

### create wallet. don’t forget to save the mnemonic
```
archwayd keys add $WALLET
```

### create validator
```
archwayd tx staking create-validator \
  --amount 9000000uaugust \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.1" \
  --commission-rate "0.01" \
  --min-self-delegation "1" \
  --pubkey  $(archwayd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID \
  --gas 300000 \
  --fees 3uaugust
```

## Usefull commands
To check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```

To view logs
```
docker logs -f archway --tail 100
```

To stop
```
docker stop archway
```

To start
```
docker start archway
```

To restart
```
docker restart archway
```

Bond more tokens (if you want increase your validator stake you should bond more to your valoper address):
```
archwayd tx staking delegate $VALOPER_ADDRESS 10000000uaugust --from $WALLET --chain-id $CHAIN_ID --fees 5000uaugust
```

Withdraw rewards
```
archwayd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID
```

Get wallet balance
```
archwayd query bank balances $WALLET_ADDRESS
```

Change commision
```
archwayd tx staking edit-validator --commission-rate "0.02" --moniker=$NODENAME --chain-id=$CHAIN_ID --from=$WALLET
```

Restore wallet key
```
archwayd keys add $WALLET --recover
```

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
