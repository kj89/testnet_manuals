<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>
<p style="font-size:14px" align="right">
<a href="https://m.do.co/c/17b61545ca3a" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus for 60 days <img src="https://user-images.githubusercontent.com/50621007/183284313-adf81164-6db4-4284-9ea0-bcb841936350.png" width="30"/></a>
</p>
<p style="font-size:14px" align="right">
<a href="https://www.vultr.com/?ref=7418642" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus <img src="https://user-images.githubusercontent.com/50621007/183284971-86057dc2-2009-4d40-a1d4-f0901637033a.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/205657849-4fa816f7-6471-4e47-9832-ef9374a706b0.png">
</p>

# Generate paloma mainnet gentx

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=messenger" >> $HOME/.bash_profile
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
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
source ~/.bash_profile
```

## Download and install binaries
```
cd $HOME
git clone https://github.com/palomachain/paloma.git
cd paloma
git checkout v0.11.6
make install
```

## Config app
```
palomad config chain-id $CHAIN_ID
palomad config keyring-backend test
```

## Init node
```
palomad init $NODENAME --chain-id $CHAIN_ID
```

## Recover or create new wallet for mainnet
Option 1 - generate new wallet
```
palomad keys add $WALLET
```

Option 2 - recover existing wallet
```
palomad keys add $WALLET --recover
```

## Add genesis account
```
WALLET_ADDRESS=$(palomad keys show $WALLET -a)
palomad add-genesis-account $WALLET_ADDRESS 10000000ugrain
```

## Generate gentx
```
palomad gentx $WALLET 9000000ugrain \
--chain-id $CHAIN_ID \
--moniker=$NODENAME \
--commission-max-change-rate=0.01 \
--commission-max-rate=1.0 \
--commission-rate=0.05 \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability" \
--min-self-delegation=1
```

## Things you have to backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.paloma/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.paloma/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/palomachain/mainnet/tree/master/cumulet
3. Create a file `gentx-<VALIDATOR_NAME>.json` under the `cumulet/gentx` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!
