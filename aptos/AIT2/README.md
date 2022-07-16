<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/EY35ZzXY" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/165930080-4f541b46-1ae3-461c-acc9-de72d7ab93b7.png">
</p>

# Connecting to AIT2
Do this only if you received the confirmation email from Aptos team for your eligibility. Nodes not selected will not have enough tokens to join the testnet. You can still run public fullnode in this case if you want.

## Official documentation and tools
>Official docs: https://aptos.dev/nodes/ait/connect-to-testnet/
>
>Status page: https://community.aptoslabs.com/it2

## Bootstrapping validator node
Before joining the testnet, you need to bootstrap your node with the genesis blob and waypoint provided by Aptos Labs team. This will convert your node from test mode to prod mode. AIT2 network Chain ID is 41.

### 1. Install yq
```
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq
sudo apt-get install jq -y
```

### 2. Prepare Aptos validator node
```
cd $HOME/testnet
docker compose down --volumes
sudo wget -qO genesis.blob https://github.com/aptos-labs/aptos-ait2/raw/main/genesis.blob
sudo wget -qO waypoint.txt https://raw.githubusercontent.com/aptos-labs/aptos-ait2/main/waypoint.txt
sudo wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
yq -i '.services.validator.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_f5d8013b0a1851da8e078394d83130d3adaf7670}"' docker-compose.yaml
yq -i '(.services.validator.ports[] | select(. == "80:8080")) = "127.0.0.1:80:8080"' docker-compose.yaml
yq -i '(.services.validator.ports[] | select(. == "9101:9101")) = "127.0.0.1:9101:9101"' docker-compose.yaml
yq -i 'del( .services.validator.expose[] | select(. == "80" or . == "9101") )' docker-compose.yaml
docker compose up -d
```

### 3. (OPTIONAL) Prepare Aptos fullnode (!!!RUN THIS ON YOUR FULLNODE MACHINE ONLY IF YOU HAVE IT!!!)
```
cd $HOME/testnet
docker compose down --volumes
sudo wget -qO genesis.blob https://github.com/aptos-labs/aptos-ait2/raw/main/genesis.blob
sudo wget -qO waypoint.txt https://raw.githubusercontent.com/aptos-labs/aptos-ait2/main/waypoint.txt
sudo wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose-fullnode.yaml
yq -i '.services.fullnode.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_f5d8013b0a1851da8e078394d83130d3adaf7670}"' docker-compose.yaml
docker compose up -d
```

## Joining Validator Set
All the selected validator node will be receiving sufficient amount of test coin (100,100,000) airdrop from Aptos Labs team to stake their node. 
The coin airdrop will happen in batches to make sure we don't have too many nodes joining at the same time, please check your balance before exeucting those steps. 

### 1. Check your account balance
```
https://explorer.devnet.aptos.dev/account/<YOUR_ACCOUNT_ADDRESS>?network=ait2
```

### 2. Init validator
```
cd $HOME/testnet
ACC_PRIVATE_KEY=$(cat $HOME/testnet/private-keys.yaml | yq .account_private_key)
aptos init --profile ait2 \
--private-key $ACC_PRIVATE_KEY \
--rest-url http://ait2.aptosdev.com \
--skip-faucet
```

### 3. Check your validator account balance
```
aptos account list --profile ait2
```
This will show you the coin balance you have in the validator account. You should be able to see something like:
```
"coin": {
    "value": "100100000"
  }
```

### 4. Register validator candidate on chain
```
cd $HOME/testnet
aptos node register-validator-candidate \
--profile ait2 \
--validator-config-file $NODENAME.yaml
```

### 5. Add stake to your validator node
```
aptos node add-stake --amount 100000000 --profile ait2
```

### 6. Set lockup time for your stake
Longer lockup time will result in more staking reward. Minimal lockup time is 24 hours, and maximal is 5 days.
```
aptos node increase-lockup \
--profile ait2 \
--lockup-duration 72h
```

### 7. Join validator set
```
aptos node join-validator-set --profile ait2
```
ValidatorSet will be updated at every epoch change, which is once every hour. You will only see your node joining the validator set in next epoch. Both Validator and fullnode will start syncing once your validator is in the validator set.

### 8. Check validator set
```
aptos node show-validator-set --profile ait2 | jq -r '.Result.pending_active' | grep $(cat $HOME/testnet/$NODENAME.yaml | yq .account_address)
```
You should be able to see your validator node in "pending_active" list. And when the next epoch change happens, the node will be moved into "active_validators" list. 
This should happen within one hour from the completion of previous step. During this time, you might see errors like "No connected AptosNet peers", which is normal.
```
aptos node show-validator-set --profile ait2 | jq -r '.Result.active_validators' | grep $(cat $HOME/testnet/$NODENAME.yaml | yq .account_address)
```

## Verify node connections
You can check the details about node liveness definition here. Once your validator node joined the validator set, you can verify the correctness following those steps:

### 1. Verify that your node is connecting to other peers on testnet. (Replace 127.0.0.1 with your Validator IP/DNS if deployed on the cloud)
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep "aptos_connections{.*\"Validator\".*}"
```
The command will output the number of inbound and outbound connections of your Validator node. For example:
```
aptos_connections{direction="inbound",network_id="Validator",peer_id="2a40eeab",role_type="validator"} 5
aptos_connections{direction="outbound",network_id="Validator",peer_id="2a40eeab",role_type="validator"} 2
```
As long as one of the metrics is greater than zero, your node is connected to at least one of the peers on the testnet.

### 2. You can also check if your node is connected to AptosLabs's node, replace <Aptos Peer ID> with the peer ID shared by Aptos team.
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep "aptos_network_peer_connected{.*remote_peer_id=\"83424ccb\".*}"
```
Once your node state sync to the latest version, you can also check if consensus is making progress, and your node is proposing
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep "aptos_consensus_current_round"
curl 127.0.0.1:9101/metrics 2> /dev/null | grep "aptos_consensus_proposals_count"
```
You should expect to see this number keep increasing.

## Update aptos validator
```
cd $HOME/testnet
yq -i '.services.validator.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_f5d8013b0a1851da8e078394d83130d3adaf7670}"' docker-compose.yaml
docker compose up -d
```

## Update aptos fullnode
```
cd $HOME/testnet
yq -i '.services.fullnode.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_f5d8013b0a1851da8e078394d83130d3adaf7670}"' docker-compose.yaml
docker compose up -d
```

## Configure Logging validator
```
cd $HOME/testnet
yq -i '.services.validator.logging.options.max-file = "3"' docker-compose.yaml
yq -i '.services.validator.logging.options.max-size = "100m"' docker-compose.yaml
docker compose down && docker compose up -d
```

## Configure Logging fullnode
```
cd $HOME/testnet
yq -i '.services.fullnode.logging.options.max-file = "3"' docker-compose.yaml
yq -i '.services.fullnode.logging.options.max-size = "100m"' docker-compose.yaml
docker compose down && docker compose up -d
```
