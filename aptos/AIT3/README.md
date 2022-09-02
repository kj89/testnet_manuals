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
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/165930080-4f541b46-1ae3-461c-acc9-de72d7ab93b7.png">
</p>

# Connecting to AIT3
Do this only if you received the confirmation email from Aptos team for your eligibility. Nodes not selected will not have enough tokens to join the testnet. You can still run public fullnode in this case if you want.

## Official documentation and tools
>Official docs: https://aptos.dev/nodes/ait/connect-to-testnet/
>
>Status page: https://aptoslabs.com/leaderboard/it3

## Initialize staking pool

![image](https://user-images.githubusercontent.com/50621007/187426972-c3fa0d36-2cd7-4cc1-9ff1-30142a8b4b34.png)

> **Warning** **BEFORE YOU PROCEED**\
> Proceed to the below steps only if you are selected to participate in the AIT-3.

1. Confirm that you received the token from the Aptos team by checking the balance of your Petra wallet. Make sure you are connected to the AIT-3 network by click `Settings → Network`.

2. Create another wallet address for the voter. See [the above Step 4: Create the wallet using Petra](https://aptos.dev/nodes/ait/steps-in-ait3/#create-wallet) to create a wallet on Petra. This step is optional. You can use the owner wallet account as voter wallet as well. However, the best practice is to have a dedicate voting account so that you do not need to access your owner key frequently for governance operations.

3. Next you will stake and delegate.

> **Note** **READ THE STAKING DOCUMENT**\
> Make sure you read the Staking documentation before proceeding further.

You will begin by initializing the staking pool and delegating to the operator and the voter.

- From the Chrome browser, go to the **[Staking section](https://explorer.devnet.aptos.dev/proposals/staking?network=ait3)** of the Aptos Governance page for AIT-3.
- Make sure the wallet is connected with your owner account.
- Provide the following inputs:
  - Staking Amount: `100000000000000` (1 million Aptos coin with 8 decimals)
  - Operator Address: The address of your operator account. This is the `operator_account_address` from the `operator.yaml` file, under `~/$WORKSPACE/$NODENAME` folder.
  - Voter Address: The wallet address of your voter.

![image](https://user-images.githubusercontent.com/50621007/187432341-db51b7f0-f137-4f70-8ef9-eab2962d7c46.png)

- Click **SUBMIT**. You will see a green snackbar indicating that the transaction is successful.

4. Next, as the owner, using Petra wallet, transfer `50000` coin each to your operator address and voter wallet address. Both the operator and the voter will use these funds to pay the gas fees while validating and voting.

5. Proceed to **Bootstrapping validator node**

## Bootstrapping validator node
Before joining the testnet, you need to bootstrap your node with the genesis blob and waypoint provided by Aptos Labs team. This will convert your node from test mode to prod mode. AIT3 network Chain ID is 47.

### 1. Install yq
```bash
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.27.3/yq_linux_amd64 && chmod +x /usr/local/bin/yq
sudo apt-get install jq -y
```

### 2. Update Aptos CLI
```bash
wget -qO aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.3.2/aptos-cli-0.3.2-Ubuntu-x86_64.zip
sudo unzip -o aptos-cli.zip -d /usr/local/bin
chmod +x /usr/local/bin/aptos
rm aptos-cli.zip
```

### 3. Prepare Aptos validator node
Set up your Petra wallet owner address
```bash
OWNER_ADDRESS=<PETRA_WALLET_OWNER_ADDRESS>
```

Load variables into system
```bash
echo "export OWNER_ADDRESS=${OWNER_ADDRESS}" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

Prepare configruation files and run docker
```bash
cd $HOME/$WORKSPACE
docker-compose down --volumes
sudo wget -qO genesis.blob https://github.com/aptos-labs/aptos-ait3/raw/main/genesis.blob
sudo wget -qO waypoint.txt https://raw.githubusercontent.com/aptos-labs/aptos-ait3/main/waypoint.txt
sudo wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
yq -i ".account_address = \"$OWNER_ADDRESS\"" keys/validator-identity.yaml
yq -i '.services.validator.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_4219d75c57115805f0faf0ad07c17becf6580202}"' docker-compose.yaml
yq -i '(.services.validator.ports[] | select(. == "80:8080")) = "127.0.0.1:80:8080"' docker-compose.yaml
yq -i '(.services.validator.ports[] | select(. == "9101:9101")) = "127.0.0.1:9101:9101"' docker-compose.yaml
yq -i 'del( .services.validator.expose[] | select(. == "80" or . == "9101") )' docker-compose.yaml
yq -i '.services.validator.logging.options.max-file = "3"' docker-compose.yaml
yq -i '.services.validator.logging.options.max-size = "100m"' docker-compose.yaml
yq -i '.services.validator.ulimits.nofile.soft = 100000' $HOME/testnet/docker-compose.yaml
yq -i '.services.validator.ulimits.nofile.hard = 100000' $HOME/testnet/docker-compose.yaml
docker-compose up -d
```

### 4. (OPTIONAL) Prepare Aptos fullnode 
> **Warning** **RUN THIS ON YOUR FULLNODE MACHINE ONLY IF YOU HAVE IT!**
```bash
cd $HOME/testnet
docker-compose down --volumes
sudo wget -qO genesis.blob https://github.com/aptos-labs/aptos-ait3/raw/main/genesis.blob
sudo wget -qO waypoint.txt https://raw.githubusercontent.com/aptos-labs/aptos-ait3/main/waypoint.txt
sudo wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose-fullnode.yaml
yq -i '.services.fullnode.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_4219d75c57115805f0faf0ad07c17becf6580202}"' docker-compose.yaml
yq -i '.services.fullnode.logging.options.max-file = "3"' docker-compose.yaml
yq -i '.services.fullnode.logging.options.max-size = "100m"' docker-compose.yaml
yq -i '.services.fullnode.ulimits.nofile.soft = 100000' $HOME/testnet/docker-compose.yaml
yq -i '.services.fullnode.ulimits.nofile.hard = 100000' $HOME/testnet/docker-compose.yaml
docker-compose up -d
```

## Joining Validator Set
All the selected validator node will be receiving sufficient amount of test coin (100,100,000) airdrop from Aptos Labs team to stake their node. 
The coin airdrop will happen in batches to make sure we don't have too many nodes joining at the same time, please check your balance before exeucting those steps. 

### 1. Check your account balance
```
https://explorer.devnet.aptos.dev/account/<YOUR_ACCOUNT_ADDRESS>?network=ait3
```

### 2. Init validator
```bash
cd $HOME/$WORKSPACE
ACC_PRIVATE_KEY=$(cat $HOME/$WORKSPACE/keys/private-keys.yaml | yq .account_private_key)
aptos init --profile ait3-operator \
  --private-key $ACC_PRIVATE_KEY \
  --rest-url http://ait3.aptosdev.com \
  --skip-faucet
```

Output:
```json
{
  "Result": "Success"
}
```

### 3. Check your validator account balance
```bash
aptos account list --profile ait3-operator 
```
This will show you the coin balance you have in the validator account. You should be able to see something like:
```json
...
"coin": {
  "value": "5000"
},
...
```

### 4. Update validator network addresses on chain
```bash
cd $HOME/$WORKSPACE
aptos node update-validator-network-addresses  \
  --pool-address $OWNER_ADDRESS \
  --operator-config-file ~/$WORKSPACE/$NODENAME/operator.yaml \
  --profile ait3-operator
```

Output:
```json
{
  "Result": {
    "transaction_hash": "0x8d39485fcf413215ff3bd08ef312f0c3a434459536e359cdf3158c044018b813",
    "gas_used": 99,
    "gas_unit_price": 1,
    "sender": "bbc95fd36de8dca25432742b9c7306aacd6934c6bfb5354c5b67850b5b68afb1",
    "sequence_number": 1,
    "success": true,
    "timestamp_us": 1661856127240106,
    "version": 387504,
    "vm_status": "Executed successfully"
  }
}
```

### 5. Update validator consensus key on chain
```bash
cd $HOME/$WORKSPACE
aptos node update-consensus-key  \
  --pool-address $OWNER_ADDRESS \
  --operator-config-file ~/$WORKSPACE/$NODENAME/operator.yaml \
  --profile ait3-operator
```

Output:
```json
{
  "Result": {
    "transaction_hash": "0xd80d3f25b9c4bdba63e095357145d48cd2aaab1de19f14882ac237dd4701f6db",
    "gas_used": 104,
    "gas_unit_price": 1,
    "sender": "bbc95fd36de8dca25432742b9c7306aacd6934c6bfb5354c5b67850b5b68afb1",
    "sequence_number": 2,
    "success": true,
    "timestamp_us": 1661856360125096,
    "version": 389109,
    "vm_status": "Executed successfully"
  }
}
```

### 6. Join validator set
```bash
cd $HOME/$WORKSPACE
aptos node join-validator-set \
  --pool-address $OWNER_ADDRESS \
  --profile ait3-operator \
  --max-gas 20000
```

Output:
```json
{
  "Result": {
    "transaction_hash": "0x5d702e4d58f31a0edf7e55db7a34118ebcda42f9a3ceeda5087621ec50f1f8d2",
    "gas_used": 1815,
    "gas_unit_price": 1,
    "sender": "bbc95fd36de8dca25432742b9c7306aacd6934c6bfb5354c5b67850b5b68afb1",
    "sequence_number": 6,
    "success": true,
    "timestamp_us": 1661856737106161,
    "version": 391698,
    "vm_status": "Executed successfully"
  }
}
```
ValidatorSet will be updated at every epoch change, which is once every 2 hours. You will only see your node joining the validator set in next epoch. Both Validator and fullnode will start syncing once your validator is in the validator set.

### 7. Check validator set
```bash
cd $HOME/$WORKSPACE
aptos node show-validator-set --profile ait3-operator | jq -r ".Result.pending_active[]? | select(.addr == \"$OWNER_ADDRESS\")"
```
You should be able to see your validator node in "pending_active" list. And when the next epoch change happens, the node will be moved into "active_validators" list. 
This should happen within one hour from the completion of previous step. During this time, you might see errors like "No connected AptosNet peers", which is normal.
```bash
cd $HOME/$WORKSPACE
aptos node show-validator-set --profile ait3-operator | jq -r ".Result.active_validators[]? | select(.addr == \"$OWNER_ADDRESS\")"
```

## Verify node connections
You can check the details about node liveness definition here. Once your validator node joined the validator set, you can verify the correctness following those steps:

### 1. Verify that your node is connecting to other peers on testnet. (Replace 127.0.0.1 with your Validator IP/DNS if deployed on the cloud)
```bash
curl 127.0.0.1:9101/metrics 2> /dev/null | grep "aptos_connections{.*\"Validator\".*}"
```
The command will output the number of inbound and outbound connections of your Validator node. For example:
```
aptos_connections{direction="inbound",network_id="Validator",peer_id="2a40eeab",role_type="validator"} 5
aptos_connections{direction="outbound",network_id="Validator",peer_id="2a40eeab",role_type="validator"} 2
```
As long as one of the metrics is greater than zero, your node is connected to at least one of the peers on the testnet.

### 2. You can also check if your node is connected to AptosLabs's node, replace <Aptos Peer ID> with the peer ID shared by Aptos team.
```bash
curl 127.0.0.1:9101/metrics 2> /dev/null | grep "aptos_network_peer_connected{.*remote_peer_id=\"f326fd30\".*}"
```
Once your node state sync to the latest version, you can also check if consensus is making progress, and your node is proposing
```bash
curl 127.0.0.1:9101/metrics 2> /dev/null | grep "aptos_consensus_current_round"
curl 127.0.0.1:9101/metrics 2> /dev/null | grep "aptos_consensus_proposals_count"
```
You should expect to see this number keep increasing.

## Update aptos validator
```bash
cd $HOME/$WORKSPACE
yq -i '.services.validator.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_4219d75c57115805f0faf0ad07c17becf6580202}"' docker-compose.yaml
docker-compose up -d
```

## Update aptos fullnode
```bash
cd $HOME/$WORKSPACE
yq -i '.services.fullnode.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_4219d75c57115805f0faf0ad07c17becf6580202}"' docker-compose.yaml
docker-compose up -d
```

## Configure round_initial_timeout_ms
```bash
cd $HOME/$WORKSPACE
yq -i '.consensus.round_initial_timeout_ms = 2000' validator.yaml
docker-compose down && docker-compose up -d
```

## Usefull commands
Get Aptos stake expiration date and time
```bash
date -u -d @$(aptos account list --profile ait3-operator | jq -r '.Result |.[3] | .locked_until_secs') +"%Y-%m-%d %H:%M:%S"
```

Get current date and time
```bash
date +"%Y-%m-%d %H:%M:%S"
```

Get time left
```bash
lockup_end_time=$(aptos account list --profile ait3-operator | jq -r '.Result |.[3] | .locked_until_secs')
current_time=$(date +%s)
time_left=$(echo "$current_time - $lockup_end_time" | bc)
time_left=$((-time_left))
printf '%02dh:%02dm:%02ds\n' $((time_left/3600)) $((time_left%3600/60)) $((time_left%60))
```


Increase open file limit for validator node
```bash
yq -i '.services.validator.ulimits.nofile.soft = 100000' $HOME/testnet/docker-compose.yaml
yq -i '.services.validator.ulimits.nofile.hard = 100000' $HOME/testnet/docker-compose.yaml
```

Increase open file limit for fullnode
```bash
yq -i '.services.fullnode.ulimits.nofile.soft = 100000' $HOME/testnet/docker-compose.yaml
yq -i '.services.fullnode.ulimits.nofile.hard = 100000' $HOME/testnet/docker-compose.yaml
```

reduce disk size using state-sync on validator node
```
yq -i '.services.validator.state_sync.state_sync_driver.bootstrapping_mode = DownloadLatestStates' $HOME/testnet/docker-compose.yaml
yq -i '.services.validator.state_sync.data_streaming_service.max_concurrent_requests = 3' $HOME/testnet/docker-compose.yaml
```

reduce disk size using state-sync on fullnode
```
yq -i '.services.fullnode.state_sync.state_sync_driver.bootstrapping_mode = DownloadLatestStates' $HOME/testnet/docker-compose.yaml
yq -i '.services.fullnode.state_sync.data_streaming_service.max_concurrent_requests = 3' $HOME/testnet/docker-compose.yaml
```

## Leaving Validator Set
A node can choose to leave validator set at anytime, or it would happen automatically when there's not sufficient stake on the validator account. To leave validator set, you can perform the following steps:

### 1. Leave validator set (will take effect in next epoch)
```bash
aptos node leave-validator-set --profile ait3
```
### 2. Unlock the stake amount as you want. (will take effect in next epoch)
```bash
aptos node unlock-stake --amount 100000000 --profile ait3
```
### 3. Withdraw stake back to your account. (This will withdraw all the unlocked stake from your validator staking pool)
```bash
aptos node withdraw-stake --profile ait3
```

Once you're done withdrawing your fund, now you can safely shutdown the node

## Shutdown and delete your Node for Incentivized Testnet
> **Warning** **BEFORE YOU PROCEED**\
> Make sure you have backed up your node identity files: `private-keys.yaml`, `validator-identity.yaml`, `validator-full-node-identity.yaml`

### Stop your node and remove the data volumes
```bash
cd $HOME/$WORKSPACE
docker-compose down --volumes
cd $HOME && rm -rf $WORKSPACE
```

# AIT3 are incentivizing people who run VFNs alongside their validators. To get the reward, you must meet the following criteria:
* Have your VFN registered on chain in the validator set.
* Run your VFN with the API enabled, listening on either port 80, 8080, or 443 (for https).
* Pass the evaluation performed by our Node Health Checker for the majority of the AIT. We will be checking continuously!

> **Note**
> We’re only just starting to track this now, so it’s not too late to start running a VFN!

**Q: How do I check myself whether the VFN is meeting the criteria?**\
**A: Check using the Node Health Checker:**
```bash
FULLNODE_IP=<YOUR_FULLNODE_IP>
FULLNODE_API_PORT=80
```

1. Query NHC
```bash
curl "https://node-checker.prod.gcp.aptosdev.com/check_node?node_url=http://${FULLNODE_IP}&api_port=${FULLNODE_API_PORT}&baseline_configuration_name=ait3_vfn" > /tmp/nhc_out
```

2. Check that your node is healthy
```bash
cat /tmp/nhc_out | jq .summary_explanation
```

Successful output:
```json
"100: Awesome!"
```

> **Note**
> Make sure the address you’re using for the check is the same address registered in the validator set.

**Q: What if it doesn’t say “100: Awesome”?**\
**A: Read the output of /tmp/nhc_out, it should tell you what is wrong. Likely your VFN is down, the API is disabled, or the API is running on a port besides 80, 8080, or 443.**

**Q: How do I know what VFN I registered on chain?**\
**A: Unfortunately we don’t have a good way to do that right now, but we have CLI improvements coming.**

**Q: Okay what if I don’t know then?**\
**A: You can update the VFN you’ve registered in the validator set with this command:**
```bash
aptos node update-validator-network-addresses  \
  --pool-address <owner-address> \
  --full-node-host <fullnode-host:port>\
  --full-node-network-public-key <fullnode-public-key> \
  --profile ait3-operator
```

**Q: What if I didn’t register a VFN at all and I want to run one?**\
**A: Run your VFN then register it using this above command.**

**Q: How do I learn more about what NHC is doing?**\
**A: Check out these articles:**
- https://aptos.dev/nodes/node-health-checker
- https://aptos.dev/nodes/node-health-checker-faq

**Q: Do I have to run a VFN as part of AIT3?**\
**A: You don't have to, but you should if you want to gain the reward of an extra 200 Aptos tokens.**

# Node updates

## Update Aptos validator
```
cd $HOME/testnet
yq -i '.services.validator.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_4219d75c57115805f0faf0ad07c17becf6580202}"' docker-compose.yaml
docker-compose up -d
```

## Update Aptos fullnode
```
cd $HOME/testnet
yq -i '.services.fullnode.image = "${VALIDATOR_IMAGE_REPO:-aptoslabs/validator}:${IMAGE_TAG:-testnet_4219d75c57115805f0faf0ad07c17becf6580202}"' docker-compose.yaml
docker-compose up -d
```
