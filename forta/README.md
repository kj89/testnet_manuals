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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/166480394-78f4659d-f4d8-4194-80de-a4080b207978.png">
</p>

# Manual node  setup
If you want to setup fullnode manually follow the steps below

Official documentation:
> [Run a Scan Node](https://docs.forta.network/en/latest/scanner-quickstart/)

Explorer:
> https://explorer.forta.network/network

## Hardware requirements:
#### For running a Forta scan node we recommend the following:
- CPU: 4 cores
- Memory: 16GB RAM
- SSD: 100GB drive space

## Preparation
### 1. Create new metamask wallet and fund it with 1 MATIC in Polygon network. This address will be used as forta owner
### 2. Register at https://moralis.io/ to generate proxy rpc url

## 0. Set environment variables
```
rm ~/.bash_profile
echo "export FORTA_PASSPHRASE=<YOUR_PASSPHRASE>" >> ~/.bash_profile
echo "export FORTA_OWNER_ADDRESS=<YOUR_FORTA_OWNER_ADDRESS>" >> ~/.bash_profile
echo "export FORTA_RPC_URL=<YOUR_FORTA_RPC_URL>" >> ~/.bash_profile
echo "export FORTA_PROXY_RPC_URL=<YOUR_FORTA_PROXY_RPC_URL>" >> ~/.bash_profile
echo "export FORTA_DIR=~/.forta" >> ~/.bash_profile
source ~/.bash_profile
```

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
### 3.1 Download and install docker
```
sudo apt-get install ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```

### 3.2 Configure docker address pools
```
tee /etc/docker/daemon.json > /dev/null <<EOF
{
   "default-address-pools": [
        {
            "base":"172.17.0.0/12",
            "size":16
        },
        {
            "base":"192.168.0.0/16",
            "size":20
        },
        {
            "base":"10.99.0.0/16",
            "size":24
        }
    ]
}
EOF
systemctl restart docker
```

## 4. Install forta
### 4.1 Download and install forta binaries
```
sudo curl https://dist.forta.network/pgp.public -o /usr/share/keyrings/forta-keyring.asc -s
echo 'deb [signed-by=/usr/share/keyrings/forta-keyring.asc] https://dist.forta.network/repositories/apt stable main' | sudo tee -a /etc/apt/sources.list.d/forta.list
sudo apt-get update
sudo apt-get install forta
```

## 4.2 Configure systemd service
```
sudo mkdir /lib/systemd/system/forta.service.d
tee /lib/systemd/system/forta.service.d/env.conf > /dev/null <<EOF
[Service]
Environment='FORTA_DIR=$FORTA_DIR'
Environment='FORTA_PASSPHRASE=$FORTA_PASSPHRASE'
EOF
```

## 5. Initial forta scan node setup
### 5.1 Initialize Forta using the forta init command
```
forta init
```
> This is the value that will be registered in the scan node registry smart contract. If you need to find out your address later again, you can run `forta account address`

### 5.2 Send 0.1 Matic in Polygon network to your scan node address

### 5.3 Update configuration file with rpc enpoints
```
yq e -i '.scan.jsonRpc.url="'$FORTA_RPC_URL'"' ~/.forta/config.yml
yq e -i '.trace.jsonRpc.url="'$FORTA_RPC_URL'"' ~/.forta/config.yml
yq e -i '.jsonRpcProxy.jsonRpc.url="'$FORTA_PROXY_RPC_URL'"' ~/.forta/config.yml
```

### 5.4 Register forta
```
forta register --owner-address $FORTA_OWNER_ADDRESS
```

### 5.5 Start service
```
sudo systemctl enable forta
sudo systemctl start forta
```

### 5.6 Check status. Status should be updated 5-10 minutes after starting node
```
forta status
```

## Usefull commands
Get forta scan node address
```
forta account address
```

Check scan node status
```
forta status
```

Check asociated bots
```
docker ps | grep docker-entrypoint | wc -l
```

Check scan node logs
```
journalctl -u forta -f -o cat
```

stop forta
```
systemctl stop forta
```

start forta
```
systemctl start forta
```

# Testnet rewards
Check your SLA
```
curl https://api.forta.network/stats/sla/scanner/<FORTA_SCANNER_ADDRESS>?startTime=2022-04-24T00:00:00Z | jq .statistics.avg
```

SLA Score will determine if and how much of the reward each scan node gets.
During 75% or more node's running time each week:
- 100% reward: SLA ≥ 0.9
- 80% reward: SLA ≥ 0.75
- No reward: SLA < 0.75

