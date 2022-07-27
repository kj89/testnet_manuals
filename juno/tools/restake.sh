#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	junod tx distribution withdraw-rewards $JUNO_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$JUNO_CHAIN_ID --fees=250ujunox --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(junod query bank balances $JUNO_WALLET_ADDRESS | grep amount | awk '{split($0,a,"\""); print a[2]}')
	AMOUNT=$(($AMOUNT - 500))
	AMOUNT_STRING=$AMOUNT"ujunox"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	 junod tx staking delegate $JUNO_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $JUNO_CHAIN_ID --fees=250ujunox --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 3600 sec!\033[0m"
	sleep 3600
done
