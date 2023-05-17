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
curl -Ls https://go.dev/dl/go1.19.9.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

## Download and install binaries
```
# Clone project repository
cd $HOME
rm -rf nolus-core
git clone https://github.com/Nolus-Protocol/nolus-core.git
cd nolus-core
git checkout v0.3.0

# Install binaries
make install
```

## Config app
```
nolusd config chain-id pirin-1
nolusd config keyring-backend os
```

## Init node
Replace `<YOUR_MONIKER>` with your validator name
```
nolusd init <YOUR_MONIKER> --chain-id pirin-1
```

## Recover or create new wallet for mainnet
Option 1 - generate new wallet
```
nolusd keys add wallet
```

Option 2 - recover existing wallet
```
nolusd keys add wallet --recover
```

## Add genesis account
```
WALLET_ADDRESS=$(nolusd keys show wallet -a)
nolusd add-genesis-account $WALLET_ADDRESS 10000000unls
```

## Generate gentx
Replace `<YOUR_MONIKER>` with your validator name and fill up the rest of validator details like website, keybase id and contack email address.
```
nolusd gentx wallet 1000000unls \
--chain-id pirin-1 \
--moniker="<YOUR_MONIKER>" \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--identity="<YOUR_KEYBASE_ID>" \
--website="<YOUR_WEBSITE>" \
--details="<YOUR_VALIDATOR_DETAILS>" \
--security-contact="<YOUR_CONTACT_EMAIL>" \
--min-self-delegation=1
```

## Things you have to backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.nolus/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.nolus/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/nolus-protocol/nolus-networks
3. Create a file `gentx-<YOUR_MONIKER>.json` under the `mainnet/pirin-1/gentxs` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!
