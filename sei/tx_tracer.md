<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/169664551-39020c2e-fa95-483b-916b-c52ce4cb907c.png">
</p>

# Set up ping pub for your cosmos chains

## 1. Update packages
```
sudo apt update && sudo apt upgrade -y
```

## 2. Install nginx
```
sudo apt install nginx -y
```

## 3. Install nodejs
```
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 4. Install yarn
```
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
```

## 3. Install binaries
```
cd ~
git clone https://github.com/ping-pub/explorer.git
cd explorer
```

## 4. Cleanup predefined chains
```
rm $HOME/explorer/src/chains/mainnet/*
```

## 5. Add testnet chains
```
wget -qO $HOME/explorer/src/chains/mainnet/dws.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/sei/pingpub_chains/dws.json
wget -qO $HOME/explorer/src/chains/mainnet/sei.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/sei/pingpub_chains/sei.json
wget -qO $HOME/explorer/src/chains/mainnet/uptick.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/sei/pingpub_chains/uptick.json
```

## 6. Build ping.pub
```
yarn && yarn build
cp -r $HOME/explorer/dist/* /var/www/html
sudo systemctl restart nginx
```
