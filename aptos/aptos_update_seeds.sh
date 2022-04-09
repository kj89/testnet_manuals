echo -e "\e[1m\e[32mUpdating seeds... \e[0m" && sleep 1
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq
wget -O seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/.aptos/config/public_full_node.yaml seeds.yaml
systemctl restart aptosd
