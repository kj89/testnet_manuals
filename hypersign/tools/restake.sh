#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	hid-noded tx distribution withdraw-rewards $HYPERSIGN_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$HYPERSIGN_CHAIN_ID --node tcp://localhost:31657 --keyring-backend test --broadcast-mode block --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(hid-noded query bank balances $HYPERSIGN_WALLET_ADDRESS --node tcp://localhost:31657 | grep amount | awk '{split($0,a,"\""); print a[2]}')
	echo -e "Your total balance of uhid: \033[0;32m$AMOUNT\033[0m"
	AMOUNT_STRING=$AMOUNT"uhid"
	hid-noded tx staking delegate $HYPERSIGN_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $HYPERSIGN_CHAIN_ID --node tcp://localhost:31657 --keyring-backend test --broadcast-mode block --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 90 sec!\033[0m"
	sleep 90
done
