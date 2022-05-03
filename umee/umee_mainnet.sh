#!/bin/bash
# wget -q -O umee_mainnet.sh https://api.nodes.guru/umee_mainnet.sh && chmod +x umee_mainnet.sh && sudo /bin/bash umee_mainnet.sh

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
sleep 1 && curl -s https://api.nodes.guru/logo.sh | bash && sleep 1

function setupVars {
	if [ ! $NODENAME ]; then
		read -p "Enter node name: " NODENAME
		echo 'export NODENAME='\"${NODENAME}\" >> $HOME/.bash_profile
	fi
	if [ ! $WALLET ]; then
		read -p "Enter wallet name: " WALLET
		echo 'export WALLET='\"${WALLET}\" >> $HOME/.bash_profile
	fi
	echo -e '\n\e[42mYour wallet name:' $WALLET '\e[0m\n'
	if [ ! $WALLET_PASSWORD ]; then
		read -p "Enter wallet password: " WALLET_PASSWORD
		echo 'export WALLET_PASSWORD='\"${WALLET_PASSWORD}\" >> $HOME/.bash_profile
	fi
	echo -e '\n\e[42mYour wallet password:' $WALLET_PASSWORD '\e[0m\n'
	echo 'export CHAIN_ID=umee-1' >> $HOME/.bash_profile
	echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
	. $HOME/.bash_profile
	sleep 1
}

function setupSwap {
	echo -e '\n\e[42mSet up swapfile\e[0m\n'
	curl -s https://api.nodes.guru/swap4.sh | bash
}

function installGo {
	echo -e '\n\e[42mInstall Go\e[0m\n' && sleep 1
	cd $HOME
	wget -O go1.17.1.linux-amd64.tar.gz https://golang.org/dl/go1.17.1.linux-amd64.tar.gz
	rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz && rm go1.17.1.linux-amd64.tar.gz
	echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
	echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
	echo 'export GO111MODULE=on' >> $HOME/.bash_profile
	echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
	go version
}

function installDeps {
	echo -e '\n\e[42mPreparing to install\e[0m\n' && sleep 1
	cd $HOME
	sudo apt update
	sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils -y < "/dev/null"
	installGo
}

function createKey {
echo -e '\n\e[42mGenerating Umee keys...\e[0m\n' && sleep 1
echo -e "\n\e[45mWait some time before creating key...\e[0m\n"
sleep 5
(echo $WALLET_PASSWORD; echo $WALLET_PASSWORD) | $HOME/go/bin/umeed keys add $WALLET --output json &>> $HOME/"$CHAIN_ID"_validator_key.json
echo -e "You can find your mnemonic by the following command:"
echo -e "\e[32mcat $HOME/\"$CHAIN_ID\"_validator_key.json\e[39m"
export WALLET_ADDRESS=`echo $WALLET_PASSWORD | $HOME/go/bin/umeed keys show $WALLET -a`
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
. $HOME/.bash_profile
echo -e '\n\e[45mYour wallet address:' $WALLET_ADDRESS '\e[0m\n'
}

function requestFunds {
echo -e "\n\e[45mRequesting funds...\e[0m\n"
curl -X POST -d "{\"address\": \"$WALLET_ADDRESS\"}" -H "Content-Type: application/json" https://faucet.umee.nodes.guru
echo -e "\n\e[45mVerify balance...\e[0m\n"
sleep 10
umeeAmountTmp=`$HOME/go/bin/umeed q bank balances $WALLET_ADDRESS | grep amount | sed -E 's/.*"([^"]+)".*/\1/'`
if [ "$umeeAmountTmp" -gt 0 ]; then
	echo -e "Your wallet balance was \e[32mfunded\e[39m!"
else
	echo -e "Your wallet balance \e[31mwas not funded\e[39m, please request again.\e[0m"
	echo -e "Request command: \e[7mcurl -X POST -d '{\"address\":\"$WALLET_ADDRESS\"}' -H 'Content-Type: application/json' https://faucet.umee.nodes.guru\e[0m"
	echo -e "Check your wallet balance: \e[7m$(which umeed) q bank balances ${WALLET_ADDRESS}\e[0m"
fi
}

function createValidator {
echo -e "\n\e[45mCreating validator...\e[0m\n"
echo $WALLET_PASSWORD | $HOME/go/bin/umeed tx staking create-validator -y --amount=9500000uumee --pubkey=`$HOME/go/bin/umeed tendermint show-validator` --moniker=$NODENAME --commission-rate=0.10 --commission-max-rate=0.20 --commission-max-change-rate=0.01 --min-self-delegation=1 --from=$WALLET --chain-id=$CHAIN_ID --fees 1000uumee
echo -e "\n\e[45mVerify your validator status...\e[0m\n"
sleep 30
umeeVPTmp=`curl -s localhost:26657/status | jq .result.validator_info.voting_power | sed -E 's/.*"([^"]+)".*/\1/'`
UMEE_VALOPER=$(echo $WALLET_PASSWORD | $HOME/go/bin/umeed keys show $WALLET --bech val -a)
umeeValidatorString=$($HOME/go/bin/umeed query staking validators --limit 1000 -o json | jq -r '.validators[] | [.operator_address, .status] | @csv' | grep $UMEE_VALOPER | column -t -s",")
umeeValidatorStatus=$(echo $umeeValidatorString | awk {'print $2'})
if [ -z "${umeeValidatorString}" ]; then
	echo -e "Your validator was \e[31mnot created\e[39m.\e[0m"
	echo -e "Create validator command: \n\e[7m$HOME/go/bin/umeed tx staking create-validator -y --amount=9500000uumee --pubkey=`$HOME/go/bin/umeed tendermint show-validator` --moniker=$NODENAME --commission-rate=0.10 --commission-max-rate=0.20 --commission-max-change-rate=0.01 --min-self-delegation=1 --from=$WALLET --chain-id=$CHAIN_ID --fees 1000uumee\e[0m"
else
	if [ "$umeeValidatorStatus" = '"BOND_STATUS_BONDED"' ]; then
		echo -e "You are \e[32mactive validator\e[39m now!"
	else
		echo -e "Your validator not in the \e[31mactive validator set\e[39m.\e[0m"
		echo -e "Increase your \e[31mbond\e[39m amount if you want to be in the active validator set.\e[0m"
	fi
fi
}

function syncCheck {
. $HOME/.bash_profile
while sleep 5; do
sync_info=`curl -s localhost:26657/status | jq .result.sync_info`
latest_block_height=`echo $sync_info | jq -r .latest_block_height`
echo -en "\r\rCurrent block: $latest_block_height"
if test `echo "$sync_info" | jq -r .catching_up` == false; then
echo -e "\nYour node was \e[32msynced\e[39m!"
requestFunds
createValidator
break
else
echo -n ", syncing..."
fi
done
}

function installSoftware {
	echo -e '\n\e[42mInstall software\e[0m\n' && sleep 1
	mkdir -p $HOME/data
	cd $HOME
	rm -r $HOME/umee
	git clone --depth 1 --branch v1.0.3 https://github.com/umee-network/umee.git
	cd umee && make install
	umeed version
	umeed init ${NODENAME} --chain-id $CHAIN_ID
	wget -O $HOME/.umee/config/genesis.json "https://raw.githubusercontent.com/umee-network/umee/main/networks/umee-1/genesis.json"
	sha256sum $HOME/.umee/config/genesis.json
	umeed unsafe-reset-all
	sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001uumee\"/" $HOME/.umee/config/app.toml
	sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.umee/config/app.toml
	external_address=`curl ifconfig.me`
	peers="f1dc58164af33f2db6c5a5bd6b2646399b18bbb4@35.187.48.177:26656,6b785fc3a088de3a5e8d222a980936f2187b8c56@34.65.213.164:26656"
	sed -i -e "s/^external_address = \"\"/external_address = \"$external_address:26656\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.umee/config/config.toml
}

function updateSoftware {
	echo -e '\n\e[42mUpdate software\e[0m\n' && sleep 1
	mkdir -p $HOME/data
	umeed unsafe-reset-all
	cd $HOME
	rm -r $HOME/umee
	git clone --depth 1 --branch v1.0.3 https://github.com/umee-network/umee.git
	cd umee && make install
	umeed version
	rm $HOME/.umee/config/genesis.json
	wget -O $HOME/.umee/config/genesis.json "https://raw.githubusercontent.com/umee-network/umee/main/networks/umee-1/genesis.json"
	umeed unsafe-reset-all
	peers="f1dc58164af33f2db6c5a5bd6b2646399b18bbb4@35.187.48.177:26656,6b785fc3a088de3a5e8d222a980936f2187b8c56@34.65.213.164:26656"
	sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.umee/config/config.toml
	systemctl restart umeed
}

function installService {
echo -e '\n\e[42mRunning\e[0m\n' && sleep 1
echo -e '\n\e[42mCreating a service\e[0m\n' && sleep 1

echo "[Unit]
Description=Umee Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which umeed) start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/umeed.service
sudo mv $HOME/umeed.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1
sudo systemctl enable umeed
sudo systemctl restart umeed
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service umeed status | grep active` =~ "running" ]]; then
  echo -e "Your Umee node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice umeed status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Umee node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
. $HOME/.bash_profile
}

function disableUmeed {
	sudo systemctl disable umeed
	sudo systemctl stop umeed
}

PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Update" "Disable" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
            echo -e '\n\e[42mYou choose install...\e[0m\n' && sleep 1
			setupVars
			setupSwap
			installDeps
			installSoftware
			installService
			createKey
			syncCheck
			break
            ;;
        "Update")
            echo -e '\n\e[33mYou choose update...\e[0m\n' && sleep 1
			setupVars
			updateSoftware
			echo -e '\n\e[33mYour node was updated!\e[0m\n' && sleep 1
			break
            ;;
		"Disable")
            echo -e '\n\e[31mYou choose disable...\e[0m\n' && sleep 1
			disableUmeed
			echo -e '\n\e[42mUmeed was disabled!\e[0m\n' && sleep 1
			break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done