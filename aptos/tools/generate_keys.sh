docker run --rm --name aptos_tools -d -i aptoslab/tools:devnet
docker exec -it aptos_tools aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file $HOME/private-key.txt
echo "export KEY=$(docker exec -it aptos_tools cat $HOME/private-key.txt)" >> $HOME/.bash_profile
PEER_ID=$(docker exec -it aptos_tools aptos-operational-tool extract-peer-from-file --encoding hex --key-file $HOME/private-key.txt --output-file $HOME/peer-info.yaml | jq -r '.. | .keys?  | select(.)[]')
echo "export PEER_ID=$PEER_ID" >> $HOME/.bash_profile
source $HOME/.bash_profile
docker stop aptos_tools