echo -e "\e[1m\e[32mUpdating aptos fullnode.. \e[0m" && sleep 1
systemctl stop aptosd
rm -rf /opt/aptos/data/*
wget -O /opt/aptos/data/genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -O ~/.aptos/waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
sed -i.bak -e "s/from_config: ".*"/from_config: "$(cat ~/.aptos/waypoint.txt)"/" $HOME/.aptos/config/public_full_node.yaml
systemctl restart aptosd
