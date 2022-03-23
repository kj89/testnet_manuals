## crescent node setup

### run script below to prepare your node
```
wget -O crescent_devnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/crescent/crescent_devnet.sh && chmod +x crescent_devnet.sh && ./crescent_devnet.sh
```

### load variables
```
source $HOME/.bash_profile
```

### update crescent sdk
```
cd $HOME
rm crescent -f
git clone https://github.com/crescent-network/crescent
cd crescent 
git checkout v1.0.0-rc3
make install
sudo systemctl restart crescentd && journalctl -fu crescentd.service -o cat
```

### create wallet. don’t forget to save the mnemonic
```
crescentd keys add $WALLET
```

### save wallet info
```
WALLET_ADDRESS=$(crescentd keys show $WALLET -a)
VALOPER_ADDRESS=$(crescentd keys show $WALLET --bech val -a)
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### create validator
```
crescentd tx staking create-validator \
  --amount 9000000uaugust \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.1" \
  --commission-rate "0.01" \
  --min-self-delegation "1" \
  --pubkey  $(crescentd tendermint show-validator) \
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
docker logs -f crescent --tail 100
```

To stop
```
docker stop crescent
```

To start
```
docker start crescent
```

To restart
```
docker restart crescent
```

Bond more tokens (if you want increase your validator stake you should bond more to your valoper address):
```
crescentd tx staking delegate $VALOPER_ADDRESS 10000000uaugust --from $WALLET --chain-id $CHAIN_ID --fees 5000uaugust
```

Restore wallet key
```
crescentd keys add $WALLET --recover
```

Edit validator
```
crescentd tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=WALLET$
```
