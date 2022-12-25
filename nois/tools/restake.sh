#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	noisd tx distribution withdraw-rewards $NOIS_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$NOIS_CHAIN_ID --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(noisd query bank balances $NOIS_WALLET_ADDRESS | grep amount | awk '{split($0,a,"\""); print a[2]}')
	AMOUNT_STRING=$AMOUNT"unois"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	noisd tx staking delegate $NOIS_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $NOIS_CHAIN_ID --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 3600 sec!\033[0m"
	sleep 3600
done
