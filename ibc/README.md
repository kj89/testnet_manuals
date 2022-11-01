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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/193043013-93ef07b7-1de6-4e43-9842-1a776b600ee8.png">
</p>

# Hermes relayer setup

## Preparation before you start
Before setting up relayer you need to make sure you already have:
1. Fully synchronized RPC nodes for each Cosmos project you want to connect
2. RPC enpoints should be available from hermes service
3. Indexing is set to `kv` and is enabled on each node
4. For each chain you will need to have wallets that are funded with tokens. This wallets will be used to do all relayer stuff and pay commission

## Update system
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install unzip -y
```

## Make hermes home dir
```
mkdir $HOME/.hermes
```

## Download Hermes
```
wget https://github.com/informalsystems/ibc-rs/releases/download/v1.0.0/hermes-v1.0.0-x86_64-unknown-linux-gnu.tar.gz
mkdir -p $HOME/.hermes/bin
tar -C $HOME/.hermes/bin/ -vxzf hermes-v1.0.0-x86_64-unknown-linux-gnu.tar.gz
echo 'export PATH="$HOME/.hermes/bin:$PATH"' >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Create hermes config
Generate hermes config file using variables we have defined above
```
sudo tee $HOME/.hermes/config.toml > /dev/null <<EOF
# The global section has parameters that apply globally to the relayer operation.
[global]
log_level = 'info'

# Specify the mode to be used by the relayer. [Required]
[mode]

# Specify the client mode.
[mode.clients]
enabled = true
refresh = true
misbehaviour = false

# Specify the connections mode.
[mode.connections]
enabled = false

# Specify the channels mode.
[mode.channels]
enabled = false

# Specify the packets mode.
[mode.packets]
enabled = true
clear_interval = 100
clear_on_start = true
tx_confirmation = false

# The REST section defines parameters for Hermes' built-in RESTful API.
# https://hermes.informal.systems/rest.html
[rest]
enabled = true
host = '0.0.0.0'
port = 3000

[telemetry]
enabled = true
host = '0.0.0.0'
port = 3001

############################################################### COSMOS ###############################################################
[[chains]]
id = 'cosmoshub-4'
rpc_addr = 'http://127.0.0.1:34657'
grpc_addr = 'http://127.0.0.1:34090'
websocket_addr = 'ws://127.0.0.1:34657/websocket'

rpc_timeout = '30s'
account_prefix = 'cosmos'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 300000
max_gas = 3500000
gas_price = { price = 0.00005, denom = 'uatom' }
gas_multiplier = 1.3
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '14days'
memo_prefix = 'Relayed by kjnodes'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
#  ['transfer', 'channel-141'], # Osmosis
  ['transfer', 'channel-281'], # Gravity Bridge
  ['transfer', 'channel-343'], # Kujira
#  ['transfer', 'channel-374'], # Agoric
  ['transfer', 'channel-391'], # Stride
]

############################################################### OSMOSIS ###############################################################
[[chains]]
id = 'osmosis-1'
rpc_addr = 'http://127.0.0.1:29657'
grpc_addr = 'http://127.0.0.1:29090'
websocket_addr = 'ws://127.0.0.1:29657/websocket'

rpc_timeout = '30s'
account_prefix = 'osmo'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 400000
max_gas = 120000000
gas_price = { price = 0.0025, denom = 'uosmo' }
gas_multiplier = 1.5
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '7days'
memo_prefix = 'Relayed by kjnodes'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
#  ['transfer', 'channel-0'], # Cosmos
  ['transfer', 'channel-144'], # Gravity
  ['transfer', 'channel-259'], # Kujira
  ['transfer', 'channel-320'], # Agoric
  ['transfer', 'channel-326'], # Stride
  ['transfer', 'channel-362'], # Teritori
  ['transfer', 'channel-412'], # Jackal
]

############################################################### GRAVITY BRIDGE ###############################################################
[[chains]]
id = 'gravity-bridge-3'
rpc_addr = 'http://127.0.0.1:26657'
grpc_addr = 'http://127.0.0.1:26090'
websocket_addr = 'ws://127.0.0.1:26657/websocket'

rpc_timeout = '30s'
account_prefix = 'gravity'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 300000
max_gas = 5000000
gas_price = { price = 0.0261, denom = 'ugraviton' }
gas_multiplier = 1.4
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '7days'
memo_prefix = 'Relayed by kjnodes'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-10'], # Osmosis
  ['transfer', 'channel-17'], # Cosmos
  ['transfer', 'channel-91'], # Agoric
]

############################################################### STRIDE ###############################################################
[[chains]]
id = 'stride-1'
rpc_addr = 'http://127.0.0.1:16657'
grpc_addr = 'http://127.0.0.1:16090'
websocket_addr = 'ws://127.0.0.1:16657/websocket'

rpc_timeout = '30s'
account_prefix = 'stride'
key_name = 'relayer'
store_prefix = 'ibc'
address_type = { derivation = 'cosmos' }
default_gas = 100000
max_gas = 1000000
gas_price = { price = 0.000, denom = 'ustrd' }
gas_multiplier = 1.2
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '7days'
memo_prefix = 'Relayed by kjnodes'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-0'], # Cosmos
  ['transfer', 'channel-5'], # Osmosis
#  ['transfer', 'channel-8'], # Kujira
]

############################################################### KUJIRA ###############################################################
[[chains]]
id = 'kaiyo-1'
rpc_addr = 'http://127.0.0.1:13657'
grpc_addr = 'http://127.0.0.1:13090'
websocket_addr = 'ws://127.0.0.1:13657/websocket'
fee_granter = 'kujira1vkje22mayn72r0a7kna6agv0sqm6k94ry9k6dd'

rpc_timeout = '30s'
account_prefix = 'kujira'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 1000000
max_gas = 35000000
gas_price = { price = 0.00125, denom = 'ukuji' }
gas_multiplier = 1.2
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '10days'
memo_prefix = 'Relayed by kjnodes'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-0'], # Cosmos
  ['transfer', 'channel-3'], # Osmosis
#  ['transfer', 'channel-32'], # Stride
]

############################################################### AGORIC ###############################################################
[[chains]]
id = 'agoric-3'
rpc_addr = 'http://127.0.0.1:27657'
grpc_addr = 'http://127.0.0.1:27090'
websocket_addr = 'ws://127.0.0.1:27657/websocket'

rpc_timeout = '30s'
account_prefix = 'agoric'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 500000
max_gas =  15000000
gas_price = { price = 0.001, denom = 'ubld' }
gas_multiplier = 1.7
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '14days'
memo_prefix = 'Relayed by kjnodes'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
#  ['transfer', 'channel-0'], # Cosmos
  ['transfer', 'channel-1'], # Osmosis
  ['transfer', 'channel-4'], # Gravity
]

############################################################### TERITORI ###############################################################
[[chains]]
id = 'teritori-1'
rpc_addr = 'http://127.0.0.1:19657'
grpc_addr = 'http://127.0.0.1:19090'
websocket_addr = 'ws://127.0.0.1:19657/websocket'

rpc_timeout = '30s'
account_prefix = 'tori'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 1000000
max_gas = 35000000
gas_price = { price = 0.01, denom = 'utori' }
gas_multiplier = 1.2
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '7days'
memo_prefix = 'Relayed by kjnodes'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-0'], # Osmosis
]

############################################################### JACKAL ###############################################################
[[chains]]
id = 'jackal-1'
rpc_addr = 'http://127.0.0.1:37657'
grpc_addr = 'http://127.0.0.1:37090'
websocket_addr = 'ws://127.0.0.1:37657/websocket'

rpc_timeout = '30s'
account_prefix = 'jkl'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 1000000
max_gas = 35000000
gas_price = { price = 0.0005, denom = 'ujkl' }
gas_multiplier = 1.2
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '7days'
memo_prefix = 'Relayed by kjnodes'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-0'], # Osmosis
]

EOF
```

## Verify hermes configuration is correct
Before proceeding further please check if your configuration is correct
```
hermes health-check
```

Healthy output should look like:
```
2022-09-29T13:26:07.457436Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
2022-09-29T13:26:07.458251Z  INFO ThreadId(01) [osmosis-1] performing health check...
2022-09-29T13:26:07.472238Z  WARN ThreadId(18) Health checkup for chain 'osmosis-1' failed
2022-09-29T13:26:07.472266Z  WARN ThreadId(18) Reason: Hermes health check failed while verifying the application compatibility for chain osmosis-1:http://127.0.0.1:29090/; caused by: SDK module at version '0.46.0' does not meet compatibility requirements >=0.41, <0.46
2022-09-29T13:26:07.472289Z  WARN ThreadId(18) Some Hermes features may not work in this mode!
2022-09-29T13:26:07.472370Z  WARN ThreadId(01) [osmosis-1] chain is unhealthy
2022-09-29T13:26:07.472409Z  INFO ThreadId(01) [stride-1] performing health check...
2022-09-29T13:26:07.485761Z  INFO ThreadId(01) chain is healthy chain=stride-1
2022-09-29T13:26:07.485799Z  INFO ThreadId(01) [kaiyo-1] performing health check...
2022-09-29T13:26:07.498111Z  INFO ThreadId(01) chain is healthy chain=kaiyo-1
2022-09-29T13:26:07.498142Z  INFO ThreadId(01) [agoric-3] performing health check...
2022-09-29T13:26:07.509245Z  INFO ThreadId(01) chain is healthy chain=agoric-3
2022-09-29T13:26:07.509275Z  INFO ThreadId(01) [gravity-bridge-3] performing health check...
2022-09-29T13:26:07.527956Z  INFO ThreadId(01) chain is healthy chain=gravity-bridge-3
SUCCESS performed health check for all chains in the config
```

## Recover wallets using mnemonic files
Before you proceed with this step, please make sure you have created and funded with tokens seperate wallets on each chain
```
 MNEMONIC='word scare connect prison angry jazz help panther museum hope antenna all voyage fame shiver sing life zone era abstract busy bamboo own dune'
CHAIN_ID=teritori-1
sudo tee $HOME/.hermes/${CHAIN_ID}.mnemonic > /dev/null <<EOF
${MNEMONIC}
EOF
hermes keys add --chain ${CHAIN_ID} --mnemonic-file $HOME/.hermes/${CHAIN_ID}.mnemonic
rm $HOME/.hermes/${CHAIN_ID}.mnemonic
```

Successful output should look like:
```
2022-09-16T22:45:51.231496Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
SUCCESS Restored key 'relayer' (stride1cz3hzltasl657t8fk94z6fd4hzc284wzt08dc6) on chain stride-1
2022-09-16T22:45:52.385884Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
SUCCESS Restored key 'relayer' (osmo15cdqegpd9t7ujda9yapzgpa3x2zsgrjzvtr7ck) on chain osmosis-1
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

## Successfull logs should look like this:
```
2022-07-27T22:43:08.019651Z  INFO ThreadId(01) Scanned chains:
2022-07-27T22:43:08.019675Z  INFO ThreadId(01) # Chain: stride-1
  - Client: 07-tendermint-0
    * Connection: connection-0
      | State: OPEN
      | Counterparty state: OPEN
      + Channel: channel-0
        | Port: transfer
        | State: OPEN
        | Counterparty: channel-0
      + Channel: channel-1
        | Port: icacontroller-GAIA.DELEGATION
        | State: OPEN
        | Counterparty: channel-4
      + Channel: channel-2
        | Port: icacontroller-GAIA.FEE
        | State: OPEN
        | Counterparty: channel-1
      + Channel: channel-3
        | Port: icacontroller-GAIA.WITHDRAWAL
        | State: OPEN
        | Counterparty: channel-2
      + Channel: channel-4
        | Port: icacontroller-GAIA.REDEMPTION
        | State: OPEN
        | Counterparty: channel-3
# Chain: GAIA
  - Client: 07-tendermint-0
    * Connection: connection-0
      | State: OPEN
      | Counterparty state: OPEN
      + Channel: channel-0
        | Port: transfer
        | State: OPEN
        | Counterparty: channel-0
      + Channel: channel-1
        | Port: icahost
        | State: OPEN
        | Counterparty: channel-2
      + Channel: channel-2
        | Port: icahost
        | State: OPEN
        | Counterparty: channel-3
      + Channel: channel-3
        | Port: icahost
        | State: OPEN
        | Counterparty: channel-4
      + Channel: channel-4
        | Port: icahost
        | State: OPEN
        | Counterparty: channel-1
2022-07-27T22:43:08.020020Z  INFO ThreadId(01) connection is Open, state on destination chain is Open chain=stride-1 connection=connection-0 counterparty_chain=GAIA
2022-07-27T22:43:08.020035Z  INFO ThreadId(01) connection is already open, not spawning Connection worker chain=stride-1 connection=connection-0
2022-07-27T22:43:08.020045Z  INFO ThreadId(01) no connection workers were spawn chain=stride-1 connection=connection-0
2022-07-27T22:43:08.020052Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=stride-1 counterparty_chain=GAIA channel=channel-0
2022-07-27T22:43:08.024013Z  INFO ThreadId(01) spawned client worker: client::GAIA->stride-1:07-tendermint-0
2022-07-27T22:43:08.028421Z  INFO ThreadId(01) done spawning channel workers chain=stride-1 channel=channel-0
2022-07-27T22:43:08.028473Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=stride-1 counterparty_chain=GAIA channel=channel-1
2022-07-27T22:43:08.031579Z  INFO ThreadId(01) done spawning channel workers chain=stride-1 channel=channel-1
2022-07-27T22:43:08.031606Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=stride-1 counterparty_chain=GAIA channel=channel-2
2022-07-27T22:43:08.034669Z  INFO ThreadId(01) done spawning channel workers chain=stride-1 channel=channel-2
2022-07-27T22:43:08.034698Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=stride-1 counterparty_chain=GAIA channel=channel-3
2022-07-27T22:43:08.037346Z  INFO ThreadId(01) done spawning channel workers chain=stride-1 channel=channel-3
2022-07-27T22:43:08.037363Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=stride-1 counterparty_chain=GAIA channel=channel-4
2022-07-27T22:43:08.041229Z  INFO ThreadId(01) done spawning channel workers chain=stride-1 channel=channel-4
2022-07-27T22:43:08.041412Z  INFO ThreadId(01) spawning Wallet worker: wallet::stride-1
2022-07-27T22:43:08.041445Z  INFO ThreadId(01) connection is Open, state on destination chain is Open chain=GAIA connection=connection-0 counterparty_chain=stride-1
2022-07-27T22:43:08.041453Z  INFO ThreadId(01) connection is already open, not spawning Connection worker chain=GAIA connection=connection-0
2022-07-27T22:43:08.041462Z  INFO ThreadId(01) no connection workers were spawn chain=GAIA connection=connection-0
2022-07-27T22:43:08.041470Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=GAIA counterparty_chain=stride-1 channel=channel-0
2022-07-27T22:43:08.048399Z  INFO ThreadId(01) spawned client worker: client::stride-1->GAIA:07-tendermint-0
2022-07-27T22:43:08.053737Z  INFO ThreadId(01) done spawning channel workers chain=GAIA channel=channel-0
2022-07-27T22:43:08.053770Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=GAIA counterparty_chain=stride-1 channel=channel-1
2022-07-27T22:43:08.057395Z  INFO ThreadId(01) done spawning channel workers chain=GAIA channel=channel-1
2022-07-27T22:43:08.057441Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=GAIA counterparty_chain=stride-1 channel=channel-2
2022-07-27T22:43:08.061244Z  INFO ThreadId(01) done spawning channel workers chain=GAIA channel=channel-2
2022-07-27T22:43:08.061296Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=GAIA counterparty_chain=stride-1 channel=channel-3
2022-07-27T22:43:08.064713Z  INFO ThreadId(01) done spawning channel workers chain=GAIA channel=channel-3
2022-07-27T22:43:08.064742Z  INFO ThreadId(01) channel is OPEN, state on destination chain is OPEN chain=GAIA counterparty_chain=stride-1 channel=channel-4
2022-07-27T22:43:08.071960Z  INFO ThreadId(01) done spawning channel workers chain=GAIA channel=channel-4
2022-07-27T22:43:08.072413Z  INFO ThreadId(01) spawning Wallet worker: wallet::GAIA
2022-07-27T22:43:08.079299Z  INFO ThreadId(01) Hermes has started
2022-07-27T22:43:43.479282Z ERROR ThreadId(56) [stride-1] error during batch processing: supervisor was not able to spawn chain runtime: missing chain config for 'uni-3' in configuration file
2022-07-27T22:44:11.376229Z  INFO ThreadId(442) packet_cmd{src_chain=stride-1 src_port=icacontroller-GAIA.DELEGATION src_channel=channel-1 dst_chain=GAIA}: pulled packet data for 0 events; events_total=1 events_left=0
2022-07-27T22:44:12.592627Z  INFO ThreadId(442) packet_cmd{src_chain=stride-1 src_port=icacontroller-GAIA.DELEGATION src_channel=channel-1 dst_chain=GAIA}:relay{odata=d9ab28da ->Destination @2-11522; len=1}: assembled batch of 2 message(s)
2022-07-27T22:44:12.762428Z  INFO ThreadId(442) packet_cmd{src_chain=stride-1 src_port=icacontroller-GAIA.DELEGATION src_channel=channel-1 dst_chain=GAIA}:relay{odata=d9ab28da ->Destination @2-11522; len=1}: [Async~>GAIA] response(s): 1; Ok:36394BDD136B8E2400D0DFE00735C7D688069E467F281EFE76D3943871FD8D04
2022-07-27T22:44:12.762463Z  INFO ThreadId(442) packet_cmd{src_chain=stride-1 src_port=icacontroller-GAIA.DELEGATION src_channel=channel-1 dst_chain=GAIA}:relay{odata=d9ab28da ->Destination @2-11522; len=1}: success
2022-07-27T22:44:20.873424Z  INFO ThreadId(453) packet_cmd{src_chain=GAIA src_port=icahost src_channel=channel-4 dst_chain=stride-1}: pulled packet data for 0 events; events_total=1 events_left=0
2022-07-27T22:44:20.895913Z  INFO ThreadId(453) packet_cmd{src_chain=GAIA src_port=icahost src_channel=channel-4 dst_chain=stride-1}:relay{odata=d169839a ->Destination @0-16135; len=1}: assembled batch of 2 message(s)
2022-07-27T22:44:20.902820Z  INFO ThreadId(453) packet_cmd{src_chain=GAIA src_port=icahost src_channel=channel-4 dst_chain=stride-1}:relay{odata=d169839a ->Destination @0-16135; len=1}: [Async~>stride-1] response(s): 1; Ok:150EEF4C0EB3EF413115C192C7A5575190AA1E0B8EFC8A52389E556C16A71C57
2022-07-27T22:44:20.902852Z  INFO ThreadId(453) packet_cmd{src_chain=GAIA src_port=icahost src_channel=channel-4 dst_chain=stride-1}:relay{odata=d169839a ->Destination @0-16135; len=1}: success
```

You also should see `Update Client (Ibc)` transactions appearing in the explorer https://stride.explorers.guru/account/<STRIDE_WALLET_ADDRESS>

![image](https://user-images.githubusercontent.com/50621007/181440643-3cc002e0-50a5-4591-9758-b2bafcda699e.png)

## Completely remove hermes relayer
> **Warning** This will delete your hermes relayer from the machine!
```
sudo systemctl stop hermesd
sudo systemctl disable hermesd
sudo rm /etc/systemd/system/hermesd* -rf
sudo rm $(which hermes) -rf
sudo rm -rf $HOME/.hermes
sudo rm -rf $HOME/hermes*
```
