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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/170463282-576375f8-fa1e-4fce-8350-6312b415b50d.png">
</p>

# Celestia node setup for testnet — mamaki

Official documentation:
- https://docs.celestia.org/nodes/overview

Explorer:
- https://celestia.explorers.guru

Manual guides:
- [Run Validator and Bridge Node on same machine](https://github.com/kj89/testnet_manuals/blob/main/celestia/manual_install.md)
- [Run Bridge Node seperately](https://github.com/kj89/testnet_manuals/blob/main/celestia/manual_bridge.md)
- [Run Light Node seperately](https://github.com/kj89/testnet_manuals/blob/main/celestia/manual_light.md)
- [Run Full Node seperately](https://github.com/kj89/testnet_manuals/blob/main/celestia/manual_full.md)

## Hardware requirements
- Memory: 8 GB RAM
- CPU: Quad-Core
- Disk: 250 GB SSD Storage
- Bandwidth: 1 Gbps for Download/100 Mbps for Upload

## Set up your celestia fullnode
### Option 1 (automatic)
You can setup your celestia fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O celestia.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/celestia.sh && chmod +x celestia.sh && ./celestia.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/celestia/manual_install.md) if you better prefer setting up node manually

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
celestia-appd status 2>&1 | jq .SyncInfo
```

### (OPTIONAL) Disable and cleanup indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.celestia-app/config/config.toml
sudo systemctl restart celestia-appd
sleep 3
sudo rm -rf $HOME/.celestia-app/data/tx_index.db
```

### (OPTIONAL) Use Quick Sync by restoring data from snapshot
```
systemctl stop celestia-appd
celestia-appd tendermint unsafe-reset-all --home $HOME/.celestia-app
cd $HOME
rm -rf ~/.celestia-app/data
mkdir -p ~/.celestia-app/data
SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ | egrep -o ">mamaki.*tar" | tr -d ">")
wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - -C ~/.celestia-app/data/
systemctl restart celestia-appd && journalctl -fu celestia-appd -o cat
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
celestia-appd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
celestia-appd keys add $WALLET --recover
```

To get current list of wallets
```
celestia-appd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
CELESTIA_WALLET_ADDRESS=$(celestia-appd keys show $WALLET -a)
CELESTIA_VALOPER_ADDRESS=$(celestia-appd keys show $WALLET --bech val -a)
echo 'export CELESTIA_WALLET_ADDRESS='${CELESTIA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export CELESTIA_VALOPER_ADDRESS='${CELESTIA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
To top up your wallet join [celestia discord server](https://discord.gg/neBFH8Se) and navigate to:
- **#faucet** to request test tokens

To request a faucet grant:
```
$request <YOUR_WALLET_ADDRESS>
```

To check wallet balance:
```
$balance <YOUR_WALLET_ADDRESS>
```

### Create validator
Before creating validator please make sure that you have at least 1 tia (1 tia is equal to 1000000 utia) and your node is synchronized

To check your wallet balance:
```
celestia-appd query bank balances $CELESTIA_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
celestia-appd tx staking create-validator \
  --amount 1000000utia \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(celestia-appd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CELESTIA_CHAIN_ID
```

## Security
To protect you keys please make sure you follow basic security rules

### Set up ssh keys for authentication
Good tutiaal on how to set up ssh keys for authentication to your server can be found [here](https://www.digitalocean.com/community/tutiaals/how-to-set-up-ssh-keys-on-ubuntu-20-04)

### Basic Firewall security
Start by checking the status of ufw.
```
sudo ufw status
```

Sets the default to allow outgoing connections, deny all incoming except ssh and 26656. Limit SSH login attempts
```
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow ${CELESTIA_PORT}656,${CELESTIA_PORT}660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for celestia validator](https://github.com/kj89/testnet_manuals/blob/main/celestia/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/tools/synctime.py && python3 ./synctime.py
```

### Get list of validators
```
celestia-appd q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${CELESTIA_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu celestia-appd -o cat
```

Start service
```
sudo systemctl start celestia-appd
```

Stop service
```
sudo systemctl stop celestia-appd
```

Restart service
```
sudo systemctl restart celestia-appd
```

### Node info
Synchronization info
```
celestia-appd status 2>&1 | jq .SyncInfo
```

Validator info
```
celestia-appd status 2>&1 | jq .ValidatorInfo
```

Node info
```
celestia-appd status 2>&1 | jq .NodeInfo
```

Show node id
```
celestia-appd tendermint show-node-id
```

### Wallet operations
List of wallets
```
celestia-appd keys list
```

Recover wallet
```
celestia-appd keys add $WALLET --recover
```

Delete wallet
```
celestia-appd keys delete $WALLET
```

Get wallet balance
```
celestia-appd query bank balances $CELESTIA_WALLET_ADDRESS
```

Transfer funds
```
celestia-appd tx bank send $CELESTIA_WALLET_ADDRESS <TO_CELESTIA_WALLET_ADDRESS> 10000000utia
```

### Voting
```
celestia-appd tx gov vote 1 yes --from $WALLET --chain-id=$CELESTIA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
celestia-appd tx staking delegate $CELESTIA_VALOPER_ADDRESS 10000000utia --from=$WALLET --chain-id=$CELESTIA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
celestia-appd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utia --from=$WALLET --chain-id=$CELESTIA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
celestia-appd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CELESTIA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
celestia-appd tx distribution withdraw-rewards $CELESTIA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CELESTIA_CHAIN_ID
```

### Validator management
Edit validator
```
celestia-appd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$CELESTIA_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
celestia-appd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CELESTIA_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop celestia-appd
sudo systemctl disable celestia-appd
sudo rm /etc/systemd/system/celestia* -rf
sudo rm $(which celestia-appd) -rf
sudo rm $HOME/.celestia-app* -rf
sudo rm $HOME/celestia -rf
sed -i '/CELESTIA_/d' ~/.bash_profile
```
