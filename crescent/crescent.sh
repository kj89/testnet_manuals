#!/usr/bin/env bash
# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=crescent-1" >> $HOME/.bash_profile
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

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download and install mainnet binary
git clone https://github.com/crescent-network/crescent
cd crescent
git checkout v1.0.0
make install

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# init
crescentd init ${NODENAME} --chain-id $CHAIN_ID

# config
crescentd config chain-id $CHAIN_ID
crescentd config keyring-backend file

# downloag mainnet genesis file
git clone https://github.com/crescent-network/launch
cd launch/mainnet/crescent-1/
tar -zxvf genesis.json.tar.gz
cp genesis.json ~/.crescent/config/genesis.json

# set peers and seeds
SEEDS="929f22a7b04ff438da9edcfebd8089908239de44@18.180.232.184:26656"
PEERS="518dac6b9b5d6aea23698b888802ceff39efcbaf@103.125.219.212:26656,68787e8412ab97d99af7595c46514b9ab4b3df45@54.250.202.17:26656,0ed5ed53ec3542202d02d0d47ac04a2823188fc2@52.194.172.170:26656,04016e800a079c8ee5bdb9361c81c026b6177856@34.146.27.138:26656,24be64cd648958d9f685f95516cb3b248537c386@52.197.140.210:26656,83b3ba06b43fda52c048934498c6ee2bd4987d2d@3.39.144.72:26656,7e59c83196fdc61dcf9d36c42776c0616bc0fc8c@3.115.85.120:26656,06415494b86316c55245d162da065c3c0fee83fc@172.104.108.21:26656,4293ce6b47ee2603236437ab44dc499519c71e62@45.76.97.48:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.crescent/config/config.toml

# set minimum gas price
sed -i.bak -e "s/^minimum-gas-prices = \"\"/minimum-gas-prices = \"0ucre\"/" $HOME/.crescent/config/app.toml

# reset
crescentd unsafe-reset-all

# create service
tee /etc/systemd/system/crescentd.service > /dev/null <<EOF
[Unit]
  Description=Crescent Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which crescentd) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable crescentd
sudo systemctl restart crescentd

echo '=============== SETUP FINISHED ==================='
echo 'To check logs: journalctl -u crescentd -f -o cat'
echo 'To check sync status: curl -s localhost:26657/status'
echo 'Create wallet:'
echo "crescentd keys add $WALLET"
echo 'To generate gentx you need to have 1 CRE:'
echo "crescentd gentx $WALLET 1000000ucre --commission-max-change-rate 0.01 --commission-max-rate 0.2  --commission-rate 0.1 --min-self-delegation 1 --pubkey=$(crescentd tendermint show-validator) --chain-id $CHAIN_ID"
