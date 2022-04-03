# umee node setup

## run script below to install your umee node
```
wget -O umee_mainnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/umee/umee_mainnet.sh && chmod +x umee_mainnet.sh && ./umee_mainnet.sh
```

### load variables
```
source $HOME/.bash_profile
```

### create wallet. don’t forget to save the mnemonic
```
umeed keys add $WALLET
```

### save wallet info
```
WALLET_ADDRESS=$(umeed keys show $WALLET -a)
VALOPER_ADDRESS=$(umeed keys show $WALLET --bech val -a)
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### create validator
```
umeed tx staking create-validator \
  --amount 9000000uumee \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.1" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey  $(umeed tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID \
  --gas 300000 \
  --fees 3uumee
```

## Usefull commands
To check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```

To view logs
```
journalctl -fu umeed -o cat
```

To stop
```
systemctl stop umeed
```

To start
```
systemctl start umeed
```

To restart
```
systemctl restart umeed
```

Bond more tokens (if you want increase your validator stake you should bond more to your valoper address):
```
umeed tx staking delegate $VALOPER_ADDRESS 10000000uumee --from $WALLET --chain-id $CHAIN_ID --fees 5000uumee
```

Restore wallet key
```
umeed keys add $WALLET --recover
```

Edit validator
```
umeed tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=WALLET$
```
