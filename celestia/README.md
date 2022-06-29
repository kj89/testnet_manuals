<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/EY35ZzXY" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/170463282-576375f8-fa1e-4fce-8350-6312b415b50d.png">
</p>

# Celestia validator node setup for Testnet — mamaki

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

## Usefull tools I have created for celestia
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for celestia validator](https://github.com/kj89/testnet_manuals/blob/main/celestia/monitoring/README.md)

## Set up your Celestia validator and bridge node on same machine
### Option 1 (automatic)
You can setup your Celestia validator and bridge node in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O celestia_mamaki.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/celestia_mamaki.sh && chmod +x celestia_mamaki.sh && ./celestia_mamaki.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/celestia/manual_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
celestia-appd status 2>&1 | jq .SyncInfo
```

To check validator logs
```
journalctl -u celestia-appd -f -o cat
```

To check bridge logs
```
journalctl -u celestia-bridge -f -o cat
```

### If your node often mis blocks try enabling legacy p2p layer
```
sed -i.bak -e "s/^use-legacy *=.*/use-legacy = \"true\"/" $HOME/.celestia-app/config/config.toml
systemctl restart celestia-appd
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
Add wallet address
```
WALLET_ADDRESS=$(celestia-appd keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(celestia-appd keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
To top up your wallet join [Celestia discord server](https://discord.gg/QAsD8j4Z) and navigate to **#faucet** channel under **NODE OPERATORS** category

To request a faucet grant:
```
$request <YOUR_WALLET_ADDRESS>
```

### Create validator
Before creating validator please make sure that you have at least 1 tia (1 tia is equal to 1000000 utia) and your node is synchronized

To check your wallet balance:
```
celestia-appd query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
celestia-appd tx staking create-validator \
  --amount 10000000utia \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(celestia-appd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID
```

## Security
To protect you keys please make sure you follow basic security rules

### Set up ssh keys for authentication
Good tutorial on how to set up ssh keys for authentication to your server can be found [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-20-04)

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
sudo ufw allow 26656,26657,26660,9090/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for celestia validator](https://github.com/kj89/testnet_manuals/blob/main/celestia/monitoring/README.md)

## Usefull commands
### Service management
Check logs
```
journalctl -fu celestia-appd -o cat
```

Start service
```
systemctl start celestia-appd
```

Stop service
```
systemctl stop celestia-appd
```

Restart service
```
systemctl restart celestia-appd
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
celestia-appd query bank balances $WALLET_ADDRESS
```

Transfer funds
```
celestia-appd tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000utia
```

### Staking, Delegation and Rewards
Delegate stake
```
celestia-appd tx staking delegate $VALOPER_ADDRESS 10000000utia --from=$WALLET --chain-id=$CHAIN_ID
```

Redelegate stake from validator to another validator
```
celestia-appd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utia --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
celestia-appd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
celestia-appd tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
celestia-appd tx staking edit-validator \
--identity=<your_keybase_id> \
--website="<your_website>" \
--details="<your_validator_description>" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
celestia-appd tx slashing unjail \
  --from=$WALLET \
  --chain-id=$CHAIN_ID
```

### Delete celestia validator and bridge node
To completely remove celesia node from server use command below (please make sure you have saved your validator key located in `~/.celestia-app/config/priv_validator_key.json`)
```
sudo systemctl stop celestia-appd
sudo systemctl disable celestia-appd
rm /etc/systemd/system/celestia-appd.service
sudo systemctl stop celestia-bridge
sudo systemctl disable celestia-bridge
rm /etc/systemd/system/celestia-bridge.service
sudo systemctl daemon-reload
cd $HOME
rm -rf .celestia-app .celestia-bridge celestia-app networks
```
