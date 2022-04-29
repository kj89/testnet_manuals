#!/bin/bash
echo "=================================================="
echo -e "\033[0;35m"
echo " :::    ::: ::::::::::: ::::    :::  ::::::::  :::::::::  :::::::::: ::::::::  ";
echo " :+:   :+:      :+:     :+:+:   :+: :+:    :+: :+:    :+: :+:       :+:    :+: ";
echo " +:+  +:+       +:+     :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+       +:+        ";
echo " +#++:++        +#+     +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#++:++#  +#++:++#++ ";
echo " +#+  +#+       +#+     +#+  +#+#+# +#+    +#+ +#+    +#+ +#+              +#+ ";
echo " #+#   #+#  #+# #+#     #+#   #+#+# #+#    #+# #+#    #+# #+#       #+#    #+# ";
echo " ###    ###  #####      ###    ####  ########  #########  ########## ########  ";
echo -e "\e[0m"
echo "=================================================="
sleep 2

echo -e "\e[1m\e[32m1. Updating dependencies... \e[0m" && sleep 1
sudo apt update && sudo apt upgrade -y
source ./.bash_profile

echo -e "\e[1m\e[32m2. Installing required dependencies... \e[0m" && sleep 1
sudo apt-get install jq -y
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq

echo -e "\e[1m\e[32m3. Checking if Docker is installed... \e[0m" && sleep 1
if ! command -v docker &> /dev/null
then
    echo -e "\e[1m\e[32m3.1 Installing Docker... \e[0m" && sleep 1
    sudo apt-get install ca-certificates curl gnupg lsb-release -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
fi

echo -e "\e[1m\e[32m4. Checking if Docker Compose is installed ... \e[0m" && sleep 1
docker compose version
if [ $? -ne 0 ]
then
    echo -e "\e[1m\e[32m4.1 Installing Docker Compose v2.3.3 ... \e[0m" && sleep 1
    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    sudo chown $USER /var/run/docker.sock
fi

echo -e "\e[1m\e[32m5. Downloading Aptos FullNode config files ... \e[0m" && sleep 1
mkdir $HOME/aptos && cd $HOME/aptos
wget -O docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/docker-compose.yaml
wget -O public_full_node.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/public_full_node.yaml
wget -O genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -O waypoint.txt https://devnet.aptoslabs.com/waypoint.txt

echo -e "\e[1m\e[32m6. Generating a unique node identity \e[0m"
if [ -z "$KEY" ] && [ -z "$PEER_ID" ]; then
	docker run --rm --name aptos_tools -d -i aptoslab/tools:devnet
	docker exec -it aptos_tools aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file $HOME/private-key.txt
	echo "export KEY=$(docker exec -it aptos_tools cat $HOME/private-key.txt)" >> $HOME/.bash_profile
	PEER_ID=$(docker exec -it aptos_tools aptos-operational-tool extract-peer-from-file --encoding hex --key-file $HOME/private-key.txt --output-file $HOME/peer-info.yaml | jq -r '.. | .keys?  | select(.)[]')
	echo "export PEER_ID=$PEER_ID" >> $HOME/.bash_profile
	source $HOME/.bash_profile
	docker stop aptos_tools
else
	echo -e "\e[1m\e[32mIdentity keys already extst! \e[0m"
fi

echo "==============================================================="
echo -e "\e[1m\e[92m Identity was successfully created \e[0m"
echo -e "\e[1m\e[92m Peer Id: \e[0m" $PEER_ID
echo -e "\e[1m\e[92m Private Key:  \e[0m" $KEY
echo "==============================================================="
yq e -i '.full_node_networks[0].identity.type="from_config"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.key="'$KEY'"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' public_full_node.yaml 


echo -e "\e[1m\e[32m7. Updating seeds \e[0m"  
wget -O seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml seeds.yaml

echo -e "\e[1m\e[32m8. Starting Aptos FullNode ... \e[0m" && sleep 1

docker compose up -d

echo "=================================================="

echo -e "\e[1m\e[32mAptos FullNode Started \e[0m"

echo "=================================================="

echo -e "\e[1m\e[32mVerify initial synchronization: \e[0m" 
echo -e "\e[1m\e[39m    curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type \n \e[0m" 

echo -e "\e[1m\e[32mVerify outbound network connections: \e[0m" 
echo -e "\e[1m\e[39m    curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_connections \n \e[0m" 

echo -e "\e[1m\e[32mGet your node identity information: \e[0m" 
echo -e "\e[1m\e[39m    wget -O aptos_identity.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/aptos_identity.sh && chmod +x aptos_identity.sh && ./aptos_identity.sh \n \e[0m" 

echo -e "\e[1m\e[32mTo view logs: \e[0m" 
echo -e "\e[1m\e[39m    docker logs -f aptos-fullnode-1 --tail 5000 \n \e[0m" 

echo -e "\e[1m\e[32mTo stop: \e[0m" 
echo -e "\e[1m\e[39m    docker compose down \n \e[0m" 

echo -e "\e[1m\e[32mTo stop: \e[0m" 
echo -e "\e[1m\e[39m    docker compose down \n \e[0m" 
