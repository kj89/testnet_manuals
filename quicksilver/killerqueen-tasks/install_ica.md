<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/166148846-93575afe-e3ce-4ca5-a3f7-a21e8a8609cb.png">
</p>

# Manual node setup on fresh Ubuntu server
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl build-essential git wget jq make gcc tmux unzip -y
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
go version
```

## Download and build binaries
```
git clone https://github.com/ingenuity-build/interchain-accounts --branch main
cd interchain-accounts
make install
```

## Init app
```
icad init $NODENAME --chain-id kqcosmos-1
```

## Download genesis and addrbook
```
wget -qO $HOME/.ica/config/genesis.json "https://raw.githubusercontent.com/ingenuity-build/testnets/main/killerqueen/kqcosmos-1/genesis.json"
```

## Set seeds and peers
```
SEEDS="66b0c16486bcc7591f2c3f0e5164d376d06ee0d0@65.108.203.151:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ica/config/config.toml
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uatom\"/" $HOME/.ica/config/app.toml
```

## Reset chain data
```
icad tendermint unsafe-reset-all --home $HOME/.ica
```

## Create service
```
sudo tee /etc/systemd/system/icad.service > /dev/null <<EOF
[Unit]
Description=ica
After=network-online.target

[Service]
User=$USER
ExecStart=$(which icad) --home $HOME/.ica start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable icad
sudo systemctl restart icad && sudo journalctl -u icad -f -o cat
```


## Recover keys
```
icad keys add $WALLET --recover --keyring-backend=test
```

## Fund your cosmos wallet using discord #atom-tap faucet
```
$request <WALLET_ADDRESS> killerqueen
```

## Create validator
```
icad tx staking create-validator \
  --amount=1000000uatom \
  --from=$WALLET \
  --keyring-backend=test  \
  --moniker=$NODENAME  \
  --chain-id=kqcosmos-1   \
  --commission-rate=0.059   \
  --commission-max-rate=1.0   \
  --commission-max-change-rate=0.1   \
  --min-self-delegation=1   \
  --pubkey=$(icad tendermint show-validator)
```

## Install hermes
```
cd ~
wget https://github.com/informalsystems/ibc-rs/releases/download/v0.15.0/hermes-v0.15.0-x86_64-unknown-linux-gnu.zip
unzip hermes-v0.15.0-x86_64-unknown-linux-gnu.zip
sudo mv hermes /usr/local/bin
hermes version
```

## Add hermes config
```
mkdir $HOME/.hermes
wget -qO $HOME/.hermes/config.toml "https://raw.githubusercontent.com/kj89/testnet_manuals/main/quicksilver/killerqueen-tasks/hermes-config.toml"
```

## Adjust line number 106, 109 and 113 based on your quicksilver rpc node endpoints
Example below:
```
# Specify the RPC address and port where the chain RPC server listens on. Required
rpc_addr = 'http://1.2.3.4:11657'

# Specify the GRPC address and port where the chain GRPC server listens on. Required
grpc_addr = 'http://1.2.3.4:11090'

# Specify the WebSocket address and port where the chain WebSocket server
# listens on. Required
websocket_addr = 'ws://1.2.3.4:11657/websocket'
```

## (ON QUICKSILVER NODE) Expose Quicksilver RPC server in .quicksilverd/config/config.toml at line 91
Change `127.0.0.1` to `0.0.0.0` and restart service. Example below:
```
# TCP or UNIX socket address for the RPC server to listen on
laddr = "tcp://0.0.0.0:11657"
```

## Restore keys
```
hermes keys restore killerqueen-1 -m "<YOUR_MNEMONIC>"
hermes keys restore kqcosmos-1 -m "<YOUR_MNEMONIC>"
```

## Register and start hermes service
```
sudo tee /etc/systemd/system/hermesd.service > /dev/null <<EOF
[Unit]
Description=hermes
After=network-online.target

[Service]
User=$USER
ExecStart=$(which hermes) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable hermesd
sudo systemctl restart hermesd && sudo journalctl -u hermesd -f -o cat
```

## IBC transfers
comsos -> quicksilver
```
hermes tx raw ft-transfer \
  killerqueen-1 \
  kqcosmos-1 \
  transfer \
  channel-0 \
  10000 \
  -d uatom \
  -k testkey \
  -r <YOUR_QUICKSILVER_ADDRESS> \
  -t 60 \
  -o 100
```
quicksilvr -> cosmos
```
hermes tx raw ft-transfer \
  kqcosmos-1 \
  killerqueen-1 \
  transfer \
  channel-0 \
  10000 \
  -d "ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2" \
  -k testkey \
  -r <YOUR_COSMOS_ADDRESS> \
  -n 1 \
  -t 60 \
  -o 100
```

You should see similar output:
```
2022-06-25T21:49:46.584669Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
2022-06-25T21:49:46.675960Z  INFO ThreadId(04) wait_for_block_commits: waiting for commit of tx hashes(s) D2BE48A8FD301D790B60876C0806547BC91FA3CF5C3D115B1BA320A1B81F93BB id=kqcosmos-1
Success: [
    SendPacket(
        SendPacket - h:1-34806, seq:2026, path:channel-0/transfer->channel-0/transfer, toh:1-32301, tos:Timestamp(2022-06-25T21:50:32.665126923Z)),
    ),
]
```

## Check your wallet balances
cosmos balance
```
icad query bank balances <COSMOS_WALLET_ADDRESS>
```

quicksilver balance
```
quicksilverd query bank balances <QUICKSILVER_WALLET_ADDRESS>
```

You should see similar output:
```
quicksilverd query bank balances $QUICKSILVER_WALLET_ADDRESS
balances:
- amount: "10000"
  denom: ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2
- amount: "198"
  denom: uqck
pagination:
  next_key: null
  total: "0"
```
