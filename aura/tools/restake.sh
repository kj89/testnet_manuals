#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	aurad tx distribution withdraw-rewards $AURA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$AURA_CHAIN_ID --fees=250ueaura --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(aurad query bank balances $AURA_WALLET_ADDRESS | grep amount | awk '{split($0,a,"\""); print a[2]}')
	AMOUNT=$(($AMOUNT - 500))
	AMOUNT_STRING=$AMOUNT"ueaura"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	 aurad tx staking delegate $AURA_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $AURA_CHAIN_ID --fees=250ueaura --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 3600 sec!\033[0m"
	sleep 3600
done
