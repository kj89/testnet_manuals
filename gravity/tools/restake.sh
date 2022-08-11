#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	gravityd tx distribution withdraw-rewards $GRAVITY_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$GRAVITY_CHAIN_ID --fees=250ugraviton --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(gravityd query bank balances $GRAVITY_WALLET_ADDRESS | grep amount | awk '{split($0,a,"\""); print a[2]}')
	AMOUNT=$(($AMOUNT - 500))
	AMOUNT_STRING=$AMOUNT"ugraviton"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	 gravityd tx staking delegate $GRAVITY_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $GRAVITY_CHAIN_ID --fees=250ugraviton --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 3600 sec!\033[0m"
	sleep 3600
done
