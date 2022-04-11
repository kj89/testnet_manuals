## Archway node setup

### set up your node using binaries
```
wget -O archway.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/torii/archway.sh && chmod +x archway.sh && ./archway.sh
```

### set up your node using docker
```
wget -O archway_docker.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/torii/archway_docker.sh && chmod +x archway_docker.sh && ./archway_docker.sh
```

### load variables
```
source $HOME/.bash_profile
```

### create wallet. don’t forget to save the mnemonic
```
archwayd keys add $WALLET
```

### create validator
```
archwayd tx staking create-validator \
  --amount 9000000utorii \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.1" \
  --commission-rate "0.01" \
  --min-self-delegation "1" \
  --pubkey  $(archwayd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID \
  --gas 300000 \
  --fees 3utorii
```

### (OPTIONAL) save wallet info (works only with binaries setup!)
```
WALLET_ADDRESS=$(archwayd keys show $WALLET -a)
VALOPER_ADDRESS=$(archwayd keys show $WALLET --bech val -a)
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Usefull commands
To check sync status
```
curl -s localhost:26657/status | jq .result.sync_info
```

### Service commands
To view logs
```
journalctl -fu archwayd -o cat
```

To stop
```
systemctl stop archwayd
```

To start
```
systemctl start archwayd
```

To restart
```
systemctl restart archwayd
```

### Docker commands
To view logs
```
docker logs -f archway --tail 100
```

To stop
```
docker stop archway
```

To start
```
docker start archway
```

To restart
```
docker restart archway
```

### cosmos commands
Bond more tokens (if you want increase your validator stake you should bond more to your valoper address):
```
archwayd tx staking delegate $VALOPER_ADDRESS 10000000utorii --from $WALLET --chain-id $CHAIN_ID --fees 5000utorii
```

Withdraw rewards
```
archwayd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID
```

Get wallet address
```
archwayd keys show $WALLET --bech val -a
```

Get wallet balance
```
archwayd query bank balances WALLET_ADDRESS
```

Change commision
```
archwayd tx staking edit-validator --commission-rate "0.02" --moniker=$NODENAME --chain-id=$CHAIN_ID --from=$WALLET
```

Restore wallet key
```
archwayd keys add $WALLET --recover
```

Edit validator
```
archwayd tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

### Instructions for Genesis Validators

#### Create Gentx

##### 1. Add genesis account:
```
archwayd add-genesis-account <key-name> 1000000000utorii --keyring-backend os
```

##### 2. Create Gentx
```
archwayd gentx <key-name> 1000000000utorii \
--chain-id=$CHAIN_ID \
--moniker=$NODENAME \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--details="XXXXXXXX" \
--security-contact="XXXXXXXX" \
--website="XXXXXXXX"
```

#### Submit PR with Gentx and peer id
1. Copy the contents of ${HOME}/.archwayd/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/archway-network/testnets
3. Create a file gentx-{{VALIDATOR_NAME}}.json under the networks/testnets/torii/gentx folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instruction!
