echo -e "\e[1m\e[32mUpdating configs... \e[0m" && sleep 1

# download public_full_node config
wget -qO $HOME/aptos/public_full_node.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/public_full_node.yaml

# update keys
yq e -i '.full_node_networks[0].identity.type="from_config"' $HOME/aptos/public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.key="'$KEY'"' $HOME/aptos/public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' $HOME/aptos/public_full_node.yaml 

# update seeds
wget -qO seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml seeds.yaml

# restart docker container
docker restart aptos-fullnode-1
