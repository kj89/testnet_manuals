<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/fRVzvPBh" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
<a href="https://m.do.co/c/17b61545ca3a" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus for 60 days <img src="https://user-images.githubusercontent.com/50621007/183284313-adf81164-6db4-4284-9ea0-bcb841936350.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/166148846-93575afe-e3ce-4ca5-a3f7-a21e8a8609cb.png">
</p>

# Relay packets between killerqueen-1 (connection-0) and kqcosmos-1 (connection-0)
This sould be installed and executed on `ica` cosmos validator node

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

## (ON QUICKSILVER NODE) Run this commands for change laddr adress `127.0.0.1` to `0.0.0.0` and restart service:
*You need to do this on the server with `killerqueen-1` installed.*
```
PORTR=$(grep -A 3 "\[rpc\]" ~/.quicksilverd/config/config.toml | egrep -o ":[0-9]+")
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1$PORTR\"%laddr = \"tcp://0.0.0.0$PORTR\"%" $HOME/.quicksilverd/config/config.toml

systemctl restart quicksilverd
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
  1000 \
  -d uatom \
  -k testkey \
  -r <QUICKSILVER_WALLET_ADDRESS> \
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
  1000 \
  -d "ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2" \
  -k testkey \
  -r <COSMOS_WALLET_ADDRESS> \
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
ica query bank balances <QUICKSILVER_WALLET_ADDRESS>
balances:
- amount: "1000"
  denom: ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2
- amount: "198"
  denom: uqck
pagination:
  next_key: null
  total: "0"
```

To generate more transactions you can run script below (it will continuously send 1 uatom to your <QUICKSILVER_WALLET_ADDRESS>)
```
while true; do hermes tx raw ft-transfer killerqueen-1 kqcosmos-1 transfer channel-0 1 -d uatom -k testkey -r <QUICKSILVER_WALLET_ADDRESS> -t 60 -o 100; echo "Press [CTRL+C] to stop.."; done
```
