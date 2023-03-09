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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/170463282-576375f8-fa1e-4fce-8350-6312b415b50d.png">
</p>

# Generate Celestia ITN gentx

## Setting up vars
Set up your Moniker (validator name) and EVM address
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
EVM_ADDRESS=<YOUR_ETH_ADDRESS_GOES_HERE>
```

## Update packages and dependancies
```
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade
```

## Install go
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

## Download and install binaries
```
cd $HOME
git clone https://github.com/celestiaorg/celestia-app.git 
cd celestia-app
git checkout v0.12.0
make install
```

## Config app
```
celestia-appd config chain-id blockspacerace-0
celestia-appd config keyring-backend test
```

## Init node
```
celestia-appd init $NODENAME --chain-id blockspacerace-0
```

## Recover or create new wallet for testnet
Option 1 - generate new wallet
```
celestia-appd keys add wallet
```

Option 2 - recover existing wallet
```
celestia-appd keys add wallet --recover
```

## Add genesis account
```
WALLET_ADDRESS=$(celestia-appd keys show wallet -a)
celestia-appd add-genesis-account $WALLET_ADDRESS 5000000000000utia
```

## Generate gentx
```
celestia-appd gentx wallet 5000000000000utia \
--chain-id blockspacerace-0 \
--moniker=$NODENAME \
--identity="" \
--website="" \
--details="" \
--commission-max-change-rate=0.01 \
--commission-max-rate=1.0 \
--commission-rate=0.05 \
--min-self-delegation=1 \
--evm-address=$EVM_ADDRESS
```

## Things you have to backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.celestia-app/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.celestia-app/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/celestiaorg/networks
3. Create a file `<VALIDATOR_NAME>.json` under the `networks/blockspacerace/gentx` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!
