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
echo '==================================='
echo 'Your chain id:' $CELESTIA_CHAIN
echo 'Your app version:' $CELESTIA_APP_VERSION
echo 'Your node version:' $CELESTIA_NODE_VERSION
echo '==================================='


function setupSwap {
	echo -e '\e[32mSet up swapfile\e[39m'
	curl -s https://raw.githubusercontent.com/kj89/testnet_manuals/main/configs/swap4.sh | bash
}


function setupVarsApp {
	if [[ ! $CELESTIA_NODENAME ]]; then
		read -p "Enter your node name: " CELESTIA_NODENAME
		echo 'export CELESTIA_NODENAME='${CELESTIA_NODENAME} >> $HOME/.bash_profile
	fi
	. $HOME/.bash_profile
	echo -e '\e[32mYour node name:' $CELESTIA_NODENAME '\e[39m'
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
	echo -e '\e[32mYour wallet name:' $CELESTIA_WALLET '\e[39m'
	echo -e '\e[32mYour wallet password:' $CELESTIA_PASSWORD '\e[39m'
	sleep 5
}


function setupVarsNodeBridge {
	if [ ! $CELESTIA_RPC_IP ]; then
		read -p 'Enter your RPC IP or press enter use default [localhost]: ' CELESTIA_RPC_IP
		CELESTIA_RPC_IP=${CELESTIA_RPC_IP:-localhost}
		echo 'export CELESTIA_RPC_IP='$CELESTIA_RPC_IP >> $HOME/.bash_profile
		. $HOME/.bash_profile
	fi
	TRUSTED_SERVER="http://$CELESTIA_RPC_IP:26657"
	# check response from rpc
	if [ $(curl -LI $TRUSTED_SERVER -o /dev/null -w '%{http_code}\n' -s) != '200' ]; then
		echo 'Endpoint' $TRUSTED_SERVER 'is unreachable! Aborting setup!'
		unset CELESTIA_RPC_IP
		exit 1
	else
		# save vars
		echo 'export TRUSTED_SERVER='${TRUSTED_SERVER} >> $HOME/.bash_profile
		source $HOME/.bash_profile
	fi
	sleep 5
}


function installDeps {
	echo -e '\e[32m...INSTALLING DEPENDENCIES...\e[39m' && sleep 1
	cd $HOME
	sudo apt update
	sudo apt install make clang pkg-config libssl-dev build-essential git jq expect -y < "/dev/null"
	# install go
	if [ -f "/usr/bin/go" ]; then
		echo 'go is already installed'
		go version
	else
		curl https://dl.google.com/go/go1.17.2.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf -
		cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
		. $HOME/.bash_profile
		cp /usr/local/go/bin/go /usr/bin
	fi
}


function installApp {
	echo -e '\e[32m...INSTALLING APP...\e[39m' && sleep 1

	# install celestia app
	rm -rf celestia-app
	cd $HOME
	git clone https://github.com/celestiaorg/celestia-app.git
	cd celestia-app
	git checkout $CELESTIA_APP_VERSION
	make install
}


function installNode {
	echo -e '\e[32m....INSTALLING NODE...\e[39m' && sleep 1
	
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
echo -e '\e[32m...CREATING SERVICE...\e[39m' && sleep 1
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

sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl restart celestia-appd
echo -e '\e[32m...CHECKING NODE STATUS...\e[39m' && sleep 1
if [[ `service celestia-appd status | grep active` =~ "running" ]]; then
  echo -e "Your Celestia node \e[32minstalled successfully\e[39m!"
else
  echo -e "Your Celestia node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
. $HOME/.bash_profile
}


function initNodeBridge {
	echo -e '\e[32m....INITIALIZING BRIDGE NODE...\e[39m' && sleep 1
	# do init
	rm -rf $HOME/.celestia-bridge
	celestia bridge init --core.remote $TRUSTED_SERVER

	# configure p2p
	sed -i.bak -e 's/PeerExchange = false/PeerExchange = true/g' $HOME/.celestia-bridge/config.toml
	BootstrapPeers="[\"/dns4/andromeda.celestia-devops.dev/tcp/2121/p2p/12D3KooWKvPXtV1yaQ6e3BRNUHa5Phh8daBwBi3KkGaSSkUPys6D\", \"/dns4/libra.celestia-devops.dev/tcp/2121/p2p/12D3KooWK5aDotDcLsabBmWDazehQLMsDkRyARm1k7f1zGAXqbt4\", \"/dns4/norma.celestia-devops.dev/tcp/2121/p2p/12D3KooWHYczJDVNfYVkLcNHPTDKCeiVvRhg8Q9JU3bE3m9eEVyY\"]"
	sed -i -e "s|BootstrapPeers *=.*|BootstrapPeers = $BootstrapPeers|" $HOME/.celestia-bridge/config.toml

	# install service
	echo -e '\e[32m...CREATING SERVICE...\e[39m' && sleep 1
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
	sudo systemctl daemon-reload
	sudo systemctl enable celestia-bridge
	sudo systemctl restart celestia-bridge
	echo -e '\e[32m...CHECKING NODE STATUS...\e[39m' && sleep 1
	if [[ `service celestia-bridge status | grep active` =~ "running" ]]; then
	  echo -e "Your Celestia node \e[32minstalled successfully\e[39m!"
	else
	  echo -e "Your Celestia node \e[31mwas not installed correctly\e[39m, please reinstall."
	fi
	. $HOME/.bash_profile
	echo 'To check app logs: journalctl -fu celestia-bridge -o cat'
}

function initNodeLight {
	echo -e '\e[32m....INITIALIZING LIGHT NODE...\e[39m' && sleep 1
	# do init
	rm -rf $HOME/.celestia-light
	celestia light init

	# configure p2p
	BootstrapPeers="[\"/dns4/andromeda.celestia-devops.dev/tcp/2121/p2p/12D3KooWKvPXtV1yaQ6e3BRNUHa5Phh8daBwBi3KkGaSSkUPys6D\", \"/dns4/libra.celestia-devops.dev/tcp/2121/p2p/12D3KooWK5aDotDcLsabBmWDazehQLMsDkRyARm1k7f1zGAXqbt4\", \"/dns4/norma.celestia-devops.dev/tcp/2121/p2p/12D3KooWHYczJDVNfYVkLcNHPTDKCeiVvRhg8Q9JU3bE3m9eEVyY\"]"
	sed -i -e "s|BootstrapPeers *=.*|BootstrapPeers = $BootstrapPeers|" $HOME/.celestia-light/config.toml

	# install service
	echo -e '\e[32m...CREATING SERVICE...\e[39m' && sleep 1
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
	sudo systemctl daemon-reload
	sudo systemctl enable celestia-light
	sudo systemctl restart celestia-light
	echo -e '\e[32m...CHECKING NODE STATUS...\e[39m' && sleep 1
	if [[ `service celestia-light status | grep active` =~ "running" ]]; then
	  echo -e "Your Celestia node \e[32minstalled successfully\e[39m!"
	else
	  echo -e "Your Celestia node \e[31mwas not installed correctly\e[39m, please reinstall."
	fi
	. $HOME/.bash_profile
	echo 'To check app logs: journalctl -fu celestia-light -o cat'
}


function createKey {
cd $HOME/celestia-app
echo -e "\e[32mWait some time before creating key...\e[39m"
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
echo -e '\e[32mYour wallet address:' $CELESTIA_WALLET_ADDRESS '\e[39m'
}


function syncCheck {
. $HOME/.bash_profile
while sleep 3; do
sync_info=`curl -s localhost:26657/status | jq .result.sync_info`
latest_block_height=`echo $sync_info | jq -r .latest_block_height`
echo -en "\r\rCurrent block: \e[32m$latest_block_height\e[39m"
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
	rm $HOME/.bash_profile
	rm /usr/bin/go -rf
}


PS3='Please enter your choice (input your option number and press enter): '
options=("Install App" "Install Bridge" "Install Light" "Sync Status" "Delete" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install App")
            echo -e '\n\e[31mYou choose install app...\e[39m' && sleep 1
			setupVarsApp
			installDeps
			installApp
			initApp
			syncCheck
			break
            ;;
		"Install Bridge")
            echo -e '\n\e[31mYou choose install bridge...\e[39m' && sleep 1
			if [ -d $HOME/.celestia-light ]; then
				echo -e '\n\e[31mPlease avoid installing both types of nodes (bridge, light) on the same instance! Aborting!\e[39m' && sleep 1
				exit 1
			fi
			setupVarsNodeBridge
			installDeps
			installNode
			initNodeBridge
			break
            ;;
		"Install Light")
            echo -e '\n\e[31mYou choose install light...\e[39m' && sleep 1
			if [ -d $HOME/.celestia-bridge ]; then
				echo -e '\n\e[31mPlease avoid installing both types of nodes (bridge, light) on the same instance! Aborting!\e[39m' && sleep 1
				exit 1
			fi
			installDeps
			installNode
			initNodeLight
			break
            ;;
		"Sync Status")
            echo -e '\n\e[31mYou choose sync status...\e[39m' && sleep 1
			syncCheck
			break
            ;;
		"Delete")
            echo -e '\n\e[31mYou choose delete...\e[39m' && sleep 1
			deleteCelestia
			echo -e '\e[32mCelestia was deleted!\e[39m' && sleep 1
			break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done
