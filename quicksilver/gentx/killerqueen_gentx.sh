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
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=killerqueen-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$CHAIN_ID\e[0m"
echo -e '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux -y

# install go
ver="1.18.2"
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
cd $HOME
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.3.0
cd quicksilver
make build
chmod +x ./build/quicksilverd && mv ./build/quicksilverd /usr/local/bin/quicksilverd

# config
quicksilverd config chain-id $CHAIN_ID
quicksilverd config keyring-backend test

# init
quicksilverd init $NODENAME --chain-id $CHAIN_ID

# add wallet
quicksilverd keys add $WALLET

# fund your wallet
WALLET_ADDRESS=$(quicksilverd keys show $WALLET -a)
quicksilverd add-genesis-account $WALLET_ADDRESS 100000000uqck

# generate gentx
quicksilverd gentx $WALLET 100000000uqck \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--pubkey=$(quicksilverd tendermint show-validator) \
--chain-id $CHAIN_ID \
--moniker $NODENAME
sleep 2
gentx=$(readlink -f $HOME/.quicksilverd/config/gentx/*)

echo -e "Your gentx file location: \e[1m\e[32m$gentx\e[0m"
echo -e "Paste this content into the form:\n\e[1m\e[32m$(cat $gentx)\e[0m"
echo "============================================================================"
echo -e "Things you have to backup:"
echo -e "	Wallet \e[1m\e[32m24 word mnemonic\e[0m generated above"
echo -e "	Contents of \e[1m\e[32m$HOME/.quicksilverd/config/\e[0m"
