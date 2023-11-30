<p style="font-size:14px" align="right">

<p align="center">
  <img height="100" height="auto" src="https://raw.githubusercontent.com/kj89/cosmos-images/main/logos/composable.png">
</p>

# Generate gentx for Composable Finance centauri-1

## Update system and install build tools
```
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade
```

## Install Go
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.20.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

## Download and install binaries
```
# Clone project repository
cd $HOME
rm -rf composable-centauri
git clone https://github.com/notional-labs/composable-centauri
cd composable-centauri 
git checkout v2.3.5

# Install binaries
make install
```

## Config app
```
banksyd config chain-id centauri-1
```

## Init node
Replace `<YOUR_MONIKER>` with your validator name
```
banksyd init <YOUR_MONIKER> --chain-id centauri-1
```

## Recover or create new wallet for testnet
Option 1 - generate new wallet
```
banksyd keys add wallet
```

Option 2 - recover existing wallet
```
banksyd keys add wallet --recover
```

## Add genesis account
```
WALLET_ADDRESS=$(banksyd keys show wallet -a)
banksyd add-genesis-account $WALLET_ADDRESS 50000000000000ppica
```

## Generate gentx
Replace `<YOUR_MONIKER>` with your validator name and fill up the rest of validator details like website, keybase id and contack email address.
```
banksyd gentx wallet 50000000000000ppica \
--moniker="<YOUR_MONIKER>" \
--identity="<YOUR_KEYBASE_ID>" \
--website="<YOUR_WEBSITE>" \
--details="<YOUR_VALIDATOR_DETAILS>" \
--security-contact="<YOUR_CONTACT_EMAIL>" \
--chain-id centauri-1 \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--min-self-delegation=1
```

## Things you have to backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.banksy/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.banksy/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/notional-labs/composable-networks
3. Create a file `gentx-<YOUR_MONIKER>.json` under the `mainnet/gentxs` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!
