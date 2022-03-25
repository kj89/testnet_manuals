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
sudo apt update

echo "=================================================="

echo -e "\e[1m\e[32m2. Installing required dependencies... \e[0m" && sleep 1
sudo apt install jq -y
sudo apt install git -y
sudo apt install jq -y
# manually installing yq
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

echo "=================================================="

echo -e "\e[1m\e[32m3. Setting up Aptos fullnode ... \e[0m" && sleep 1

cd $HOME
rm -rf aptos-core
sudo mkdir -p /opt/aptos/data .aptos/config .aptos/key
git clone https://github.com/aptos-labs/aptos-core.git
cd aptos-core
git checkout origin/devnet &>/dev/null
echo y | ./scripts/dev_setup.sh
source ~/.cargo/env
cargo build -p aptos-node --release
cargo build -p aptos-operational-tool --release
mv ~/aptos-core/target/release/aptos-node /usr/local/bin
mv ~/aptos-core/target/release/aptos-operational-tool /usr/local/bin
/usr/local/bin/aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file ~/.aptos/key/private-key.txt
/usr/local/bin/aptos-operational-tool extract-peer-from-file --encoding hex --key-file ~/.aptos/key/private-key.txt --output-file ~/.aptos/config/peer-info.yaml &>/dev/null
cp ~/.aptos/key/private-key.txt $HOME/aptos_backup/private-key.txt
cp ~/.aptos/config/peer-info.yaml $HOME/aptos_backup/peer-info.yaml
cp ~/aptos-core/config/src/config/test_data/public_full_node.yaml ~/.aptos/config
wget -O /opt/aptos/data/genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -q -O ~/.aptos/waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
wget -q -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq
wget -O seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
WAYPOINT=$(cat ~/.aptos/waypoint.txt)
PRIVKEY=$(cat ~/.aptos/key/private-key.txt)
PEER=$(sed -n 2p ~/.aptos/config/peer-info.yaml | sed 's/.$//')
PUBKEY=$(cat ~/.aptos/config/peer-info.yaml | jq -r '.. | .keys?  | select(.)[]')
sed -i.bak -e "s/0:01234567890ABCDEFFEDCA098765421001234567890ABCDEFFEDCA0987654210/$WAYPOINT/" $HOME/.aptos/config/public_full_node.yaml
sed -i "s/genesis_file_location: .*/genesis_file_location: \"\/opt\/aptos\/data\/genesis.blob\"/" $HOME/.aptos/config/public_full_node.yaml
sleep 2 
/usr/local/bin/yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/.aptos/config/public_full_node.yaml seeds.yaml
sed -i '/^api:/a\
  address: 0.0.0.0:8080' $HOME/.aptos/config/public_full_node.yaml
sed -i '/network_id: "public"$/a\
    identity:\
        type: "from_config"\
        key: "'$PRIVKEY'"\
        peer_id: "'$PEER'"' $HOME/.aptos/config/public_full_node.yaml

echo -e "\e[1m\e[32m4. Creating service for Aptos fullnode ... \e[0m" && sleep 1

echo "[Unit]
Description=Aptosfg
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which aptos-node) -f $HOME/.aptos/config/public_full_node.yaml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/aptosd.service
mv $HOME/aptosd.service /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable aptosd
sudo systemctl restart aptosd

echo "=================================================="

echo -e "\e[1m\e[32mAptos fullnode is started \e[0m"

echo "=================================================="

echo -e "\e[1m\e[92m Identity was successfully created \e[0m"
echo -e "\e[1m\e[92m Peer Id: \e[0m" $PEER
echo -e "\e[1m\e[92m Public Key:  \e[0m" $PUBKEY
echo -e "\e[1m\e[92m Private Key:  \e[0m" $PRIVKEY

echo "=================================================="

echo -e "\e[1m\e[32mPrivate key file location: \e[0m" 
echo -e "\e[1m\e[39m"    $HOME/.aptos/key/private-key.txt" \n \e[0m"

echo -e "\e[1m\e[32mPeer info file location: \e[0m" 
echo -e "\e[1m\e[39m"    $HOME/.aptos/config/peer-info.yaml" \n \e[0m"


echo -e "\e[1m\e[32mTo check sync status: \e[0m" 
echo -e "\e[1m\e[39m    curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type \n \e[0m" 

echo -e "\e[1m\e[32mTo view logs: \e[0m" 
echo -e "\e[1m\e[39m    docker logs -f aptos-fullnode-1 --tail 5000 \n \e[0m" 

echo -e "\e[1m\e[32mTo stop: \e[0m" 
echo -e "\e[1m\e[39m    docker compose stop \n \e[0m" 
