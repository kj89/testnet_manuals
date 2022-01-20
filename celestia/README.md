### Create VPS on Hetzner
For celestia you have to choose CPX21
![image](https://user-images.githubusercontent.com/50621007/148914219-03784eed-cb72-4494-aa3b-5f140aadc347.png)

LOGIN as root

### Run script bellow to prepare your server
```
wget -O celestia.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/celestia/celestia.sh && chmod +x celestia.sh && ./celestia.sh
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
celestia-appd keys add $CELESTIA_NODENAME --recover --keyring-backend=test
```

### Request faucet at Discord
![image](https://user-images.githubusercontent.com/50621007/148915863-81081f40-36e7-4656-9265-11969a5f0d8e.png)


### Create validator
```
celestia-appd tx staking create-validator \
 --amount=1000000celes \
 --pubkey=$(celestia-appd tendermint show-validator) \
 --moniker=$CELESTIA_NODENAME \
 --chain-id=devnet-2 \
 --commission-rate=0.1 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1000000 \
 --from=$CELESTIA_WALLET \
 --keyring-backend=test
```

### Celestia explorer
http://celestia.observer:3080/validators

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

Check validator node status
```
curl -O https://gist.githubusercontent.com/michaelfig/2319d0573c0f6bc257de6a97e3d46b3e/raw/cf2b2b784c60359d8e49fb3fa198b5be13c816be/check-validator.js
node check-validator.js
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

## Create and Modify validator
Create validator
```
chainName=devnet-2
celestia-appd tx staking create-validator --amount=51000000000celes --broadcast-mode=block --pubkey=`celestia-appd tendermint show-validator` --moniker=kj-nodes.xyz --website="http://kj-nodes.xyz" --details="One of TOP 25 performing validators on Celestia testnet with highest uptime. Uptime is important to me. Server is constantly being monitored and maintained. You can contact me at discord: kristaps#8455 or telegram: @janispaegle" --commission-rate="0.07" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1" --from=celestia-wallet --chain-id=$chainName --gas-adjustment=1.4 --fees=5001celes
```

Modify validator
```
chainName=devnet-2
celestia-appd tx staking edit-validator --moniker="kj-nodes.xyz" --website="http://kj-nodes.xyz" --details="One of TOP 25 performing validators on celestia testnet with highest uptime. Uptime is important to me. Server is constantly being monitored and maintained. You can contact me at discord: kristaps#8455 or telegram: @janispaegle" --chain-id=$chainName --from=celestia-wallet
```

## Wallet operations
Recover wallet
```
celestia-appd keys add celestia-wallet --recover
```

Get wallet balance
```
celestia-appd query bank balances $(celestia-appd keys show celestia-wallet -a)
```

List of wallets
```
celestia-appd keys list
```

Delete wallet
```
celestia-appd keys delete celestia-wallet
```

## Configruation reset
Reset configs
```
celestia-appd unsafe-reset-all
```

## Staking, Delegation and Rewards
Delegate stake
```
chainName=devnet-2
celestia-appd tx staking delegate $(celestia-appd keys show celestia-wallet --bech val -a) 470000000celes --from=celestia-wallet --chain-id=$chainName --gas=auto --keyring-dir=$HOME/.celestia-appd --keyring-backend=test
```

Redelegate stake from validator to another validator
```
chainName=devnet-2
celestia-appd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 5000000celes --from=celestia-wallet --chain-id=$chainName --gas=auto --keyring-dir=$HOME/.celestia-appd
```

Withdraw rewards
```
chainName=devnet-2
celestia-appd tx distribution withdraw-all-rewards --from=celestia-wallet --chain-id=$chainName --gas=auto --keyring-dir=$HOME/.celestia-appd
```

### Migrate celestia validator to another VPS
1. First of all you have to backup your configuration files on your old validator node located in `~/.celestia-appd/config/`
2. Set up new VPS
3. Stop service and disable daemon on old validator node
```
sudo systemctl stop celestia-appd
sudo systemctl disable celestia-appd
```

_(Be sure that your ag-chain-cosmos is not running on the old machine. If it is, you will be slashed for double-signing.)_

4. Use guide for validator node setup - [Validator Guide for Incentivized Testnet](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Incentivized-Testnet)
>When you reach step [Syncing Your Node](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Incentivized-Testnet#syncing-your-node) you have to copy and replace configuration files located in `~/.celestia-appd/config/` with those we saved in step 1
5. Finish setup by synchronizing your node with network
6. After your node catch up you have to restore your key. For that you will need 24-word mnemonic you saved on key creation
>To recover your key follow this guide - [How do I recover a key?](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Devnet#how-do-i-recover-a-key)
7. Make sure your validator is not jailed
>To unjail use this guide - [How do I unjail my validator?](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide#how-do-i-unjail-my-validator)
8. After you ensure your validator is producing blocks in explorer and is healthy you can shut down old validator server
