Upgrade to Stride incentivized testnet - STRIDE-TESTNET-2

# download and build new binaries
```
sudo systemctl stop strided
cd $HOME && rm -rf stride
git clone https://github.com/Stride-Labs/stride.git
cd stride
git checkout 3cb77a79f74e0b797df5611674c3fbd000dfeaa1
make build
sudo cp $HOME/stride/build/strided /usr/local/bin
```

# update genesis
```
wget -qO $HOME/.stride/config/genesis.json "https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/genesis.json"
```

# update seed/peers
```
SEEDS="c0b278cbfb15674e1949e7e5ae51627cb2a2d0a9@seedv2.poolparty.stridenet.co:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stride/config/config.toml
```

# update stride config
```
sed -i '/STRIDE_CHAIN_ID/d' ~/.bash_profile
echo "export STRIDE_CHAIN_ID=STRIDE-TESTNET-2" >> $HOME/.bash_profile
source $HOME/.bash_profile
strided config chain-id $STRIDE_CHAIN_ID
```

# reset chain data
```
strided tendermint unsafe-reset-all --home $HOME/.stride
```

# start service
```
sudo systemctl start strided && journalctl -fu strided -o cat
```
