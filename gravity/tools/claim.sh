#!/bin/bash
RECORDS=$(gravityd q records list-user-redemption-record --limit 10000 --output json | jq --arg WALLET_ADDRESS "$$1" '.UserRedemptionRecord | map(select(.sender == $WALLET_ADDRESS and .isClaimable == true))')
RECORDS_COUNT=$(echo $RECORDS | jq length)
echo -e "\e[1m\e[32m$RECORDS_COUNT\e[0m claimable records found for sender \e[1m\e[32m$$1\e[0m..."
sleep 3
for row in $(echo "${RECORDS}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    ZONE=$(echo $(_jq '.hostZoneId'))
    EPOCH=$(echo $(_jq '.epochNumber'))
    SENDER=$(echo $(_jq '.sender'))
    echo -e "Claiming \e[1m\e[32m$ZONE.$EPOCH.$SENDER\e[0m..."
    gravityd tx stakeibc claim-undelegated-tokens $ZONE $EPOCH $SENDER --chain-id $GRAVITY_CHAIN_ID --from $WALLET --yes
    sleep 10
done
