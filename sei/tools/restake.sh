#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	echo seid tx distribution withdraw-rewards $SEI_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$SEI_CHAIN_ID --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(seid query bank balances $SEI_WALLET_ADDRESS | grep amount | awk '{split($0,a,"\""); print a[2]}')
	AMOUNT_STRING=$AMOUNT"usei"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	echo seid tx staking delegate $SEI_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $SEI_CHAIN_ID --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 90 sec!\033[0m"
	sleep 90
done
