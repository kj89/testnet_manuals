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
echo -e "\e[1m\e[32mReplace <NODENAME> below with the name of your node\e[0m"
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
source ~/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e '================================================='
sleep 3

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update packages
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# update dependencies
sudo apt install curl jq ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y

# update executables
cd $HOME
sudo rm -rf tidechain
APP_VERSION=$(curl -s https://api.github.com/repos/tidelabs/tidechain/releases/latest | jq -r ".tag_name")
wget -O tidechain https://github.com/tidelabs/tidechain/releases/download/${APP_VERSION}/tidechain
sudo chmod +x tidechain
sudo mv tidechain /usr/local/bin/

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create tidechain service 
sudo tee <<EOF >/dev/null /etc/systemd/system/tidechaind.service
[Unit]
Description=Tidechain Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which tidechain) \\
--chain lagoon \\
--pruning archive \\
--name $NODENAME
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable tidechaind
sudo systemctl restart tidechaind

echo "==================================================="
echo -e '\e[32mCheck node status\e[39m' && sleep 1
if [[ `service tidechaind status | grep active` =~ "running" ]]; then
  echo -e "Your tidechain node \e[32minstalled and running\e[39m!"
else
  echo -e "Your tidechain node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo -e "Check your node logs: \e[32mjournalctl -fu tidechaind -o cat\e[39m"
sleep 2
