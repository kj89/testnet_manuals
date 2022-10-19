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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/195559096-2a2b9816-31a0-40b2-8882-787e54e5d778.png">
</p>

## Setting up vars
>Replace `YOUR_NODENAME` below with your `CONTROLLER_ADDRESS`
```
NODENAME=<YOUR_NODENAME>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Install bifrost node
To setup bifrost node follow the steps below

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl build-essential git wget npm nodejs jq make gcc tmux -y
```

## Create chain data directory
```
sudo mkdir -p /var/lib/bifrost-data
sudo chmod 0777 /var/lib/bifrost-data
```

## Update executables
```
cd $HOME
wget -qO bifrost-node "https://github.com/bifrost-platform/bifrost-node/releases/download/v1.0.0/bifrost-node"
wget -qO bifrost-testnet.json "https://github.com/bifrost-platform/bifrost-node/releases/download/v1.0.0/bifrost-testnet.json"
sudo chmod +x bifrost-node
sudo mv bifrost-node /usr/local/bin/
sudo mv bifrost-testnet.json /var/lib/bifrost-data
```

## Create bifrost-node service
```
sudo tee <<EOF >/dev/null /etc/systemd/system/bifrostd.service
[Unit]
Description=Bifrost Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which bifrost-node) \\
--base-path /var/lib/bifrost-data \\
--chain /var/lib/bifrost-data/bifrost-testnet.json \\
--port 30333 \\
--validator \\
--state-cache-size 0 \\
--runtime-cache-size 64 \\
--name $NODENAME
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Run bifrost services
```
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable bifrostd
sudo systemctl restart bifrostd
```

## Check node logs
```
journalctl -fu bifrostd -o cat
```


