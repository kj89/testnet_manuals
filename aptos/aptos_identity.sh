echo -e "\e[1m\e[32mExtracting node identity details \e[0m" 
if [ -f $HOME/aptos/identity/private-key.txt ]
then
    PEER_ID=$(cat $HOME/aptos/identity/id.json | jq -r '.Result | keys[]')
    PUBLIC_KEY=$(cat $HOME/aptos/identity/id.json | jq -r '.. | .keys?  | select(.)[]')
    PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
    echo -en "\n"
    echo "=================================================="
    echo -e "\e[1m\e[32m1. peer-info.yaml file content \e[0m" 
    echo -en "\n"
    cat $HOME/aptos/identity/peer-info.yaml
    echo -en "\n"
    echo "=================================================="
    echo -e "\e[1m\e[32m2. Your upstream peer details. You can share your peer info with other users \e[0m" 
    echo -e ' 
'$PUBLIC_KEY':
    addresses: 
    - "/ip4/'$(ip route get 8.8.8.8 | sed -n "/src/{s/.*src *\([^ ]*\).*/\1/p;q}")'/tcp/6180/ln-noise-ik/'$PUBLIC_KEY'/ln-handshake/0" 
    role: "Upstream"'
    echo -en "\n"
    echo "=================================================="
    echo -e "\e[1m\e[32m3. Your identity details \e[0m" 
    echo -en "\n"
    echo -e "\e[1m\e[32mPeer Id: \e[0m" $PEER_ID
    echo -e "\e[1m\e[32mPublic Key: \e[0m" $PUBLIC_KEY
    echo -e "\e[1m\e[32mPrivate Key:  \e[0m" $PRIVATE_KEY
    echo -en "\n"
else
    echo -e "\e[1m\e[32mCan't find required identy files: "$HOME/aptos/identity"  \e[0m" 
fi
