#!/usr/bin/env bash
. ~/.bashrc

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=mooncat-1-1" >> $HOME/.bash_profile
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
# download binary
git clone https://github.com/crescent-network/crescent
cd crescent
git checkout v1.0.0-rc2
make install

chmod +x crescentd
sudo mv crescentd /usr/local/bin/

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# init
crescentd init ${NODENAME} --chain-id $CHAIN_ID

# config
crescentd config chain-id $CHAIN_ID
crescentd config keyring-backend file

# download addrbook and genesis
git clone https://github.com/crescent-network/launch
cd launch/testnet/
rm ~/.crescent/config/genesis.json
tar -zxvf genesis_collect-gentxs.json.tar.gz
cp genesis_collect-gentxs.json ~/.crescent/config/genesis.json

# set peers and seeds
SEEDS="1fe40daaf2643fd3857e30f86ff30ea82bf1c03b@54.169.204.99:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.crescent/config/config.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ucre\"/" $HOME/.crescent/config/app.toml

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
echo -e 'To check logs: \e[1m\e[32m crescentd -f -o cat\e[0m'
echo -e 'To check sync status: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info\e[0m'
echo 'To generate gentx you need to have 1 CRE:'
echo 'crescentd gentx $WALLET 1000000ucre --commission-max-change-rate 0.01 --commission-max-rate 0.2  --commission-rate 0.1 --min-self-delegation 1 --pubkey=$(crescentd tendermint show-validator) --chain-id $CHAIN_ID'
