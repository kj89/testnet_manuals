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
# update packages
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# update dependencies
sudo apt install curl jq ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y

# update executables
cd $HOME
sudo rm -rf peaq-node
APP_VERSION=$(curl -s https://api.github.com/repos/peaqnetwork/peaq-network-node/releases/latest | jq -r ".tag_name")
wget -O peaq-node.tar.gz https://github.com/peaqnetwork/peaq-network-node/releases/download/${APP_VERSION}/peaq-node-${APP_VERSION}.tar.gz
sudo tar zxvf peaq-node.tar.gz
sudo chmod +x peaq-node
sudo mv peaq-node /usr/local/bin/

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create peaq-node service 
sudo tee <<EOF >/dev/null /etc/systemd/system/peaqd.service
[Unit]
Description=Peaq Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which peaq-node) \\
--base-path ./chain-data \\
--chain agung \\
--port 1033 \\
--ws-port 9944 \\
--rpc-port 9933 \\
--rpc-cors all \\
--pruning archive \\
--name ro_full_node_0
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable peaqd
sudo systemctl restart peaqd

echo "==================================================="
echo -e '\e[32mCheck node status\e[39m' && sleep 1
if [[ `service peaqd status | grep active` =~ "running" ]]; then
  echo -e "Your peaq node \e[32minstalled and running\e[39m!"
else
  echo -e "Your peaq node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo -e "Check your node logs: \e[32mjournalctl -fu peaqd -o cat\e[39m"
sleep 2
