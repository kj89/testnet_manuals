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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/177979901-4ac785e2-08c3-4d61-83df-b451a2ed9e68.png">
</p>

# Generate Aura Miannet gentx

## Setting up vars
Set up your Moniker (validator name) and EVM address
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
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
git clone https://github.com/aura-nw/aura.git
cd aura
git checkout Aura_v0.4.3
make install
```

## Config app
```
aurad config chain-id xstaxy-1
aurad config keyring-backend test
```

## Init node
```
aurad init $NODENAME --chain-id xstaxy-1
```

## Recover or create new wallet for testnet
Option 1 - generate new wallet
```
aurad keys add wallet
```

Option 2 - recover existing wallet
```
aurad keys add wallet --recover
```

## Add genesis account
```
WALLET_ADDRESS=$(aurad keys show wallet -a)
aurad add-genesis-account $WALLET_ADDRESS 100000000uaura 
```

## Generate gentx
```
aurad gentx wallet 100000000uaura  \
--chain-id xstaxy-1 \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Trusted and reliable Proof-of-Stake validator across Cosmos universe." \
--commission-max-change-rate=0.01 \
--commission-max-rate=1.0 \
--commission-rate=0.05 \
--min-self-delegation=1 \
--yes
```

## Things you have to backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.aura/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.aura/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/aura-nw/mainnet-artifacts
3. Create a file `gentx-<VALIDATOR_NAME>.json` under the `xstaxy-1/gentxs` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!
