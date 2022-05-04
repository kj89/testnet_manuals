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

source $HOME/.bash_profile

echo -e "\e[1m\e[32m1. Updating dependencies... \e[0m" && sleep 1
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing required dependencies... \e[0m" && sleep 1
sudo apt-get install jq -y
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq

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
wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/docker-compose.yaml
wget -qO public_full_node.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/public_full_node.yaml
wget -qO genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -qO waypoint.txt https://devnet.aptoslabs.com/waypoint.txt

echo -e "\e[1m\e[32m6. Generating a unique node identity \e[0m"
if [ -z "$KEY" ] && [ -z "$PEER_ID" ]; then
	wget -qO generate_keys.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/tools/generate_keys.sh && chmod +x generate_keys.sh && ./generate_keys.sh
	source $HOME/.bash_profile
else
	echo -e "\e[1m\e[32mIdentity keys already extst! \e[0m"
fi

echo -e "\e[1m\e[32m7.1 Updating configuration \e[0m"  
yq e -i '.full_node_networks[0].identity.type="from_config"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.key="'$KEY'"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].listen_address = "/ip4/0.0.0.0/tcp/6180"' public_full_node.yaml \
&& yq -i '.services.fullnode.ports += "6180:6180"' docker-compose.yaml

echo -e "\e[1m\e[32m7.2 Updating seeds \e[0m"  
wget -qO seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml seeds.yaml

echo -e "\e[1m\e[32m8. Starting Aptos FullNode ... \e[0m" && sleep 1

docker compose up -d

echo "=================================================="

echo -e "\e[1m\e[32mAptos FullNode Started \e[0m"
echo -e "\e[1m\e[92m Peer Id: \e[0m" $PEER_ID
echo -e "\e[1m\e[92m Private Key:  \e[0m" $KEY

echo "=================================================="

echo -e "\e[1m\e[32mVerify initial synchronization: \e[0m" 
echo -e "\e[1m\e[39m    curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type \n \e[0m" 

echo -e "\e[1m\e[32mGet your node identity information: \e[0m" 
echo -e "\e[1m\e[39m    wget -qO get_identity.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/tools/get_identity.sh && chmod +x get_identity.sh && ./get_identity.sh \n \e[0m" 

echo -e "\e[1m\e[32mTo view logs: \e[0m" 
echo -e "\e[1m\e[39m    docker logs -f aptos-fullnode-1 --tail 50 \n \e[0m" 

echo -e "\e[1m\e[32mTo restart: \e[0m" 
echo -e "\e[1m\e[39m    docker compose restart \n \e[0m" 
