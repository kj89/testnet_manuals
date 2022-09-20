<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/JqQNcwff2e" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/172488614-7d93b016-5fe4-4a51-99e2-67da5875ab7a.png">
</p>

# Pigeon relayer manual setup
A Golang cross-chain message relayer system for Paloma validators to deliver messages to any blockchain.

## Register and create Alchemy app
To get `ETH_RPC_URL` register at https://www.alchemy.com/ and create new Ethereum Mainnet app

![image](https://user-images.githubusercontent.com/50621007/178287931-d190db26-6b8f-4e05-863d-293a97f3a546.png)

## Setting up vars
```
ETH_RPC_URL=<YOUR_ETH_MAINNET_RPC_URL>
ETH_PASSWORD=<ETH_KEY_PASSWORD>
```

Example
```
ETH_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/UTv.....
ETH_PASSWORD=mysecurepassword
```

Save and import variables into system
```
echo "export ETH_RPC_URL=${ETH_RPC_URL}" >> $HOME/.bash_profile
echo "export ETH_PASSWORD=${ETH_PASSWORD}" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Download and build binaries
```
wget -O - https://github.com/palomachain/pigeon/releases/download/v0.8.0/pigeon_Linux_x86_64.tar.gz | \
tar -C /usr/local/bin -xvzf - pigeon
chmod +x /usr/local/bin/pigeon
mkdir ~/.pigeon
```

## Set up your EVM keys
### (OPTION 1) Generate new keys
Use the same password you have defined earlier in `ETH_PASSWORD`
```
pigeon evm keys generate-new $HOME/.pigeon/keys/evm/eth-main
```
### (OPTION 2) Import existing keys
```
pigeon evm keys import ~/.pigeon/keys/evm/eth-main
```

## Load ETH_SIGNER_KEY into bash_profile
```
echo "export ETH_SIGNING_KEY=0x$(cat .pigeon/keys/evm/eth-main/*  | jq -r .address | head -n 1)" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Create configuration file
```
sudo tee $HOME/.pigeon/config.yaml > /dev/null <<EOF
loop-timeout: 5s
health-check-port: 5757

paloma:
  chain-id: paloma-testnet-10
  call-timeout: 20s
  keyring-dir: $HOME/.paloma
  keyring-type: test
  keyring-pass-env-name: PASSWORD
  signing-key: ${WALLET}
  base-rpc-url: http://localhost:${PALOMA_PORT}657
  gas-adjustment: 1.5
  gas-prices: 0.001ugrain
  account-prefix: paloma

evm:
  eth-main:
    chain-id: 1
    base-rpc-url: ${ETH_RPC_URL}
    keyring-pass-env-name: PASSWORD
    signing-key: ${ETH_SIGNING_KEY}
    keyring-dir: $HOME/.pigeon/keys/evm/eth-main
EOF
```

## Set .env file
```
sudo tee $HOME/.pigeon/.env > /dev/null <<EOF
PASSWORD=$ETH_PASSWORD
EOF
```


## Create service
```
sudo tee /etc/systemd/system/pigeond.service > /dev/null <<EOF
[Unit]
Description=Pigeon Service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which pigeon) start
EnvironmentFile=$HOME/.pigeon/.env
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
sudo systemctl enable pigeond
sudo systemctl restart pigeond && sudo journalctl -u pigeond -f -o cat
```

## Post output of command below into paloma telegram channel
```
palomad q valset validator-info <YOUR_PALOMA_VALIDATOR_ADDRESS>
```

Output should look like this (this is just an example):
```
palomad q valset validator-info palomavaloper13uslh0y22ffnndyr3x30wqd8a6peqh25m8p743
chainInfos:
- address: 0x63f55bc560E981d53E1f5bb3643e3a96D26fc635
  chainID: eth-main
  chainType: EVM
  pubkey: Y/VbxWDpgdU+H1uzZD46ltJvxjU=
```

# Remove pigeon (use on your own risk!)
```
sudo systemctl stop pigeond
sudo systemctl disable pigeond
sudo rm /etc/systemd/system/pigeon* -rf
sudo rm $(which pigeon) -rf
sudo rm $HOME/.pigeon* -rf
```
