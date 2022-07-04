# Chain upgrade from 1.0.5beta to 1.0.6beta
## (OPTION 1) Manual upgrade
Once the chain reaches the upgrade height, you will encounter the following panic error message:\
`ERR UPGRADE "upgrade-1.0.6beta" NEEDED at height: 1217302`
```
cd $HOME && rm $HOME/sei-chain -rf
git clone https://github.com/sei-protocol/sei-chain.git && cd $HOME/sei-chain
git checkout 1.0.6beta
make install
mv ~/go/bin/seid /usr/local/bin/seid
systemctl restart seid && journalctl -fu seid -o cat
```

!!! DO NOT UPGRADE BEFORE CHAIN RECHES THE BLOCK `1217302`!!!

### (OPTION 2) Automatic upgrade
As an alternative we have prepared script that should update your binary when block height is reached
Run this in a `screen` so it will not get stopped when session disconnected 😉
```
wget -O sei_upgrade_106beta.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/sei/tools/sei_upgrade_106beta.sh && chmod +x sei_upgrade_106beta.sh && ./sei_upgrade_106beta.sh
```
