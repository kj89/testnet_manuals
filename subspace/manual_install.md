<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/171398816-7e0432f4-4d39-42ad-a72e-cd8dd008028f.png">
</p>

# Install Subspace node
To setup Subspace node follow the steps below

## Setting up vars
>Replace `YOUR_NODENAME` below with the name of your node\
>Replace `YOUR_WALLET_ADDRESS` below with your account address from Polkadot.js wallet\
>Replace `YOUR_PLOT_SIZE` with plot size in gigabytes or terabytes, for instance 100G or 2T (but leave at least 10G of disk space for node)
```
NODENAME=<YOUR_NODENAME>
WALLET_ADDRESS=<YOUR_WALLET_ADDRESS>
PLOT_SIZE=<YOUR_PLOT_SIZE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET_ADDRESS=$WALLET_ADDRESS" >> $HOME/.bash_profile
echo "export PLOT_SIZE=$PLOT_SIZE" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl jq -y
```

## Update executables
```
cd $HOME
rm -rf subspace-*
APP_VERSION=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name")
wget -O subspace-node https://github.com/subspace/subspace/releases/download/${APP_VERSION}/subspace-node-ubuntu-x86_64-${APP_VERSION}
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/${APP_VERSION}/subspace-farmer-ubuntu-x86_64-${APP_VERSION}
chmod +x subspace-*
mv subspace-* /usr/local/bin/
```

## Create subspace-node service
```
tee $HOME/subspaced.service > /dev/null <<EOF
[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-node) --chain gemini-1 --execution wasm --pruning 1024 --keep-blocks 1024 --validator --name $NODENAME
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
mv $HOME/subspaced.service /etc/systemd/system/
```

## Create subspaced-farmer service
```
tee $HOME/subspaced-farmer.service > /dev/null <<EOF
[Unit]
Description=Subspaced Farm
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-farmer) farm --reward-address $WALLET_ADDRESS --plot-size $PLOT_SIZE
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
mv $HOME/subspaced-farmer.service /etc/systemd/system/
```

## Run subspace services
```
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 10
sudo systemctl restart subspaced-farmer
```

## Check node status
```
service subspaced status
```

## Check farmer status
```
service subspaced-farmer status
```
