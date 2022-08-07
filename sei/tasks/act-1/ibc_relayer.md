<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/fRVzvPBh" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/169664551-39020c2e-fa95-483b-916b-c52ce4cb907c.png">
</p>

# Set up a relayer / ibc channel with another testnet
In current example we will learn how to set up IBC relayer between two cosmos chains

## Preparation before you start
Before setting up relayer you need to make sure you already have:
1. Fully synchronized RPC nodes for each Cosmos project you want to connect
2. RPC enpoints should be exposed and available from hermes instance
#### RPC configuration is located in `config.toml` file
```
laddr = "tcp://0.0.0.0:12657"
```
#### GRPC configuration is located in `app.toml` file
```
address = "0.0.0.0:12090"
```

3. Indexing is set to `kv` and is enabled on each node
4. For each chain you will need to have seperate wallets that are funded with tokens. This wallets will be used to do all relayer stuff

## Update system
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install unzip -y
```

## Set up variables
All settings below are just example for IBC Relayer between sei `atlantic-1` and uptick `uptick_7776-1` testnets. Please fill with your own values.
```
RELAYER_NAME='kjnodes'
```

### Chain A
```
CHAIN_ID_A='atlantic-1'
RPC_ADDR_A='111.57.22.69:12657'
GRPC_ADDR_A='111.57.22.69:12090'
ACCOUNT_PREFIX_A='sei'
TRUSTING_PERIOD_A='2days'
DENOM_A='usei'
MNEMONIC_A='stand action deer vivid wasp field latin hidden original cup brisk invest alert bone table invest pluck position govern thank canyon naive napkin penalty'
```

### Chain B
```
CHAIN_ID_B='uptick_7776-1'
RPC_ADDR_B='43.31.213.26:15657'
GRPC_ADDR_B='43.31.213.26:15090'
ACCOUNT_PREFIX_B='uptick'
TRUSTING_PERIOD_B='14days'
DENOM_B='auptick'
MNEMONIC_B='shaft pave alone age dolphin lab brave trick fatigue vivid social wolf wave blind spread fabric artefact universe add funny boss inch wash skate'
```

## Download Hermes
```
cd $HOME
wget https://github.com/informalsystems/ibc-rs/releases/download/v1.0.0-rc.0/hermes-v1.0.0-rc.0-x86_64-unknown-linux-gnu.zip
unzip hermes-v1.0.0-rc.0-x86_64-unknown-linux-gnu.zip
sudo mv hermes /usr/local/bin
hermes version
```

## Make hermes home dir
```
mkdir $HOME/.hermes
```

## Create hermes config
Generate hermes config file using variables we have defined above
```
sudo tee $HOME/.hermes/config.toml > /dev/null <<EOF
[global]
log_level = 'info'

[mode]

[mode.clients]
enabled = true
refresh = true
misbehaviour = true

[mode.connections]
enabled = false

[mode.channels]
enabled = false

[mode.packets]
enabled = true
clear_interval = 100
clear_on_start = true
tx_confirmation = true

[rest]
enabled = true
host = '127.0.0.1'
port = 3000

[telemetry]
enabled = true
host = '127.0.0.1'
port = 3001

[[chains]]
### CHAIN_A ###
id = '${CHAIN_ID_A}'
rpc_addr = 'http://${RPC_ADDR_A}'
grpc_addr = 'http://${GRPC_ADDR_A}'
websocket_addr = 'ws://${RPC_ADDR_A}/websocket'
rpc_timeout = '10s'
account_prefix = '${ACCOUNT_PREFIX_A}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = 0.001, denom = '${DENOM_A}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = 2097152
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${TRUSTING_PERIOD_A}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${RELAYER_NAME} Relayer'

[[chains]]
### CHAIN_B ###
id = '${CHAIN_ID_B}'
rpc_addr = 'http://${RPC_ADDR_B}'
grpc_addr = 'http://${GRPC_ADDR_B}'
websocket_addr = 'ws://${RPC_ADDR_B}/websocket'
rpc_timeout = '10s'
account_prefix = '${ACCOUNT_PREFIX_B}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = 0.001, denom = '${DENOM_B}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = 2097152
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${TRUSTING_PERIOD_B}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${RELAYER_NAME} Relayer'
EOF
```

## Verify hermes configuration is correct
Before proceeding further please check if your configuration is correct
```
hermes health-check
```

Healthy output should look like:
```
2022-07-21T19:38:15.571398Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
2022-07-21T19:38:15.573884Z  INFO ThreadId(01) [atlantic-1] performing health check...
2022-07-21T19:38:15.614273Z  INFO ThreadId(01) chain is healthy chain=atlantic-1
2022-07-21T19:38:15.614313Z  INFO ThreadId(01) [uptick_7776-1] performing health check...
2022-07-21T19:38:15.627747Z  INFO ThreadId(01) chain is healthy chain=uptick_7776-1
Success: performed health check for all chains in the config
```

## Recover wallets using mnemonic files
Before you proceed with this step, please make sure you have created and funded with tokens seperate wallets on each chain
```
sudo tee $HOME/.hermes/${CHAIN_ID_A}.mnemonic > /dev/null <<EOF
${MNEMONIC_A}
EOF
sudo tee $HOME/.hermes/${CHAIN_ID_B}.mnemonic > /dev/null <<EOF
${MNEMONIC_B}
EOF
hermes keys add --chain ${CHAIN_ID_A} --mnemonic-file $HOME/.hermes/${CHAIN_ID_A}.mnemonic
hermes keys add --chain ${CHAIN_ID_B} --mnemonic-file $HOME/.hermes/${CHAIN_ID_B}.mnemonic
```

Successful output should look like:
```
2022-07-21T19:54:13.778550Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
Success: Restored key 'wallet' (sei1eardm7w7v9el9d3khkwlj9stdj9hexnfv8pea8) on chain atlantic-1
2022-07-21T19:54:14.956171Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
Success: Restored key 'wallet' (uptick1ypnerpxuqezq2vfqxm74ddkuqnektveezh5uaa) on chain uptick_7776-1
```

## Create hermes service daemon
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
sudo systemctl restart hermesd
```

## Check hermes logs
```
journalctl -u hermesd -f -o cat
```

## Find free channels
```
hermes query channels --chain ${CHAIN_ID_A}
hermes query channels --chain ${CHAIN_ID_B}
```

## Register channel
```
hermes create channel --a-chain ${CHAIN_ID_A} --b-chain ${CHAIN_ID_B} --a-port transfer --b-port transfer --order unordered --new-client-connection
```

Output should give you all information about chanels that have been created for current chains

## Perform token transfer using IBC Relayer
All commands below are just an examples

### Send usei tokens from `atlantic-1` to `uptick_7776-1`
```
seid tx ibc-transfer transfer transfer channel-162 uptick1jqpaf0vgzlxvjx5meq8huweuv2nguqe2ugvd9v 666usei --from $WALLET --fees 200usei
```

### Send auptick tokens from `uptick_7776-1` to `atlantic-1`
```
uptickd tx ibc-transfer transfer transfer channel-5 sei1828et4w3u52na4h8m3mp8r22vjylxeaa2zq5ed 666auptick --from $WALLET --fees 200auptick
```
