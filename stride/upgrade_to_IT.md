<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/177221972-75fcf1b3-6e95-44dd-b43e-e32377685af8.png">
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
PEERS="d6583df382d418872ab5d71d45a1a8c3d28ff269@138.201.139.175:21016,05d7b774620b7afe28bba5fa9e002b436786d4c3@195.201.165.123:20086,d28cfff8b2fe03b597f67c96814fbfd19085b7c3@168.119.124.158:26656,a9687b78c13d39d2f96ec0905c6aa201671f61f0@78.107.234.44:25656,6922feb0ca2eab2be07d60fbfd275319bcd83ec9@77.244.66.222:26656,48b1310bc81deea3eb44173c5c26873c23565d33@34.135.129.186:26656,a3afae256ad780f873f85a0c377da5c8e9c28cb2@54.219.207.30:26656,dd93bd24192d8d3151264424e44b0f213d2334dc@162.55.173.64:26656,d46c3c3de3aacb7c75bbbbf1fe5c168f0c100f26@135.181.131.116:26683,c765007c489ddbcb80249579534e63d7a00407d0@65.108.225.158:22656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stride/config/config.toml
```

## Update stride config
```
sed -i '/STRIDE_CHAIN_ID/d' ~/.bash_profile
echo "export STRIDE_CHAIN_ID=STRIDE-TESTNET-2" >> $HOME/.bash_profile
source $HOME/.bash_profile
strided config chain-id $STRIDE_CHAIN_ID
```

## Reset chain data
```
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
