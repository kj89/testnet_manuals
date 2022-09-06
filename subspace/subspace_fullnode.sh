#!/bin/bash

sleep 2

# set vars
echo -e "\e[1m\e[32mReplace <SUBNODENAME> below with the name of your node\e[0m"
if [ ! $SUBNODENAME ]; then
	read -p "Enter node name: " SUBNODENAME
	echo 'export SUBNODENAME='$SUBNODENAME >> $HOME/.bash_profile
fi
echo -e "\e[1m\e[32mReplace <SUBWALLET_ADDRESS> below with your account address from Polkadot.js wallet\e[0m"
if [ ! $SUBWALLET_ADDRESS ]; then
	read -p "Enter wallet address: " SUBWALLET_ADDRESS
	echo 'export SUBWALLET_ADDRESS='$SUBWALLET_ADDRESS >> $HOME/.bash_profile
fi
echo -e "\e[1m\e[32mReplace <SUBPLOT_SIZE> with plot size in gigabytes or terabytes, for instance 100G or 2T (but leave at least 10G of disk space for node)\e[0m"
if [ ! $SUBPLOT_SIZE ]; then
	read -p "Enter plot size: " SUBPLOT_SIZE
	echo 'export SUBPLOT_SIZE='$SUBPLOT_SIZE >> $HOME/.bash_profile
fi
source ~/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$SUBNODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$SUBWALLET_ADDRESS\e[0m"
echo -e "Your plot size: \e[1m\e[32m$SUBPLOT_SIZE\e[0m"
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
rm -rf subspace-*
wget -O subspace-node https://github.com/subspace/subspace/releases/download/gemini-2a-2022-sep-06/subspace-node-ubuntu-x86_64-gemini-2a-2022-sep-06
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/gemini-2a-2022-sep-06/subspace-farmer-ubuntu-x86_64-gemini-2a-2022-sep-06
chmod +x subspace-*
mv subspace-* /usr/local/bin/

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create subspace-node service 
sudo tee <<EOF >/dev/null /etc/systemd/system/subspaced.service
[Unit]
Description=Subspace Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which subspace-node) \\
--chain="gemini-2a" \\
--execution="wasm" \\
--state-pruning="archive" \\
--validator \\
--name="$SUBNODENAME"
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# create subspaced-farmer service 
sudo tee <<EOF >/dev/null /etc/systemd/system/subspaced-farmer.service
[Unit]
Description=Subspace Farmer
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which subspace-farmer) farm \\
--reward-address=$SUBWALLET_ADDRESS \\
--plot-size=$SUBPLOT_SIZE
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
subspace-farmer wipe
subspace-node purge-chain --chain gemini-1 -y
sleep 5
systemctl restart subspaced
sleep 20
systemctl restart subspaced-farmer
sleep 5

echo "==================================================="
echo -e '\e[32mCheck node status\e[39m' && sleep 1
if [[ `service subspaced status | grep active` =~ "running" ]]; then
  echo -e "Your Subspace node \e[32minstalled and running\e[39m!"
else
  echo -e "Your Subspace node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo -e "Check your node logs: \e[journalctl -fu subspaced -o cat\e[39m"
sleep 2
echo "==================================================="
echo -e '\e[32mCheck farmer status\e[39m' && sleep 1
if [[ `service subspaced-farmer status | grep active` =~ "running" ]]; then
  echo -e "Your Subspace farmer \e[32minstalled and running\e[39m!"
else
  echo -e "Your Subspace farmer \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo -e "Check your farmer logs \e[32mjournalctl -fu subspaced-farmer -o cat\e[39m"
echo -e "If you are having issues please try to restart farmer service: \e[32msystemctl restart subspaced-farmer\e[39m"
