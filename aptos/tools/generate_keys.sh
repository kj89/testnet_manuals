echo -e "\e[1m\e[32mGenerating identity keys... \e[0m" && sleep 1
docker run --rm --name aptos_tools -d -i aptoslab/tools:devnet
docker exec -it aptos_tools aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file $HOME/private-key.txt
echo "export KEY=$(docker exec -it aptos_tools cat $HOME/private-key.txt)" >> $HOME/.bash_profile
PEER_ID=$(docker exec -it aptos_tools aptos-operational-tool extract-peer-from-file --encoding hex --key-file $HOME/private-key.txt --output-file $HOME/peer-info.yaml | jq -r '.Result | keys[0]')
echo "export PEER_ID=$PEER_ID" >> $HOME/.bash_profile
docker stop aptos_tools
