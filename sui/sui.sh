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

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq
sudo apt-get install jq -y

# install docker
sudo apt-get install ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# install docker compose
docker_compose_version=$(wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name")
sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
sudo chmod +x /usr/bin/docker-compose

# download configs
cd $HOME && rm -rf sui
mkdir sui && cd sui
wget -qO docker-compose.yaml https://raw.githubusercontent.com/MystenLabs/sui/main/docker/fullnode/docker-compose.yaml
wget -qO fullnode-template.yaml https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml
wget -qO genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
sed -i 's/127.0.0.1/0.0.0.0/' fullnode-template.yaml
docker-compose down --volumes

# start application
docker-compose up -d

echo "=================================================="

echo -e "\e[1m\e[32mSui FullNode Started \e[0m"

echo "=================================================="

echo -e "\e[1m\e[32mCheck node info: \e[0m" 
echo -e "\e[1m\e[39m    curl -s -X POST http://127.0.0.1:9000 -H 'Content-Type: application/json' -d '{ \"jsonrpc\":\"2.0\", \"method\":\"rpc.discover\",\"id\":1}' | jq .result.info \n \e[0m" 

echo -e "\e[1m\e[32mTo view logs: \e[0m" 
echo -e "\e[1m\e[39m    docker logs -f sui-fullnode-1 --tail 50 \n \e[0m" 

echo -e "\e[1m\e[32mTo restart: \e[0m" 
echo -e "\e[1m\e[39m    docker-compose restart \n \e[0m" 
