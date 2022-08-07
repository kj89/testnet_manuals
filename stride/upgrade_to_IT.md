<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/fRVzvPBh" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/183283696-d1c4192b-f594-45bb-b589-15a5e57a795c.png">
</p>

# Upgrade to Stride incentivized testnet - STRIDE-TESTNET-2

## Download and build new binaries
```
sudo systemctl stop strided
cd $HOME && rm -rf stride
git clone https://github.com/Stride-Labs/stride.git
cd stride
git checkout 3cb77a79f74e0b797df5611674c3fbd000dfeaa1
make build
sudo cp $HOME/stride/build/strided /usr/local/bin
```

## Update genesis
```
wget -qO $HOME/.stride/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/genesis.json"
```

## Update seed/peers
```
SEEDS="c0b278cbfb15674e1949e7e5ae51627cb2a2d0a9@seedv2.poolparty.stridenet.co:26656"
PEERS="6a9c9871d115c97acc56cb47aa96ccac1728d42d@51.75.135.47:16656,02073421dfeb1fc9426698250db8db68a60b3865@35.184.123.9:26656,efb44e5336800b589053a13f2ee94d3d1cfe19d8@65.108.62.95:12656,11cf69772d08210baa7eff2728efb190cc8103db@46.146.231.96:26656,0c5521e59c227726888504e3f857beb5973d113c@65.108.76.44:11523,e981b87ff961e991f0915301e50f408b33bfdd60@143.198.43.17:16656,c9975b81d7f3afdf5179651c76a013baf70d13ce@62.171.172.182:16656,d7b72c668e32bf1e5efa7d196047188d5a6f1db8@65.108.231.252:46656,73f15ad99a0ac6e60cda2b691bc5b71cd7f221bc@141.95.124.151:20086,f4e9b46abb91c1cf328e28cc195964958ff621b9@65.108.45.200:26959,f6e804d1d509db730de171cf1d0553d701c5140f@142.132.235.215:16656,830a6dcc085dbe37ba0d6c15ac2b10c95d5ba5c3@158.247.231.2:26656,03a532495fc6a2ec20f29318aeb6c9a54286312a@89.163.221.56:26656,ae03ae125b456b4d8df8658917910ec259e14f8b@149.102.131.174:16656,1c06803eb8dda04473f2a5d8419f26126d6d1b09@89.58.45.204:26656,be60859ea3cc6e4d37d50c81c1841355b6885109@86.48.2.79:26656,05313ff7326221035692e5c43198d13ee9079cc7@116.203.47.199:26656,fdcbb0a1d58e4bb934606abaa0e7eb9fc8ef3227@159.223.231.90:16656,c95397b6cc5282a1525bef49bcdd3119847f324e@149.102.139.103:26656,4aed611d0f9758d2362c7d28f067eb6ecd833927@147.182.250.27:16656,dfdc971008bbc3910bcd71855d229e19b8534dbf@159.223.203.149:16656,bb3daec1234c4cbd18b26b13ab9c1db8fbd17f83@38.242.146.249:16656,89fc167903c6f8afd519cbc8cc1542ac6467f911@135.181.133.248:11656,3e17bda1c34f025b8397b5baeaef5000c4c21ddd@213.239.213.179:26656,3e8741d3ae96e08439e7da308ebf1e6651acb02a@167.71.77.205:16656,a3afae256ad780f873f85a0c377da5c8e9c28cb2@54.219.207.30:26656,1aa3c20fd33fd1ece537e695fd67c49efe9e806d@34.125.11.162:26656,4e26c5b8206c116192ceb7f6b5efa176312198ad@185.205.244.117:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stride/config/config.toml
```

## Update stride config
```
sed -i '/STRIDE_CHAIN_ID/d' ~/.bash_profile
echo "export STRIDE_CHAIN_ID=STRIDE-TESTNET-2" >> $HOME/.bash_profile
source $HOME/.bash_profile
strided config chain-id $STRIDE_CHAIN_ID
```

## Reset chain data and disable state sync
```
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1false|" $HOME/.stride/config/config.toml
strided tendermint unsafe-reset-all --home $HOME/.stride
```

## Start service
```
sudo systemctl start strided && journalctl -fu strided -o cat
```

## Check your wallet balance
```
strided query bank balances $STRIDE_WALLET_ADDRESS
```

## Create your validator
```
strided tx staking create-validator \
  --amount 10000000ustrd \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(strided tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $STRIDE_CHAIN_ID
```

## Delegate to your validator
```
strided tx staking delegate $STRIDE_VALOPER_ADDRESS <AMOUNT>ustrd --from=$WALLET --chain-id=$STRIDE_CHAIN_ID --gas=auto
```

## Check active validator list
```
strided q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```
