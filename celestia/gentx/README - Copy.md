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
curl -Ls https://go.dev/dl/go1.20.8.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

## Download and install binaries
```
# Clone project repository
cd $HOME
rm -rf andromedad
git clone https://github.com/andromedaprotocol/andromedad.git
cd andromedad

# Install binaries
make install
```

## Config app
```
andromedad config chain-id andromeda-1
andromedad config keyring-backend test
```

## Init node
Replace `kjnodes` with your validator name
```
andromedad init kjnodes --chain-id andromeda-1
```

## Recover or create new wallet for mainnet
Option 1 - generate new wallet
```
andromedad keys add wallet
```

Option 2 - recover existing wallet
```
andromedad keys add wallet --recover
```

## Download pre-genesis
```
wget -O $HOME/.andromeda/config/genesis.json https://raw.githubusercontent.com/andromedaprotocol/mainnet/andromeda-1/genesis.json
```

## Generate gentx
Replace `kjnodes` with your validator name and fill up the rest of validator details like website, keybase id and contack email address.
```
andromedad gentx wallet 100000000000uandr \
--chain-id andromeda-1 \
--commission-max-change-rate=0.05 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--moniker=" kjnodes.com 🦄" \
--identity=1C5ACD2EEF363C3A \
--website="https://services.kjnodes.com/mainnet/andromeda" \
--details="Trusted Proof of Stake validator across Cosmos universe. Active ecosystem contributor, IBC relayer and chain service provider since 2021. We deliver top-notch secure and reliable infrastructure for Cosmos projects. 24/7 monitoring with no slashing history in our track record." \
--security-contact="contact@kjnodes.com" \
--min-self-delegation=1
```

## Things you have to backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.andromeda/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.andromeda/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/nolus-protocol/nolus-networks
3. Create a file `gentx-kjnodes.json` under the `mainnet/andromeda-1/gentxs` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!
