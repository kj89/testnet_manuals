#!/bin/bash

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

# devnet configuration
CELESTIA_APP_VERSION=$(curl -s "https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/latest_app.txt")
CELESTIA_NODE_VERSION=$(curl -s "https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/latest_node.txt")
echo 'export CELESTIA_CHAIN=devnet-2' >> $HOME/.bash_profile
. $HOME/.bash_profile
echo -e '\n\e[45mYour chain id:' $CELESTIA_CHAIN '\e[0m\n'
echo -e '\n\e[45mYour app version:' $CELESTIA_APP_VERSION '\e[0m\n'
echo -e '\n\e[45mYour node version:' $CELESTIA_NODE_VERSION '\e[0m\n'
sleep 5


function setupSwap {
	echo -e '\n\e[45mSet up swapfile\e[0m\n'
	curl -s https://raw.githubusercontent.com/kj89/testnet_manuals/main/configs/swap4.sh | bash
}


function setupVarsApp {
	if [[ ! $CELESTIA_NODENAME ]]; then
		read -p "Enter your node name: " CELESTIA_NODENAME
		echo 'export CELESTIA_NODENAME='${CELESTIA_NODENAME} >> $HOME/.bash_profile
	fi
	. $HOME/.bash_profile
	echo -e '\n\e[45mYour node name:' $CELESTIA_NODENAME '\e[0m\n'
	sleep 5
}


function setupVarsValidator {
	if [[ ! $CELESTIA_WALLET ]]; then
		read -p "Enter wallet name: " CELESTIA_WALLET
		echo 'export CELESTIA_WALLET='${CELESTIA_WALLET} >> $HOME/.bash_profile
	fi
	if [[ ! $CELESTIA_PASSWORD ]]; then
		read -p "Enter wallet password: " CELESTIA_PASSWORD
		echo 'export CELESTIA_PASSWORD='${CELESTIA_PASSWORD} >> $HOME/.bash_profile
	fi
	. $HOME/.bash_profile
	echo -e '\n\e[45mYour wallet name:' $CELESTIA_WALLET '\e[0m\n'
	echo -e '\n\e[45mYour wallet password:' $CELESTIA_PASSWORD '\e[0m\n'
	sleep 5
}


function setupVarsNodeBridge {
	if [ ! $CELESTIA_VALIDATOR_IP ]; then
		read -p "Enter your validator IP or press enter use default [localhost]: " CELESTIA_VALIDATOR_IP
		CELESTIA_VALIDATOR_IP=${CELESTIA_VALIDATOR_IP:-localhost}
		echo 'export CELESTIA_VALIDATOR_IP='$CELESTIA_VALIDATOR_IP >> $HOME/.bash_profile
		. $HOME/.bash_profile
	fi
	sleep 5
}


function installDeps {
	echo -e '\n\e[45mPreparing to install\e[0m\n' && sleep 1
	cd $HOME
	sudo apt update
	sudo apt install make clang pkg-config libssl-dev build-essential git jq expect -y < "/dev/null"
	# install go
	if [ -z "go version | grep 1.17.2" ]; then
		curl https://dl.google.com/go/go1.17.2.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf -
		cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
		. $HOME/.bash_profile
		cp /usr/local/go/bin/go /usr/bin;
	fi
}


function installApp {
	echo -e '\n\e[45mInstall app\e[0m\n' && sleep 1

	# install celestia app
	rm -rf celestia-app
	cd $HOME
	git clone https://github.com/celestiaorg/celestia-app.git
	cd celestia-app
	git checkout $CELESTIA_APP_VERSION
	make install
}


function installNode {
	echo -e '\n\e[45mInstall node\e[0m\n' && sleep 1
	
	# install celestia node
	cd $HOME
	rm -rf celestia-node
	git clone https://github.com/celestiaorg/celestia-node.git
	cd celestia-node/
	git checkout $CELESTIA_NODE_VERSION
	make install
}


function initApp {
# init celestia app
celestia-appd init $CELESTIA_NODENAME --chain-id $CELESTIA_CHAIN

# install celestia networks
cd $HOME
git clone https://github.com/celestiaorg/networks.git

# set network configs
cp $HOME/networks/$CELESTIA_CHAIN/genesis.json  $HOME/.celestia-app/config/

# update seeds
seeds='"74c0c793db07edd9b9ec17b076cea1a02dca511f@46.101.28.34:26656"'
echo $seeds
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/" $HOME/.celestia-app/config/config.toml

# open rpc
sed -i 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:26657"#g' $HOME/.celestia-app/config/config.toml

# set proper defaults
sed -i 's/timeout_commit = "5s"/timeout_commit = "15s"/g' $HOME/.celestia-app/config/config.toml
sed -i 's/index_all_keys = false/index_all_keys = true/g' $HOME/.celestia-app/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="5000"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.celestia-app/config/app.toml

# reset
celestia-appd unsafe-reset-all

# download address book
wget -O $HOME/.celestia-app/config/addrbook.json "https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/addrbook.json"

# set client config
celestia-appd config chain-id $CELESTIA_CHAIN
celestia-appd config keyring-backend test

# install service
echo -e '\n\e[45mCreating a service\e[0m\n' && sleep 1
echo "[Unit]
Description=celestia-appd Cosmos daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/go/bin/celestia-appd start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" > $HOME/celestia-appd.service
sudo mv $HOME/celestia-appd.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e '\n\e[45mRunning a service\e[0m\n' && sleep 1
sudo systemctl enable celestia-appd
sudo systemctl restart celestia-appd
echo -e '\n\e[45mCheck node status\e[0m\n' && sleep 1
if [[ `service celestia-appd status | grep active` =~ "running" ]]; then
  echo -e "Your Celestia node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice celestia-appd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Celestia node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
. $HOME/.bash_profile
}


function initNodeBridge {
# add protocol and port
TRUSTED_SERVER="http://$CELESTIA_VALIDATOR_IP:26657"

# save vars
echo 'export TRUSTED_SERVER='${TRUSTED_SERVER} >> $HOME/.bash_profile
source $HOME/.bash_profile

# do init
celestia bridge init --core.remote $TRUSTED_SERVER

# configure p2p
sed -i.bak -e 's/PeerExchange = false/PeerExchange = true/g' $HOME/.celestia-bridge/config.toml
BootstrapPeers="[\"/dns4/andromeda.celestia-devops.dev/tcp/2121/p2p/12D3KooWKvPXtV1yaQ6e3BRNUHa5Phh8daBwBi3KkGaSSkUPys6D\", \"/dns4/libra.celestia-devops.dev/tcp/2121/p2p/12D3KooWK5aDotDcLsabBmWDazehQLMsDkRyARm1k7f1zGAXqbt4\", \"/dns4/norma.celestia-devops.dev/tcp/2121/p2p/12D3KooWHYczJDVNfYVkLcNHPTDKCeiVvRhg8Q9JU3bE3m9eEVyY\"]"
sed -i -e "s|BootstrapPeers *=.*|BootstrapPeers = $BootstrapPeers|" $HOME/.celestia-bridge/config.toml

# install service
	echo -e '\n\e[45mCreating a service\e[0m\n' && sleep 1
	echo "[Unit]
Description=celestia-bridge node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which celestia) bridge start
Restart=on-failure
RestartSec=10
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" > $HOME/celestia-bridge.service
	sudo mv $HOME/celestia-bridge.service /etc/systemd/system
	sudo systemctl restart systemd-journald
	sudo systemctl daemon-reload
	echo -e '\n\e[45mRunning a service\e[0m\n' && sleep 1
	sudo systemctl enable celestia-bridge
	sudo systemctl restart celestia-bridge
	echo -e '\n\e[45mCheck node status\e[0m\n' && sleep 1
	if [[ `service celestia-bridge status | grep active` =~ "running" ]]; then
	  echo -e "Your Celestia node \e[32minstalled and works\e[39m!"
	  echo -e "You can check node status by the command \e[7mservice celestia-bridge status\e[0m"
	  echo -e "Press \e[7mQ\e[0m for exit from status menu"
	else
	  echo -e "Your Celestia node \e[31mwas not installed correctly\e[39m, please reinstall."
	fi
	. $HOME/.bash_profile
	echo 'To check app logs: journalctl -fu celestia-bridge -o cat'
}

function initNodeLight {
	# do init
	rm -rf $HOME/.celestia-light
	celestia light init

	# configure p2p
	BootstrapPeers="[\"/dns4/andromeda.celestia-devops.dev/tcp/2121/p2p/12D3KooWKvPXtV1yaQ6e3BRNUHa5Phh8daBwBi3KkGaSSkUPys6D\", \"/dns4/libra.celestia-devops.dev/tcp/2121/p2p/12D3KooWK5aDotDcLsabBmWDazehQLMsDkRyARm1k7f1zGAXqbt4\", \"/dns4/norma.celestia-devops.dev/tcp/2121/p2p/12D3KooWHYczJDVNfYVkLcNHPTDKCeiVvRhg8Q9JU3bE3m9eEVyY\"]"
	sed -i -e "s|BootstrapPeers *=.*|BootstrapPeers = $BootstrapPeers|" $HOME/.celestia-light/config.toml

	# install service
	echo -e '\n\e[45mCreating a service\e[0m\n' && sleep 1
	echo "[Unit]
Description=celestia-light node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which celestia) light start
Restart=on-failure
RestartSec=10
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" > $HOME/celestia-light.service
	sudo mv $HOME/celestia-light.service /etc/systemd/system
	sudo systemctl restart systemd-journald
	sudo systemctl daemon-reload
	echo -e '\n\e[45mRunning a service\e[0m\n' && sleep 1
	sudo systemctl enable celestia-light
	sudo systemctl restart celestia-light
	echo -e '\n\e[45mCheck node status\e[0m\n' && sleep 1
	if [[ `service celestia-light status | grep active` =~ "running" ]]; then
	  echo -e "Your Celestia node \e[32minstalled and works\e[39m!"
	  echo -e "You can check node status by the command \e[7mservice celestia-light status\e[0m"
	  echo -e "Press \e[7mQ\e[0m for exit from status menu"
	else
	  echo -e "Your Celestia node \e[31mwas not installed correctly\e[39m, please reinstall."
	fi
	. $HOME/.bash_profile
	echo 'To check app logs: journalctl -fu celestia-light -o cat'
}


function createKey {
cd $HOME/celestia-app
echo -e "\n\e[45mWait some time before creating key...\e[0m\n"
sleep 20
sudo tee <<EOF >/dev/null $HOME/celestia-app/celestia_add_key.sh
#!/usr/bin/expect -f
EOF
echo "set timeout -1
spawn celestia-appd keys add $CELESTIA_WALLET --home $HOME/celestia-appd
match_max 100000
expect -exact \"Enter keyring passphrase:\"
send -- \"$CELESTIA_PASSWORD\r\"
expect -exact \"\r
Re-enter keyring passphrase:\"
send -- \"$CELESTIA_PASSWORD\r\"
expect eof" >> $HOME/celestia-app/celestia_add_key.sh
sudo chmod +x $HOME/celestia-app/celestia_add_key.sh
$HOME/celestia-app/celestia_add_key.sh &>> $HOME/celestia-app/$CELESTIA_WALLET.txt
echo -e "You can find your mnemonic by the following command:"
echo -e "\e[32mcat $HOME/celestia-app/$CELESTIA_WALLET.txt\e[39m"
export CELESTIA_WALLET_ADDRESS=`cat $HOME/celestia-app/$CELESTIA_WALLET.txt | grep address | awk '{split($0,addr," "); print addr[2]}' | sed 's/.$//'`
echo 'export CELESTIA_WALLET_ADDRESS='${CELESTIA_WALLET_ADDRESS} >> $HOME/.bash_profile
. $HOME/.bash_profile
echo -e '\n\e[45mYour wallet address:' $CELESTIA_WALLET_ADDRESS '\e[0m\n'
}


function syncCheck {
. $HOME/.bash_profile
while sleep 1; do
sync_info=`curl -s localhost:26657/status | jq .result.sync_info`
latest_block_height=`echo $sync_info | jq -r .latest_block_height`
echo -en "\r\rCurrent block: $latest_block_height"
if test `echo "$sync_info" | jq -r .catching_up` == false; then
echo -e "\nYour node was \e[32msynced\e[39m!"
break
else
echo -n ", syncing..."
fi
done
}


function deleteCelestia {
	systemctl disable celestia-appd.service
	systemctl disable celestia-bridge.service
	systemctl disable celestia-light.service
	systemctl stop celestia-appd.service
	systemctl stop celestia-bridge.service
	systemctl stop celestia-light.service
	rm /etc/systemd/system/celestia-appd.service
	rm /etc/systemd/system/celestia-bridge.service
	rm /etc/systemd/system/celestia-light.service
	systemctl daemon-reload
	systemctl reset-failed
	rm .celestia* -rf
	rm celestia* -rf
	rm networks -rf
	rm .bash_profile
}


PS3='Please enter your choice (input your option number and press enter): '
options=("Install App" "Install Bridge" "Install Light" "Sync Status" "Delete" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install App")
            echo -e '\n\e[45mYou choose install app...\e[0m\n' && sleep 1
			setupVarsApp
			setupSwap
			installDeps
			installApp
			initApp
			syncCheck
			echo -e '\n\e[45mDone!\e[0m\n'
			break
            ;;
		"Install Bridge")
            echo -e '\n\e[31mYou choose install bridge...\e[0m\n' && sleep 1
			setupVarsNodeBridge
			setupSwap
			installDeps
			installNode
			initNodeBridge
			break
            ;;
		"Install Light")
            echo -e '\n\e[31mYou choose install light...\e[0m\n' && sleep 1
			setupSwap
			installDeps
			installNode
			initNodeLight
			break
            ;;
		"Sync Status")
            echo -e '\n\e[31mYou choose sync status...\e[0m\n' && sleep 1
			syncCheck
			break
            ;;
		"Delete")
            echo -e '\n\e[31mYou choose delete...\e[0m\n' && sleep 1
			deleteCelestia
			echo -e '\n\e[45mCelestia was deleted!\e[0m\n' && sleep 1
			break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done
