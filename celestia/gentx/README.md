<p style="font-size:14px" align="right">

<p align="center">
  <img height="100" height="auto" src="https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/logos/nolus.png">
</p>

# Generate Nolus mainnet gentx

## Update system and install build tools
```
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade
```

## Install Go
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.21.1.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

## Download and install binaries
```
# Clone project repository
cd $HOME
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app
git checkout v1.1.0

# Install binaries
make install
```

## Config app
```
celestia-appd config chain-id celestia
celestia-appd config keyring-backend os
```

## Init node
Replace `kjnodes` with your validator name
```
celestia-appd init kjnodes --chain-id celestia
```

## Recover or create new wallet for mainnet
Option 1 - generate new wallet
```
celestia-appd keys add wallet
```

Option 2 - recover existing wallet
```
celestia-appd keys add wallet --recover
```

## Download pre-genesis
```
wget -O $HOME/.celestia-app/config/genesis.json https://raw.githubusercontent.com/celestiaorg/networks/master/celestia/pre-genesis.json 
```

## Generate gentx
Replace `kjnodes` with your validator name and fill up the rest of validator details like website, keybase id and contack email address.
```
celestia-appd gentx wallet 61600000000utia \
--chain-id celestia \
--moniker="kjnodes" \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--moniker=" kjnodes.com 🦄" \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Trusted Proof of Stake validator across Cosmos universe. Active ecosystem contributor, IBC relayer and chain service provider since 2021. We deliver top-notch secure and reliable infrastructure for Cosmos projects. 24/7 monitoring with no slashing history in our track record." \
--security-contact="contact@kjnodes.com" \
--min-self-delegation=1
```

## Things you have to backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.celestia-app/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.celestia-app/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/nolus-protocol/nolus-networks
3. Create a file `gentx-kjnodes.json` under the `mainnet/celestia/gentxs` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!
