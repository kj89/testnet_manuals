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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/192942503-d3df529e-1ca8-465e-a110-5d4a0c4f438e.png">
</p>

# Chain upgrade to v0.2.0
> **Note** **Block Countdown can be found [here](https://explorer.kjnodes.com/terp-test/gov/2)**

## (OPTION 1) Manual upgrade
Once the chain reaches the upgrade height, you will encounter the following panic error message:\
`ERR UPGRADE "xxx" NEEDED at height: 1497396`
```
sudo systemctl stop terpd
cd $HOME && rm -rf terp-core
git clone https://github.com/terpnetwork/terp-core.git
cd terp-core
git checkout v0.2.0
make install
```

Check version, should return 0.2.0
```
terpd version
```

Wait for new genesis file with updated structure beeing deployed by the Terp team
```
curl -s  https://raw.githubusercontent.com/terpnetwork/test-net/master/athena-2/0.2.0/genesis.json > ~/.terp/config/genesis.json
```

Start the service
```
sudo systemctl start terpd && journalctl -fu terpd -o cat
```

> **Warning**
> !!! DO NOT UPGRADE BEFORE CHAIN RECHES THE BLOCK `1497396`!!!
