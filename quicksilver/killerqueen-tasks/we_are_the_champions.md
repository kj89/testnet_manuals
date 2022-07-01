## Sign in the first 100 blocks after the Rhye upgrade
Once the chain reaches the upgrade height, you will encounter the following panic error message:\
`ERR UPGRADE "upgrade-v0.4.1" NEEDED at height: 98000`
```
cd $HOME
rm quicksilver -rf
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.4.1
cd quicksilver
make build
sudo chmod +x ./build/quicksilverd && sudo mv ./build/quicksilverd /usr/local/bin/quicksilverd
sudo systemctl restart quicksilverd
```

!!! DO NOT UPGRADE BEFORE CHAIN RECHES THE BLOCK `98000`!!!

## As an alternative we have prepared script that should update your binary when block height is reached
Run this in a `screen` so it will not get stopped when session disconnected 😉
```
wget -O 0_4_1_upgrade.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/quicksilver/killerqueen-tasks/0_4_1_upgrade.sh && chmod +x 0_4_1_upgrade.sh && ./0_4_1_upgrade.sh
```
