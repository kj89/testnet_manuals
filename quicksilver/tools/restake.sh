#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	quicksilverd tx distribution withdraw-rewards $QUICKSILVER_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$QUICKSILVER_CHAIN_ID --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(quicksilverd query bank balances $QUICKSILVER_WALLET_ADDRESS -oj | jq -r '.balances[] | select(.denom=="uqck") | .amount')
	AMOUNT_STRING=$AMOUNT"uqck"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	quicksilverd tx staking delegate $QUICKSILVER_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $QUICKSILVER_CHAIN_ID --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 90 sec!\033[0m"
	sleep 90
done
