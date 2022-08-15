# Kujira Oracle Guide

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

## 4. Create the wallet and a password for the keyring.
```
kujirad keys add oracle
```
or
```
kujirad keys add oracle --recover
```

## 5. Load oracle address into system variables
step 1
```
KUJIRA_ORACLE_ADDRESS=$(kujirad keys show oracle -a)
```
step 2
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
gas_adjustment = 1.5
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
rest = "https://api1.binance.com"
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
