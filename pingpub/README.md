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
  <img height="100" height="auto" src="https://ping.pub/logo.svg">
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
wget -qO $HOME/explorer/src/chains/mainnet/dws.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/testnet_chains/dws.json
wget -qO $HOME/explorer/src/chains/mainnet/sei.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/testnet_chains/sei.json
wget -qO $HOME/explorer/src/chains/mainnet/uptick.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/testnet_chains/uptick.json
wget -qO $HOME/explorer/src/chains/mainnet/cardchain.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/testnet_chains/cardchain.json
wget -qO $HOME/explorer/src/chains/mainnet/teritori.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/testnet_chains/teritori.json
wget -qO $HOME/explorer/src/chains/mainnet/paloma.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/testnet_chains/paloma.json
wget -qO $HOME/explorer/src/chains/mainnet/aura.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/testnet_chains/aura.json
wget -qO $HOME/explorer/src/chains/mainnet/rebus.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/testnet_chains/rebus.json
```

## 6. Build ping.pub
```
yarn && yarn build
cp -r $HOME/explorer/dist/* /var/www/html
sudo systemctl restart nginx
```
