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
  <img height="100" height="auto" src="8ff8a186fe9cbc70d0f34891fa051f87e561a48b@158.160.0.93:26656,8f9e7cf4cc2809933e714b2c2e757a4da99fd7b4@35.189.115.248:26656,7fe3007cba4de49584cbdad9489ffecfc9651c57@65.108.79.246:26673,b02f304fa0f10090491f62bf12ed32bf73138d5c@148.72.153.85:11656,18b711011fe7c0fa4a1555c89808dffecf9a3ba3@65.21.142.30:26656,433f85361545a434ad6b4202e2f373e4894ecf39@142.132.151.99:15619,1c1ca90d704c22844570d57039ccf2e8f58e475d@80.64.208.123:26656,8a334ed2e728ca1164f8ef6ae58dd5fda31da5be@66.94.104.239:26641">
</p>

# Chain upgrade to commit 4ec1b0ca818561cef04f8e6df84069b14399590e
## (OPTION 1) Manual upgrade
Once the chain reaches the upgrade height, you will encounter the following panic error message:\
`ERR UPGRADE "xxx" NEEDED at height: 155420`
```
sudo systemctl stop noisd
cd $HOME && rm -rf nois
git clone https://github.com/Stride-Labs/nois.git && cd nois
git checkout 4ec1b0ca818561cef04f8e6df84069b14399590e
make build
sudo mv build/noisd $(which noisd)
sudo systemctl restart noisd && journalctl -fu noisd -o cat
```

!!! DO NOT UPGRADE BEFORE CHAIN RECHES THE BLOCK `155420`!!!

### (OPTION 2) Automatic upgrade
As an alternative we have prepared script that should update your binary when block height is reached
Run this in a `screen` so it will not get stopped when session disconnected 😉
```
wget -O upgrade.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/nois/upgrade/155420/upgrade.sh && chmod +x upgrade.sh && ./upgrade.sh
```
