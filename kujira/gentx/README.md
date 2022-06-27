<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/172356220-b8326ceb-9950-4226-b66e-da69099aaf6e.png">
</p>

# Generate Kujira Mainnet Gentx

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=kaiyo-1" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt-get install make build-essential gcc git jq chrony -y
```

## Install go
```
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
```

## Download and install binaries
```
https://github.com/Team-Kujira/core.git
cd core
make install
```

## Config app
```
kujirad config chain-id $QUICKSILVER_CHAIN_ID
kujirad config keyring-backend test
```

## Init node
kujirad init $NODENAME --chain-id $CHAIN_ID

## Recover or create new wallet for mainnet
Option 1 - generate new wallet
```
kujirad keys add $WALLET
```

Option 2 - recover existing wallet
```
kujirad keys add $WALLET --recover
```

## Add genesis account
```
WALLET_ADDRESS=$(kujirad keys show $WALLET -a)
kujirad add-genesis-account $WALLET_ADDRESS 100000000ukuji
```

## Generate gentx
```
kujirad gentx $WALLET 99000000ukuji \
--chain-id $CHAIN_ID \
--moniker=$NODENAME \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--security-contact="admin@kjnodes.com" \
--website="https://kjnodes.com"
```

## Things you have to backup
- `12 word mnemonic` of your generated wallet
- contents of `$HOME/.kujira/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.kujirad/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/Team-Kujira/networks
3. Create a file gentx-{{VALIDATOR_NAME}}.json under the `networks/mainnet/gentx` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!