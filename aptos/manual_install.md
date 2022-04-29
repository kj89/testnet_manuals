# Manual node  setup
If you want to setup fullnode manually follow the steps below

## 1. Update packages
```
sudo apt update && sudo apt upgrade -y
```

## 2. Install dependencies
```
sudo apt-get install jq -y
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq
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
wget -O docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/docker-compose.yaml
wget -O public_full_node.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/public_full_node.yaml
wget -O genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -O waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
```

## 6. Generate or recover your identity keys
At this step you have two options. You can generate new identity keys or recover from existing ones. Choose option that fits your case

### Option 1 - Generate new identity keys
```
docker run --rm --name aptos_tools -d -i aptoslab/tools:devnet
docker exec -it aptos_tools aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file $HOME/private-key.txt
echo "export KEY=$(docker exec -it aptos_tools cat $HOME/private-key.txt)" >> $HOME/.bash_profile
PEER_ID=$(docker exec -it aptos_tools aptos-operational-tool extract-peer-from-file --encoding hex --key-file $HOME/private-key.txt --output-file $HOME/peer-info.yaml | jq -r '.. | .keys?  | select(.)[]')
echo "export PEER_ID=$PEER_ID" >> $HOME/.bash_profile
source $HOME/.bash_profile
docker stop aptos_tools
```

### Option 2 - Recover your keys
If you want to recover your keys please fill out identity and run script below
```
echo "export KEY=<YOUR_KEY>" >> $HOME/.bash_profile
echo "export PEER_ID=<YOUR_PEER_ID>" >> $HOME/.bash_profile
source ./.bash_profile
```

## Update configs
```
yq e -i '.full_node_networks[0].identity.type="from_config"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.key="'$KEY'"' public_full_node.yaml \
&& yq e -i '.full_node_networks[0].identity.peer_id="'$PEER_ID'"' public_full_node.yaml 
```

## Update seeds
```
wget -O seeds.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/seeds.yaml
yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml seeds.yaml
```

# Start application
```
docker compose up -d
```
