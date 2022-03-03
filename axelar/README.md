## Celestia node setup

### Run validator node
```
wget -O celestia.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/celestia.sh && chmod +x celestia.sh && ./celestia.sh
```

### Run full node
```
wget -O celestia_full.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/celestia_full.sh && chmod +x celestia_full.sh && ./celestia_full.sh
```

### Run light node
```
wget -O celestia_light.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/celestia_light.sh && chmod +x celestia_light.sh && ./celestia_light.sh
```

### Run this command to load environment variables
```
. $HOME/.bash_profile
```

### Check if node synchronyzed with latest block
Before you create you validator make sure you are fully synced with the network
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```
In the output of the above command make sure catching_up is false

### Create wallet
```
~/networks/scripts/1_create_key.sh $CELESTIA_WALLET
```

### Restore your wallet in case if you created it before
```
celestia-appd keys add $CELESTIA_WALLET --recover
```

### Request faucet at Discord
![image](https://user-images.githubusercontent.com/50621007/148915863-81081f40-36e7-4656-9265-11969a5f0d8e.png)


### Create validator
_Amount of tokens is 1 to 1 000 000_
```
celestia-appd tx staking create-validator \
 --amount=1000000celes \
 --pubkey=$(celestia-appd tendermint show-validator) \
 --moniker=$CELESTIA_NODENAME \
 --chain-id=$CELESTIA_CHAIN \
 --commission-rate=0.1 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1000000 \
 --from=$CELESTIA_WALLET
```

### Celestia explorer
http://celestia.observer

### Usefull commands
## Service management
Check logs
```
journalctl -fu celestia-appd
```

Stop celestia service
```
service celestia-appd stop
```

Start celestia service
```
service celestia-appd start
```

Configuration file
```
vim ~/.celestia-appd/config/config.toml
```

## Node info
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

## Modify validator
Modify validator
```
celestia-appd tx staking edit-validator \
 --moniker=$CELESTIA_NODENAME \
--website="http://kjnodes.com" \
--identity=1C5ACD2EEF363C3A \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CELESTIA_CHAIN \
--from=$CELESTIA_WALLET
```

## Wallet operations
Send funds
```
celestia-appd tx bank send <address1> <address2> 1000000celes
```

Recover wallet
```
celestia-appd keys add $CELESTIA_WALLET --recover
```

Get wallet balance
```
celestia-appd query bank balances $(celestia-appd keys show $CELESTIA_WALLET -a)
```

List of wallets
```
celestia-appd keys list
```

Delete wallet
```
celestia-appd keys delete $CELESTIA_WALLET
```

## Configruation reset
Reset configs
```
celestia-appd unsafe-reset-all
```

## Staking, Delegation and Rewards
Delegate stake
```
celestia-appd tx staking delegate $(celestia-appd keys show $CELESTIA_WALLET --bech val -a) 1000000celes --from=$CELESTIA_WALLET --chain-id=$CELESTIA_CHAIN --gas=auto --keyring-dir=$HOME/.celestia-appd
```

Redelegate stake from validator to another validator
```
celestia-appd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 1000000celes --from=$CELESTIA_WALLET --chain-id=$CELESTIA_CHAIN --gas=auto --keyring-dir=$HOME/.celestia-appd
```

Withdraw rewards
```
celestia-appd tx distribution withdraw-all-rewards --from=$CELESTIA_WALLET --chain-id=$CELESTIA_CHAIN --gas=auto --keyring-dir=$HOME/.celestia-appd
```

### Migrate celestia validator to another VPS
1. First of all you have to backup your configuration files on your old validator node located in `~/.celestia-appd/config/`
2. Set up new VPS
3. Stop service and disable daemon on old validator node
```
sudo systemctl stop celestia-appd
sudo systemctl disable celestia-appd
```

_(Be sure that your celestia-appd is not running on the old machine. If it is, you will be slashed for double-signing.)_

4. Install new validator
5. Copy and replace configuration files located in `~/.celestia-appd/config/` with those we saved in step 1
6. Finish setup by synchronizing your node with network
7. After you ensure your validator is producing blocks in explorer and is healthy you can shut down old validator server
