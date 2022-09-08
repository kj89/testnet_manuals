#!/bin/bash


echo "============================================================"
echo "Install start"
echo "============================================================"
echo "Setup NodeName:"
echo "============================================================"
read STAFI_NODENAME
echo "============================================================"

echo export STAFI_NODENAME=${STAFI_NODENAME} >> $HOME/.bash_profile
echo export STAFI_CHAIN_ID=stafihub-testnet-1 >> $HOME/.bash_profile
echo export STAFI_PORT=18 >> $HOME/.bash_profile
source ~/.bash_profile

#UPDATE APT
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

#INSTALL GO
wget https://golang.org/dl/go1.18.3.linux-amd64.tar.gz; \
rm -rv /usr/local/go; \
tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz && \
rm -v go1.18.3.linux-amd64.tar.gz && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version

rm -rf $HOME/stafihub $HOME/.stafihub
cd $HOME
#INSTALL
git clone --branch public-testnet https://github.com/stafihub/stafihub
cd $HOME/stafihub
make install

rm $HOME/.stafihub/config/genesis.json
stafihubd init $STAFI_NODENAME --chain-id $STAFI_CHAIN_ID
stafihubd config chain-id $STAFI_CHAIN_ID


stafihubd tendermint unsafe-reset-all --home ~/.stafihub
rm $HOME/.stafihub/config/genesis.json
wget -O $HOME/.stafihub/config/genesis.json "https://raw.githubusercontent.com/tore19/network/main/testnets/stafihub-testnet-1/genesis.json"
wget -O $HOME/.stafihub/config/addrbook.json "https://raw.githubusercontent.com/StakeTake/guidecosmos/main/stafihub/stafihub-testnet-1/addrbook.json"
external_address=$(wget -qO- eth0.me)
peers="4e2441c0a4663141bb6b2d0ea4bc3284171994b6@46.38.241.169:26656,79ffbd983ab6d47c270444f517edd37049ae4937@23.88.114.52:26656"
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.stafihub/config/config.toml
# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.stafihub/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.stafihub/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.stafihub/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.stafihub/config/app.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.01ufis\"/" $HOME/.stafihub/config/app.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stafihub/config/app.toml
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${STAFI_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${STAFI_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${STAFI_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${STAFI_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${STAFI_PORT}660\"%" $HOME/.stafihub/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${STAFI_PORT}317\"%; s%^address = \":8080\"%address = \":${STAFI_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${STAFI_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${STAFI_PORT}091\"%" $HOME/.stafihub/config/app.toml


tee $HOME/stafihubd.service > /dev/null <<EOF
[Unit]
Description=stafihub
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which stafihubd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sudo mv $HOME/stafihubd.service /etc/systemd/system/
# start service
sudo systemctl daemon-reload
sudo systemctl enable stafihubd
sudo systemctl restart stafihubd
