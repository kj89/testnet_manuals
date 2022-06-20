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
sudo apt install tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq -y --no-install-recommends
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq
# install rust
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
sudo mkdir -p /var/sui
cd $HOME && rm sui -rf
git clone https://github.com/MystenLabs/sui.git && cd sui
git remote add upstream https://github.com/MystenLabs/sui
git fetch upstream
git checkout --track upstream/devnet
cargo build --release -p sui-node
sudo mv ~/sui/target/release/sui-node /usr/local/bin/

# set configuration
wget -O /var/sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
sudo cp crates/sui-config/data/fullnode-template.yaml /var/sui/fullnode.yaml
sudo yq e -i '.db-path="/var/sui/db"' /var/sui/fullnode.yaml \
&& yq e -i '.genesis.genesis-file-location="/var/sui/genesis.blob"' /var/sui/fullnode.yaml \
&& yq e -i '.metrics-address="0.0.0.0:9184"' /var/sui/fullnode.yaml \
&& yq e -i '.json-rpc-address="0.0.0.0:9000"' /var/sui/fullnode.yaml

# start service
echo "[Unit]
Description=Sui Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/sui-node --config-path /var/sui/fullnode.yaml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/suid.service
mv $HOME/suid.service /etc/systemd/system/

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl restart suid

echo "==================================================="
echo -e '\e[32mCheck node status\e[39m' && sleep 1
if [[ `service suid status | grep active` =~ "running" ]]; then
  echo -e "Your Sui node \e[32minstalled and running\e[39m!"
else
  echo -e "Your Sui node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo -e "Check your node logs: \e[journalctl -fu suid -o cat\e[39m\n\n"

echo -e "To register your Sui node:"
echo -e "1. Join Sui Discord: \e[32mhttps://discord.gg/b5vWu33f\e[39m"
echo -e "2. Paste your node rpc endpoint url \e[32mhttp://$(curl -s ifconfig.me):9000\e[39m into \e[32m#📋node-ip-application\e[39m channel"
