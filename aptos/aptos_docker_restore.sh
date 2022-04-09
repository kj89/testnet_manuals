echo -e "\e[1m\e[32mRecovering Aptos fullnode... \e[0m" && sleep 1
cd $HOME/aptos
docker compose down
docker volume rm aptos_db -f
PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
PEER_ID=$(cat $HOME/aptos/identity/id.json | jq -r '.. | .keys?  | select(.)[]')
yq e -i '.full_node_networks[0].identity.key="'$PRIVATE_KEY'"' $HOME/aptos/public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' $HOME/aptos/public_full_node.yaml
docker compose up -d
