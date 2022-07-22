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
rm src/chains/mainnet/*
```

## 5. Add testnet chains
```
wget -qO src/chains/mainnet/dws.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/sei/pingpub_chains/dws.json
wget -qO src/chains/mainnet/sei.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/sei/pingpub_chains/sei.json
wget -qO src/chains/mainnet/uptick.json https://raw.githubusercontent.com/kj89/testnet_manuals/main/sei/pingpub_chains/uptick.json
```

## 4. Build ping.pub
```
yarn && yarn build
cp -r ./dist/* /var/www/html
systemctl restart nginx
```

## 
rm src/chains/mainnet/*
nano src/chains/mainnet/sei.json