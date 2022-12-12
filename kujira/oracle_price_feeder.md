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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/172356220-b8326ceb-9950-4226-b66e-da69099aaf6e.png">
</p>

# Kujira Oracle Guide

### Introduction
Validators are required to submit price feeds for the on-chain oracle. The price-feeder app can get price data from multiple providers and submit oracle votes to perform this duty.

### Requirements
price-feeder needs access to a running node's RPC and gRPC ports. This guide assumes you have it on the same machine and uses localhost with default ports 13657 and 13090. Change these in config.toml as needed.

## 1. Update system
```
sudo apt update && sudo apt upgrade -y
```

## 2. Install dependencies
```
sudo apt install -y build-essential git unzip curl
```

## 3. Download and build binaries
```
git clone https://github.com/Team-Kujira/oracle-price-feeder
cd oracle-price-feeder
make install
price-feeder version
```

Output:
```
version: -7788ddebca69b4f537668c6a3be71e778c59c3db
commit: 7788ddebca69b4f537668c6a3be71e778c59c3db
sdk: v0.45.6
go: go1.18.2 linux/amd64
```

## 4. Create oracle wallet
This wallet will be relatively insecure, only store the funds you need to send votes.

### (OPTION 1) Generate new wallet
```
kujirad keys add oracle
```
### (OPTION 2) Recover  wallet
```
kujirad keys add oracle --recover
```

## 5. Load oracle address into system variables
```
KUJIRA_ORACLE_ADDRESS=$(kujirad keys show oracle -a)
```
```
echo 'export KUJIRA_ORACLE_ADDRESS='${KUJIRA_ORACLE_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## 5. Set the feeder delegation
```
kujirad tx oracle set-feeder $KUJIRA_ORACLE_ADDRESS --from $WALLET --fees 250ukuji
```

## 6. Create oracle config
```
mkdir $HOME/.kujira-price-feeder
sudo tee $HOME/.kujira-price-feeder/config.toml > /dev/null <<EOF
gas_adjustment = 1.7
gas_prices = "0.00125ukuji"
enable_server = true
enable_voter = true
provider_timeout = "500ms"

[server]
listen_addr = "0.0.0.0:7171"
read_timeout = "20s"
verbose_cors = true
write_timeout = "20s"

[[deviation_thresholds]]
base = "USDT"
threshold = "2"

[[currency_pairs]]
base = "USDT"
providers = ["binance", "kraken", "coinbase"]
quote = "USD"

[[currency_pairs]]
base = "BNB"
providers = ["binance"]
quote = "USD"

[[currency_pairs]]
base = "BNB"
providers = ["huobi", "mexc"]
quote = "USDT"

[[currency_pairs]]
base = "ATOM"
providers = ["binance", "kraken", "coinbase", "osmosis"]
quote = "USD"

[[currency_pairs]]
base = "BTC"
providers = ["huobi"]
quote = "USDT"

[[currency_pairs]]
base = "BTC"
providers = ["binance", "coinbase"]
quote = "USD"

[[currency_pairs]]
base = "ETH"
providers = ["binance", "kraken", "coinbase"]
quote = "USD"

[[currency_pairs]]
base = "DOT"
providers = ["binance", "kraken", "coinbase"]
quote = "USD"

[account]
address = "${KUJIRA_ORACLE_ADDRESS}"
chain_id = "${KUJIRA_CHAIN_ID}"
validator = "${KUJIRA_VALOPER_ADDRESS}"
prefix = "kujira"

[keyring]
backend = "file"
dir = "$HOME/.kujira"

[rpc]
grpc_endpoint = "localhost:${KUJIRA_PORT}090"
rpc_timeout = "100ms"
tmrpc_endpoint = "http://localhost:${KUJIRA_PORT}657"

[telemetry]
enable_hostname = true
enable_hostname_label = true
enable_service_label = true
enabled = true
global_labels = [["chain-id", "${KUJIRA_CHAIN_ID}"]]
service_name = "price-feeder"
type = "prometheus"

[[provider_endpoints]]
name = "binance"
rest = "https://api.binance.com"
websocket = "stream.binance.com:9443"
EOF
```

## 7. Validate the currency pairs
It's important to only submit price votes for whitelisted denoms in order to avoid slashing. Check [this link](https://lcd.kaiyo.kujira.setten.io/oracle/params) to see the currently configured denoms and update [[currency_pairs]] if needed: kaiyo-1 oracle parameters.

## 8. Create a service
```
sudo tee /etc/systemd/system/kujira-price-feeder.service > /dev/null <<EOF
[Unit]
Description=Kujira price feeder
After=network-online.target

[Service]
User=$USER
ExecStart=$(which price-feeder) $HOME/.kujira-price-feeder/config.toml
Restart=on-failure
RestartSec=30
LimitNOFILE=65535
Environment="PRICE_FEEDER_PASS=<YOUR_KEYRING_PASSWORD>"

[Install]
WantedBy=multi-user.target
EOF
```

## 9. Register and run service
```
sudo systemctl daemon-reload
sudo systemctl enable kujira-price-feeder
sudo systemctl start kujira-price-feeder
```

## 10. Check logs
```
journalctl -fu kujira-price-feeder
```
