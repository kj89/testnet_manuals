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
