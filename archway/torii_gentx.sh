if [ ! $NODENAME ]; then
	read -p "Enter your moniker name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

if [ ! $PASSWORD ]; then
	read -p "Enter keyring password: " PASSWORD
	echo 'export PASSWORD='$PASSWORD >> $HOME/.bash_profile
fi

echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=torii-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "==================================="
echo -e "Your moniker name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your chain id: \e[1m\e[32m$CHAIN_ID\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your password name: \e[1m\e[32m$PASSWORD\e[0m"
echo "==================================="
sleep 5

# install go
wget -O go1.17.2.linux-amd64.tar.gz https://golang.org/dl/go1.17.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz && rm go1.17.2.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile

# install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# install binaries
git clone https://github.com/archway-network/archway
cd archway && git checkout main && make install

# init application
archwayd init $NODENAME --chain-id $CHAIN_ID

# generate wallet
echo -e "${PASSWORD}\n${PASSWORD}\n"| archwayd keys add $WALLET

# download genesis and generate gentx file
wget -O $HOME/.archway/config/genesis.json "https://raw.githubusercontent.com/archway-network/testnets/main/torii-1/penultimate_genesis.json"
WALLET_ADDRESS=$(echo ${PASSWORD} | archwayd keys show $WALLET -a)
archwayd add-genesis-account $WALLET_ADDRESS 1001000utorii
echo ${PASSWORD} | archwayd gentx $WALLET 1000000utorii \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--pubkey=$(archwayd tendermint show-validator) \
--chain-id=$CHAIN_ID \
--moniker=$NODENAME \
--details="" \
--website=""
sleep 2

echo -e "Your gentx file location: \e[1m\e[32m$(readlink -f $HOME/.archway/config/gentx/*)\e[0m"
echo "============================================================================"
echo -e "Things you have to backup:"
echo -e "	Wallet \e[1m\e[32m24 word mnemonic\e[0m generated above"
echo -e "	Contents of \e[1m\e[32m$HOME/.archway/config/\e[0m"
