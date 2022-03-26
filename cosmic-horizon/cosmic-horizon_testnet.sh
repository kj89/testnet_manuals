#!/usr/bin/env bash
. ~/.bashrc

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=darkmatter-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Your node name: ' $NODENAME
echo 'Your wallet name: ' $WALLET
echo 'Your chain name: ' $CHAIN_ID
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# install packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu net-tools -y

# install go 1.17.2
ver="1.17.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# install starport
curl https://get.starport.network/starport | bash
sudo mv starport /usr/local/bin/

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
git clone https://github.com/cosmic-horizon/coho.git
cd coho
starport chain build

chmod +x cohod
sudo mv cohod /usr/local/bin/

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# init
cohod init $NODENAME --chain-id $CHAIN_ID

# config
cohod config chain-id $CHAIN_ID
cohod config keyring-backend file

# download genesis
wget -qO $HOME/.coho/config/genesis.json "https://raw.githubusercontent.com/cosmic-horizon/testnets/main/darkmatter-1/genesis.json"

# reset
cohod unsafe-reset-all

# create service
tee /etc/systemd/system/cohod.service > /dev/null <<EOF
[Unit]
  Description=Crescent Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which cohod) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable cohod
sudo systemctl restart cohod

echo '=============== SETUP FINISHED ==================='
echo 'To check logs: journalctl -u cohod -f -o cat'
echo 'To check sync status: curl -s localhost:26657/status'
