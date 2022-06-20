<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our refferal link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
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
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
sudo chown $USER /var/run/docker.sock
```

## 5. Download Aptos CLI
```
wget -qO aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.1.1/aptos-cli-0.1.1-Ubuntu-x86_64.zip
unzip -o aptos-cli.zip -d /usr/local/bin
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
wget -qO docker-compose.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/docker-compose.yaml
wget -qO fullnode.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/fullnode.yaml
wget -qO validator.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/validator.yaml
```

### Generate keys
This will create three files: `$NODENAME.yaml`, `validator-identity.yaml`, `validator-full-node-identity.yaml` for you.
```
aptos genesis generate-keys --output-dir ~/$WORKSPACE
```
**IMPORTANT**: *Backup your key files somewhere safe. These key files are important for you to establish ownership of your node, 
and you will use this information to claim your rewards later if eligible. Never share those keys with anyone else.*

### Configure validator
```
aptos genesis set-validator-configuration \
  --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
  --username $NODENAME \
  --validator-host $PUBLIC_IP:6180 \
  --full-node-host $PUBLIC_IP:6182
```
  
### Generate root key
```
mkdir keys
aptos key generate --assume-yes --output-file keys/root
ROOT_KEY="0x"$(cat ~/$WORKSPACE/keys/root.pub)
```

### Create layout file
```
tee layout.yaml > /dev/null <<EOF
---
root_key: "$ROOT_KEY"
users:
  - $NODENAME
chain_id: 23
EOF
```

### Download Aptos Framework
```
wget -qO framework.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip
unzip -o framework.zip
rm framework.zip
```

### Compile genesis blob and waypoint
```
aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE
```

### Run docker compose
```
docker compose up -d
```
