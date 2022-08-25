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

# Manual node  setup
If you want to setup validator node manually follow the steps below

## 0. Setting up vars
Put your node name here
```
NODENAME=<YOUR_NODENAME>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WORKSPACE=testnet" >> $HOME/.bash_profile
echo "export PUBLIC_IP=$(curl -s ifconfig.me)" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## 1. Update packages
```
sudo apt update && sudo apt upgrade -y
```

## 2. Install dependencies
```
sudo apt-get install jq unzip -y
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq
```

## 3. Install docker
```
sudo apt-get install ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```

## 4. Install docker compose
```
docker_compose_version=$(wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name")
sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
sudo chmod +x /usr/bin/docker-compose
```

## 5. Download Aptos CLI
```
wget -qO aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.3.1/aptos-cli-0.3.1-Ubuntu-x86_64.zip
sudo unzip -o aptos-cli.zip -d /usr/local/bin
chmod +x /usr/local/bin/aptos
rm aptos-cli.zip
```

## 6. Install Validator node

### Create directory
```
mkdir ~/$WORKSPACE && cd ~/$WORKSPACE
```

### Download config files
```
wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
wget -qO validator.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml
```

### Set logging settings
```
yq -i '.services.validator.logging.options.max-file = "3"' docker-compose.yaml
yq -i '.services.validator.logging.options.max-size = "100m"' docker-compose.yaml
```

### Generate keys
This will create four key files under `~/$WORKSPACE/keys` directory: `public-keys.yaml`, `private-keys.yaml`, `validator-identity.yaml` and `validator-full-node-identity.yaml`
```
aptos genesis generate-keys --output-dir ~/$WORKSPACE/keys
```
**IMPORTANT**: *Backup your key files somewhere safe. These key files are important for you to establish ownership of your node, 
and you will use this information to claim your rewards later if eligible. Never share those keys with anyone else.*

### Configure validator
This will create two YAML files in the `~/$WORKSPACE/$USERNAME` directory: `owner.yaml` and `operator.yaml`
```
aptos genesis set-validator-configuration \
    --local-repository-dir ~/$WORKSPACE \
    --username $NODENAME \
    --owner-public-identity-file ~/$WORKSPACE/keys/public-keys.yaml \
    --validator-host $PUBLIC_IP:6180 \
    --stake-amount 100000000000000
```
> *The --full-node-host flag is optional* Only use it if you plan or already have installed fullnode on a seperate server

### Create layout file
Layout template file defines the node in the Aptos validatorSet.
```
sudo tee layout.yaml > /dev/null <<EOF
---
root_key: "D04470F43AB6AEAA4EB616B72128881EEF77346F2075FFE68E14BA7DEBD8095E"
users:
  - $NODENAME
chain_id: 43
allow_new_validators: false
epoch_duration_secs: 7200
is_test: true
min_stake: 100000000000000
min_voting_threshold: 100000000000000
max_stake: 100000000000000000
recurring_lockup_duration_secs: 86400
required_proposer_stake: 100000000000000
rewards_apy_percentage: 10
voting_duration_secs: 43200
voting_power_increase_limit: 20
EOF
```
> Please make sure you use the same root public key as shown in the example and same chain ID, those config will be used during registration to verify your node.

### Download Aptos Framework
```
wget -qO framework.mrb https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.3.0/framework.mrb -P ~/$WORKSPACE
```

### Compile genesis blob and waypoint
This will create two files in your working directory: `genesis.blob` and `waypoint.txt`
```
aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE
```

### Run docker compose
```
docker-compose up -d
```
