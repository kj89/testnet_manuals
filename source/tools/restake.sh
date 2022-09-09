#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	sourced tx distribution withdraw-rewards $SOURCE_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$SOURCE_CHAIN_ID --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(sourced query bank balances $SOURCE_WALLET_ADDRESS -oj | jq -r '.balances[] | select(.denom=="usource") | .amount')
	AMOUNT_STRING=$AMOUNT"usource"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	sourced tx staking delegate $SOURCE_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $SOURCE_CHAIN_ID --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 90 sec!\033[0m"
	sleep 90
done
