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

### Usefull commands
Synchronization info
```
curl -s localhost:26657/status | jq .result | jq .sync_info
```

Validator info
```
celestia-appd status 2>&1 | jq .ValidatorInfo
```

Node info
```
celestia-appd status 2>&1 | jq .NodeInfo
```

List of wallets
```
celestia-appd keys list
```

Reset configs
```
celestia-appd unsafe-reset-all
```

Get wallet balance
```
celestia-appd query bank balances $(celestia-appd keys show $CELESTIA_WALLET -a --keyring-backend test)
```

### Celestia explorer
http://celestia.observer:3080/validators
