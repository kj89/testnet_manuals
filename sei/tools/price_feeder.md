<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/169664551-39020c2e-fa95-483b-916b-c52ce4cb907c.png">
</p>

# Price Oracle Script
This is a simple oracle script that fetchs market prices of different token pairs from the CoinGecko. Sei team will add multiple price sources in this script so that Sei can decentralize the oracle prices.

## Install coingecko api
```
git clone https://github.com/man-c/pycoingecko.git
cd pycoingecko
python3 setup.py install
```

## Set coins to fetch
```
COINS='cosmos','usd-coin'
```

## Create service
```
sudo tee /etc/systemd/system/price_feeder.service > /dev/null <<EOF
[Unit]
Description=sei
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/sei-chain/scripts/oracle
ExecStart=python3 -u price_feeder.py $WALLET 0 $SEI_CHAIN_ID $COINS --node http://localhost:${SEI_PORT}657
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

## Run service
```
sudo systemctl daemon-reload
sudo systemctl enable price_feeder
sudo systemctl restart price_feeder
```

## Check service logs
```
journalctl -fu price_feeder
```
