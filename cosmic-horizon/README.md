## cosmic-horizon node setup

### run script below to prepare your node
```
wget -O cosmic-horizon_testnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/cosmic-horizon/cosmic-horizon_testnet.sh && chmod +x cosmic-horizon_testnet.sh && ./cosmic-horizon_testnet.sh
```

### load variables
```
source $HOME/.bash_profile
```

### create wallet. don’t forget to save the mnemonic
```
cohod keys add $WALLET
```

### save wallet info
```
WALLET_ADDRESS=$(cohod keys show $WALLET -a)
VALOPER_ADDRESS=$(cohod keys show $WALLET --bech val -a)
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### create validator
```
cohod tx staking create-validator \
  --amount 9000000ucoho \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(cohod tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID \
  --gas 300000 \
  --fees 3ucoho
```

## Usefull commands
To check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```

To view logs
```
journalctl -fu cohod -o cat
```

To stop
```
systemctl stop cohod
```

To start
```
systemctl start cohod
```

To restart
```
systemctl restart cohod
```

Bond more tokens (if you want increase your validator stake you should bond more to your valoper address):
```
cohod tx staking delegate $VALOPER_ADDRESS 10000000ucoho --from $WALLET --chain-id $CHAIN_ID --fees 5000ucoho
```

Restore wallet key
```
cohod keys add $WALLET --recover
```

Edit validator
```
cohod tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=WALLET$
```
