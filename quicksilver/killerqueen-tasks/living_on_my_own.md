Withdraw rewards
```
quicksilverd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$QUICKSILVER_CHAIN_ID --gas=auto --gas-adjustment 1.4 --yes
```

Check wallet balance
```
quicksilverd query bank balances $QUICKSILVER_WALLET_ADDRESS
```

Bond to self by providing `uqck` token amount you ant to delegate
```
quicksilverd tx staking delegate $QUICKSILVER_VALOPER_ADDRESS <AMOUNT>uqck --from=$WALLET --chain-id=$QUICKSILVER_CHAIN_ID --gas=auto --gas-adjustment 1.4 --yes
```
