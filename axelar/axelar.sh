#!/usr/bin/env bash
. ~/.bashrc

# set ulimit
ulimit -n 16384

# set keyring password
if [ ! $KEYRING_PASSWORD ]; then
	read -p "Enter keyring password: " KEYRING_PASSWORD
	echo 'export KEYRING_PASSWORD='$KEYRING_PASSWORD >> $HOME/.bash_profile
	. ~/.bash_profile
fi

# set tofnd password
if [ ! $TOFND_PASSWORD ]; then
	read -p "Enter tofnd password: " TOFND_PASSWORD
	echo 'export TOFND_PASSWORD='$TOFND_PASSWORD >> $HOME/.bash_profile
	. ~/.bash_profile
fi

# update packages
export DEBIAN_FRONTEND=noninteractive
apt-get update && 
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --allow-change-held-packages &&
    apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -q -y --allow-change-held-packages
sleep 3
sudo apt-get install jq -y && sudo apt-get install snapd -y
sleep 1

# clone app repo
rm -rf axelarate-community
git clone https://github.com/axelarnetwork/axelarate-community.git
cd axelarate-community

## use quicksync for rapid chain data synchronization

# initialize axelar node
KEYRING_PASSWORD=$KEYRING_PASSWORD ./scripts/node.sh -a v0.13.6

# stop axelar node
kill -9 $(pgrep -f "axelard start")

# remove axelar data
rm -r ~/.axelar_testnet/.core/data

# download and extract testnet snapshot
wget https://dl2.quicksync.io/axelartestnet-lisbon-3-pruned.20220226.2240.tar.lz4
lz4 -dc --no-sparse axelartestnet-lisbon-3-pruned.20220226.2240.tar.lz4 | tar xfC - ~/.axelar_testnet/.core

# start axelar node
KEYRING_PASSWORD=$KEYRING_PASSWORD ./scripts/node.sh -n testnet
cp $HOME/.axelar_testnet/bin/axelard /usr/local/bin
