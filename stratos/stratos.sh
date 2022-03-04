#!/bin/bash
# wget -q -O stratos.sh https://api.nodes.guru/stratos.sh && chmod +x stratos.sh && sudo /bin/bash stratos.sh


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
curl -s https://api.nodes.guru/logo.sh | bash && sleep 1

function setupVars {
	if [[ ! $STRATOS_NODENAME ]]; then
		read -p "Enter your node name: " STRATOS_NODENAME
		echo 'export STRATOS_NODENAME='${STRATOS_NODENAME} >> $HOME/.bash_profile
	fi
	echo -e '\n\e[45mYour node name:' $STRATOS_NODENAME '\e[0m\n'
	if [[ ! $STRATOS_WALLET ]]; then
		read -p "Enter wallet name: " STRATOS_WALLET
		echo 'export STRATOS_WALLET='${STRATOS_WALLET} >> $HOME/.bash_profile
	fi
	echo -e '\n\e[45mYour wallet name:' $STRATOS_WALLET '\e[0m\n'
	if [[ ! $STRATOS_PASSWORD ]]; then
		read -p "Enter wallet password: " STRATOS_PASSWORD
		echo 'export STRATOS_PASSWORD='${STRATOS_PASSWORD} >> $HOME/.bash_profile
	fi
	echo -e '\n\e[45mYour wallet password:' $STRATOS_PASSWORD '\e[0m\n'
	. $HOME/.bash_profile
	sleep 1
}

function setupSwap {
	echo -e '\n\e[45mSet up swapfile\e[0m\n'
	curl -s https://api.nodes.guru/swap4.sh | bash
}

function installDeps {
	echo -e '\n\e[45mPreparing to install\e[0m\n' && sleep 1
	cd $HOME
	sudo apt update
	sudo apt install make clang pkg-config libssl-dev build-essential git jq expect -y < "/dev/null"
}

function installSoftware {
	echo -e '\n\e[45mInstall software\e[0m\n' && sleep 1
	mkdir -p $HOME/stratos/config
	cd $HOME/stratos
	wget -O stchaincli https://github.com/stratosnet/stratos-chain/releases/download/v0.6.1/stchaincli 
	wget -O stchaind https://github.com/stratosnet/stratos-chain/releases/download/v0.6.1/stchaind
	chmod +x stchaincli
	chmod +x stchaind
	./stchaind init --home ./ ${STRATOS_NODENAME}
	wget -O genesis.json https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/genesis.json
	wget -O config.toml https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/config.toml
        wget -O addrbook.json https://api.nodes.guru/addrbook_stratos.json
	mv config.toml config/
	mv genesis.json config/
        mv addrbook.json config/
	sed -i.bak "s/^moniker *=.*/moniker = \"$STRATOS_NODENAME\"/" config/config.toml
        peers="d12cd591f7062aa11bf94e79578647e2cac26b86@18.178.110.255:26656,7d9d9366f99e559ebd3c406a1bf0754b0124b704@65.21.201.244:26706"
	sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/stratos/config/config.toml
}

function installService {
echo -e '\n\e[45mRunning\e[0m\n' && sleep 1
echo -e '\n\e[45mCreating a service\e[0m\n' && sleep 1
echo "[Unit]
Description=Stratos Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/stratos/stchaind start --home $HOME/stratos
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/stratosd.service
sudo mv $HOME/stratosd.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e '\n\e[45mRunning a service\e[0m\n' && sleep 1
sudo systemctl enable stratosd
sudo systemctl restart stratosd
echo -e '\n\e[45mCheck node status\e[0m\n' && sleep 1
if [[ `service stratosd status | grep active` =~ "running" ]]; then
  echo -e "Your Stratos node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice stratosd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Stratos node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
. $HOME/.bash_profile
}

function createKey {
cd $HOME/stratos
echo -e "\n\e[45mWait some time before creating key...\e[0m\n"
sleep 20
sudo tee <<EOF >/dev/null $HOME/stratos/stratos_add_key.sh
#!/usr/bin/expect -f
EOF
echo "set timeout -1
spawn $HOME/stratos/stchaincli keys add $STRATOS_WALLET --home $HOME/stratos
match_max 100000
expect -exact \"Enter keyring passphrase:\"
send -- \"$STRATOS_PASSWORD\r\"
expect -exact \"\r
Re-enter keyring passphrase:\"
send -- \"$STRATOS_PASSWORD\r\"
expect eof" >> $HOME/stratos/stratos_add_key.sh
sudo chmod +x $HOME/stratos/stratos_add_key.sh
$HOME/stratos/stratos_add_key.sh &>> $HOME/stratos/$STRATOS_WALLET.txt
echo -e "You can find your mnemonic by the following command:"
echo -e "\e[32mcat $HOME/stratos/$STRATOS_WALLET.txt\e[39m"
export STRATOS_WALLET_ADDRESS=`cat $HOME/stratos/$STRATOS_WALLET.txt | grep address | awk '{split($0,addr," "); print addr[2]}' | sed 's/.$//'`
echo 'export STRATOS_WALLET_ADDRESS='${STRATOS_WALLET_ADDRESS} >> $HOME/.bash_profile
. $HOME/.bash_profile
echo -e '\n\e[45mYour wallet address:' $STRATOS_WALLET_ADDRESS '\e[0m\n'
}

function requestFunds {
echo -e "\n\e[45mRequesting funds...\e[0m\n"
tmpStratosFaucetURL=https://faucet-tropos.thestratos.org/faucet/$STRATOS_WALLET_ADDRESS
stratosFaucetURL=${tmpStratosFaucetURL%$'\r'}
curl -X POST ${stratosFaucetURL}
echo -e "\n\e[45mVerify balance...\e[0m\n"
sleep 10
stratosAmountTmp=`$HOME/stratos/stchaincli query account $STRATOS_WALLET_ADDRESS --home $HOME/stratos | grep amount | sed -E 's/.*"([^"]+)".*/\1/'`
if [ "$stratosAmountTmp" -gt 0 ]; then
	echo -e "Your wallet balance was \e[32mfunded\e[39m!"
else
	echo -e "Your wallet balance \e[31mwas not funded\e[39m, please request again.\e[0m"
	echo -e "Request command: \e[7mcurl -X POST https://faucet-tropos.thestratos.org/faucet/${STRATOS_WALLET_ADDRESS}\e[0m"
	echo -e "Check your wallet balance: \e[7m$HOME/stratos/stchaincli query account ${STRATOS_WALLET_ADDRESS} --home $HOME/stratos\e[0m"
fi
}

function createValidator {
echo -e "\n\e[45mCreating validator...\e[0m\n"
export STRATOS_CHAIN=`cat $HOME/stratos/config/genesis.json | jq .chain_id | sed -E 's/.*"([^"]+)".*/\1/'`
sudo tee <<EOF >/dev/null $HOME/stratos/stratos_create_validator.sh
#!/usr/bin/expect -f
EOF
echo "set timeout -1
spawn $HOME/stratos/stchaincli --home /root/stratos tx staking create-validator -y --amount=99000000000ustos --pubkey=`$HOME/stratos/stchaind --home $HOME/stratos tendermint show-validator` --moniker=$STRATOS_NODENAME --commission-rate=0.10 --commission-max-rate=0.20 --commission-max-change-rate=0.01 --min-self-delegation=1 --from=$STRATOS_WALLET --chain-id=$STRATOS_CHAIN --gas=auto --gas-adjustment=1.4
match_max 100000
expect -exact \"Enter keyring passphrase:\"
send -- \"$STRATOS_PASSWORD\r\"
expect -exact \"\r
Enter keyring passphrase:\"
send -- \"$STRATOS_PASSWORD\r\"
expect eof" >> $HOME/stratos/stratos_create_validator.sh
sudo chmod +x $HOME/stratos/stratos_create_validator.sh
$HOME/stratos/stratos_create_validator.sh
echo -e "\n\e[45mVerify you are have voting power...\e[0m\n"
sleep 10
stratosVPTmp=`curl -s localhost:26657/status | jq .result.validator_info.voting_power | sed -E 's/.*"([^"]+)".*/\1/'`
if [ "$stratosVPTmp" -gt 0 ]; then
	echo -e "Your voting power \e[32mgreater than zero\e[39m!"
	echo -e "You are \e[32mvalidator\e[39m now!"
else
	echo -e "Your voting power equal \e[31mzero\e[39m, please retry.\e[0m"
	echo -e "Command: \e[7m$HOME/stratos/stchaincli --home $HOME/stratos tx staking create-validator -y --amount=99000000000ustos --pubkey=`$HOME/stratos/stchaind --home $HOME/stratos tendermint show-validator` --moniker=$STRATOS_NODENAME --commission-rate=0.10 --commission-max-rate=0.20 --commission-max-change-rate=0.01 --min-self-delegation=1 --from=$STRATOS_WALLET --chain-id=$STRATOS_CHAIN --gas=auto --gas-adjustment=1.4\e[0m"
	echo -e "Check you are validator: \e[7mcurl -s localhost:26657/status | jq .result.validator_info.voting_power | sed -E 's/.*\"([^\"]+)\".*/\1/'\e[0m (should be greater than zero)"
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

function disableStratos {
	sudo systemctl disable stratosd
	sudo systemctl stop stratosd
}

PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Disable" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
            echo -e '\n\e[45mYou choose install...\e[0m\n' && sleep 1
			setupVars
			setupSwap
			installDeps
			installSoftware
			installService
			createKey
			syncCheck
			echo -e '\n\e[45mDone!\e[0m\n'
			break
            ;;
		"Disable")
            echo -e '\n\e[31mYou choose disable...\e[0m\n' && sleep 1
			deleteStratos
			echo -e '\n\e[45mStratos was disabled!\e[0m\n' && sleep 1
			break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done