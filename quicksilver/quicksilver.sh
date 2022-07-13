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
QUICKSILVER_PORT=11
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export QUICKSILVER_CHAIN_ID=killerqueen-1" >> $HOME/.bash_profile
echo "export QUICKSILVER_PORT=${QUICKSILVER_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$QUICKSILVER_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$QUICKSILVER_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
rm quicksilver -rf
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.4.0
cd quicksilver
make build
sudo chmod +x ./build/quicksilverd && sudo mv ./build/quicksilverd /usr/local/bin/quicksilverd

# config
quicksilverd config chain-id $QUICKSILVER_CHAIN_ID
quicksilverd config keyring-backend test
quicksilverd config node tcp://localhost:${QUICKSILVER_PORT}657

# init
quicksilverd init $NODENAME --chain-id $QUICKSILVER_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.quicksilverd/config/genesis.json "https://raw.githubusercontent.com/ingenuity-build/testnets/main/killerqueen/genesis.json"

# set peers and seeds
SEEDS="dd3460ec11f78b4a7c4336f22a356fe00805ab64@seed.killerqueen-1.quicksilver.zone:26656"
PEERS="fbfaf93f9c508f53875584db8a953c879b5fde93@62.141.45.22:44656,48d6e6f74b22599fb80b63e3df15107057678701@142.132.213.50:26656,c73e0f1af31eec4652992b410ca7862622b9ec08@65.108.135.213:26756,90ac25d4eb949d0c96d035b440bf43d38983910c@167.235.60.58:26656,3c8dbb7ac3bea1baab2dbef6f30fec8e9ccbf20f@150.158.152.166:26656,08e9c9d61b66a29f3bb777cf32da0cf0478ff9e8@81.68.181.186:26656,d8cd956350252da5f43e3d2cb9c404f2beeb2430@43.156.26.121:26656,4d397f3548dc90f0d5377d144dfb41667004a0f1@176.116.87.5:26656,3d600e16fc5070ad591877889a8198c203a799cb@124.223.87.231:26656,5f5eb201298af5a6f6e9bd5eed1c01ba329f83f2@178.236.129.143:26656,23be55e923172df0ccd3b437962c70cddb6ab814@142.93.150.22:26656,1e201ae20e650c7a6de6c4961c7ec9bbc49b99c7@164.68.119.26:26656,d52a4dc04658f3b0f20874a571788ceb9b7bada4@124.223.66.120:26656,1fdc86d5e36c4ead4cfc79da9b57569b7d72cabc@193.122.107.99:26656,46d2eb9953403de555369ab5d144c713a6e5b960@144.76.67.53:2390,0e7dcc9313cefbdbc4b7b00931a04c4e78f4da5f@88.208.57.200:46656,77481c2bfffb141da24e1f3ef931a330b3b9bba4@164.92.90.14:11656,8cf285b8aaf60744d561640651a0557ea56c8a00@124.223.26.171:26656,469e4cac6d3454c911594412e5731097ab38be1a@95.111.229.221:26656,308dbd671f5c5c9520af2944fd960a0ccfdb33be@134.249.85.64:26656,288948102bb3025c52209ab6ac708d95e9aecef1@124.223.107.85:26656,53e64bfb9572f890c06c4c95062a93cad6c5e8b5@188.9.122.183:26656,b730363c80a74560b35f60abc663539e58d25552@46.38.243.16:11656,2f54f2f9feaa1c89a767ed17506a3e5ed9275bcc@146.0.40.114:11656,987456d197614b2eb927f5e9fd3c200e6e926eac@175.24.183.235:26656,31ff74d28c9f6a81c0786ef6e6dda98004c3bcbd@1.15.185.171:26656,fa9790558b91a835c9eceffc231b3f63c7c15298@140.238.96.20:26656,015baa30ea5c71efa37ba7bf9fb2f7c61fcb32a2@146.56.128.144:26656,6d199195e710f8fbee5d729735941ae65ddd9adf@94.130.180.23:11656,87b9d7ef60e4c90cc9dc7dc7341167445a774e74@124.223.107.100:26656,245502cb4c2ccd62f4d56293d9ca341a57b22908@129.226.156.253:26656,888d27502f5e687849013ea1cb420e8421528cbf@65.109.0.101:11656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.quicksilverd/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${QUICKSILVER_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${QUICKSILVER_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${QUICKSILVER_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${QUICKSILVER_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${QUICKSILVER_PORT}660\"%" $HOME/.quicksilverd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${QUICKSILVER_PORT}317\"%; s%^address = \":8080\"%address = \":${QUICKSILVER_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${QUICKSILVER_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${QUICKSILVER_PORT}091\"%" $HOME/.quicksilverd/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.quicksilverd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.quicksilverd/config/app.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uqck\"/" $HOME/.quicksilverd/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.quicksilverd/config/config.toml

# reset
quicksilverd tendermint unsafe-reset-all --home $HOME/.quicksilverd

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/quicksilverd.service > /dev/null <<EOF
[Unit]
Description=quicksilver
After=network-online.target

[Service]
User=$USER
ExecStart=$(which quicksilverd) --home $HOME/.quicksilverd start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable quicksilverd
sudo systemctl restart quicksilverd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u quicksilverd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${QUICKSILVER_PORT}657/status | jq .result.sync_info\e[0m"
