# Manual node  setup
If you want to setup fullnode manually follow the steps below

## 0. Set environment variables
```
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
```
sudo curl https://dist.forta.network/pgp.public -o /usr/share/keyrings/forta-keyring.asc -s
echo 'deb [signed-by=/usr/share/keyrings/forta-keyring.asc] https://dist.forta.network/repositories/apt stable main' | sudo tee -a /etc/apt/sources.list.d/forta.list
sudo apt-get update
sudo apt-get install forta
```

## 5. Configure systemd
```
sudo mkdir /lib/systemd/system/forta.service.d
tee /lib/systemd/system/forta.service.d/env.conf > /dev/null <<EOF
[Service]
Environment='FORTA_DIR=$FORTA_DIR'
Environment='FORTA_PASSPHRASE=$FORTA_PASSPHRASE'
EOF
```

## 6. Initial Setup
Initialize Forta using the forta init command
```
forta init
```
> This is the value that will be registered in the scan node registry smart contract. If you need to find out your address later again, you can run `forta account address`

Update configuration file with rpc enpoints
```
yq e -i '.scan.jsonRpc.url="'$FORTA_RPC_URL'"' ~/.forta/config.yml
yq e -i '.trace.jsonRpc.url="'$FORTA_RPC_URL'"' ~/.forta/config.yml
yq e -i '.jsonRpcProxy.jsonRpc.url="'$FORTA_PROXY_RPC_URL'"' ~/.forta/config.yml
```

Register forta
```
forta register --owner-address $OWNER_ADDRESS
```

Start service
```
sudo systemctl enable forta
sudo systemctl start forta
```

Check status. Status should be updated 5-10 minutes after starting node
```
forta status
```
