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

# Manual node  setup
If you want to setup fullnode manually follow the steps below

## 1. Update packages
```
sudo apt update && sudo apt upgrade -y
```

## 2. Install dependencies
```
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq
sudo apt-get install jq -y
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
curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
sudo chown $USER /var/run/docker.sock
```

## 5. Download configs
```
mkdir $HOME/aptos && cd $HOME/aptos
wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/docker-compose.yaml
wget -qO public_full_node.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/public_full_node.yaml
wget -qO genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -qO waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
```

## 6. Generate or recover your identity keys
At this step you have two options. You can generate new identity keys or recover from existing ones. Choose option that fits you more

### Option 1 - Generate new identity keys (run commands 
```
wget -qO generate_keys.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/tools/generate_keys.sh && chmod +x generate_keys.sh && ./generate_keys.sh
```

### Option 2 - Recover your keys
If you want to recover your keys please fill out identity and run script below
```
echo "export KEY=<YOUR_KEY>" >> $HOME/.bash_profile
echo "export PEER_ID=<YOUR_PEER_ID>" >> $HOME/.bash_profile
```

## Update configs
```
source $HOME/.bash_profile
yq e -i '.full_node_networks[0].identity.type="from_config"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.key="'$KEY'"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].listen_address = "/ip4/0.0.0.0/tcp/6180"' public_full_node.yaml \
&& yq -i '.services.fullnode.ports += "6180:6180"' docker-compose.yaml
```

## Update seeds
```
wget -qO seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml seeds.yaml
```

# Start application
```
docker compose up -d
```
