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

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=augusta-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo -e "\033[0;35m"
echo '================================================='
echo 'Your node name: ' $NODENAME
echo 'Your wallet name: ' $WALLET
echo 'Your chain name: ' $CHAIN_ID
echo '================================================='
echo -e "\e[0m"
sleep 2

echo -e "\e[1m\e[32m1. Updating dependencies... \e[0m" && sleep 1
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
sudo apt install -y uidmap dbus-user-session

echo "=================================================="

echo -e "\e[1m\e[32m2. Checking if Docker is installed... \e[0m" && sleep 1

if ! command -v docker &> /dev/null
then

    echo -e "\e[1m\e[32m2.1 Installing Docker... \e[0m" && sleep 1
    sudo apt-get install ca-certificates curl gnupg lsb-release wget -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
fi

echo -e "\e[1m\e[32m4. Downloading Archway config files ... \e[0m" && sleep 1

docker rm -f archway
docker run --rm -it -v $HOME/.archway:/root/.archway archwaynetwork/archwayd:augusta init $NODENAME --chain-id $CHAIN_ID
docker run --rm -it -v $HOME/.archway:/root/.archway archwaynetwork/archwayd:augusta config chain-id $CHAIN_ID
perl -i -pe 's/^minimum-gas-prices = .+?$/minimum-gas-prices = "0august"/' $HOME/.archway/config/app.toml
SEEDS="2f234549828b18cf5e991cc884707eb65e503bb2@34.74.129.75:31076,c8890bcde31c2959a8aeda172189ec717fef0b2b@95.216.197.14:26656"
PEERS="332dea7332a0c4647a147a08bf50bb2038931e4c@81.30.158.46:26656,4e08eb9d62607d05e3fa3fa52d98a00014c8040b@162.55.90.254:26656,4a701d399a0cd4a577e5b30c9d3cc5d75854936e@95.214.53.132:26456,0c019ac4e4f39d95355926435e50a25ed589915f@89.163.151.226:26656,b65efc14137a426a795b5e78cf34def7e5240231@89.163.164.211:26656,33baa872768e12d4100bce5eb875b90b8739a1d4@185.214.134.154:46656,76862fd5ee017b7b46f65a7ac15da12bba12f7f1@49.12.215.72:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.archway/config/config.toml
sed -i.bak -e "s/prometheus = false/prometheus = true/" $HOME/.archway/config/config.toml
curl -s "https://api.nodes.guru/archway_genesis.json" | jq '.result.genesis' > $HOME/.archway/config/genesis.json
wget -O addrbook.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/addrbook.json
mv addrbook.json $HOME/.archway/config/

echo -e "\e[1m\e[32m5. Starting Archway ... \e[0m" && sleep 1

docker run --restart=always -d -it --network host --name archway -v $HOME/.archway:/root/.archway archwaynetwork/archwayd:augusta start --x-crisis-skip-assert-invariants
echo "alias archwayd='docker exec -it archway archwayd'" >> $HOME/.bash_profile

echo "=================================================="

echo -e "\e[1m\e[32mArchway Started \e[0m"

echo "=================================================="

echo -e "\e[1m\e[32mTo check sync status: \e[0m" 
echo -e "\e[1m\e[39m    curl -s localhost:26657/status | jq .result | jq .sync_info \n \e[0m" 

echo -e "\e[1m\e[32mTo view logs: \e[0m" 
echo -e "\e[1m\e[39m    docker logs -f archway --tail 100 \n \e[0m" 

echo -e "\e[1m\e[32mTo stop: \e[0m" 
echo -e "\e[1m\e[39m    docker stop archway \n \e[0m" 

echo -e "\e[1m\e[32mTo start: \e[0m" 
echo -e "\e[1m\e[39m    docker start archway \n \e[0m" 

echo -e "\e[1m\e[32mTo restart: \e[0m" 
echo -e "\e[1m\e[39m    docker restart archway \n \e[0m" 
