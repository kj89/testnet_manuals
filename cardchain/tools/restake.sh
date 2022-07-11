#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	echo -e "${PASSWORD}\n" | Cardchain tx distribution withdraw-rewards $CARDCHAIN_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CARDCHAIN_CHAIN_ID --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(Cardchain query bank balances $CARDCHAIN_WALLET_ADDRESS | grep amount | awk '{split($0,a,"\""); print a[2]}')
	AMOUNT_STRING=$AMOUNT"ubpf"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	echo -e "${PASSWORD}\n" |  Cardchain tx staking delegate $CARDCHAIN_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $CARDCHAIN_CHAIN_ID --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 3600 sec!\033[0m"
	sleep 3600
done
