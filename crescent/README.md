## crescent node setup

### crescent network configuration
https://docs.crescent.network/other-information/network-configurations

### run script below to prepare your node in mainnet
```
wget -O crescent.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/crescent/crescent.sh && chmod +x crescent.sh && ./crescent.sh
```

### run script below to prepare your node in devnet
```
wget -O crescent_devnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/crescent/crescent_devnet.sh && chmod +x crescent_devnet.sh && ./crescent_devnet.sh
```

### load variables
```
source $HOME/.bash_profile
```

### update crescent sdk to v1.0.0-rc3
```
cd $HOME
rm crescent -rf
git clone https://github.com/crescent-network/crescent
cd crescent 
git checkout v1.0.0-rc3
make install
sudo systemctl restart crescentd && journalctl -fu crescentd.service -o cat
```

### update crescent sdk to v1.0.0-rc4
```
cd $HOME
rm crescent -rf
git clone https://github.com/crescent-network/crescent
cd crescent 
git checkout v1.0.0-rc4
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
  --amount 9000000ucre \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(crescentd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID \
  --gas 300000 \
  --fees 3ucre
```

## Usefull commands
To check sync status
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```

To view logs
```
journalctl -fu crescentd -o cat
```

To stop
```
systemctl stop crescentd
```

To start
```
systemctl start crescentd
```

To restart
```
systemctl restart crescentd
```

Bond more tokens (if you want increase your validator stake you should bond more to your valoper address):
```
crescentd tx staking delegate $VALOPER_ADDRESS 10000000ucre --from $WALLET --chain-id $CHAIN_ID --fees 5000ucre
```

Withdraw rewards
```
crescentd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID
```

Get wallet balance
```
crescentd query bank balances $WALLET_ADDRESS
```

Change commision
```
crescentd tx staking edit-validator --commission-rate "0.02" --moniker=$NODENAME --chain-id=$CHAIN_ID --from=$WALLET
```

Restore wallet key
```
crescentd keys add $WALLET --recover
```

Edit validator
```
crescentd tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```
