<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/162544751-fb3e2adb-d203-4866-99cf-13f06d562d05.png">
</p>

# NYM MIXNODE SETUP GUIDE (v1.0.1 - MAINNET)

> *To check health of your mixnode you can use:*
> - [Nodes.Guru Nym Checker](https://nodes.guru/nym/mixnodecheck)
> - [Mainet Mixnode Explorer](https://mixnet.explorers.guru/mixnodes)
> - [Mainnet validators](https://nym.explorers.guru/validators)

## MIXNODE SYSTEM REQUIREMENTS
For the moment mixnode does not require beastly server with multiple cores. Current system requirements are:
 
- 2 vCPU
- 1 GB RAM
- Support of IPv4 and IPv6

## BEFORE YOU BEGIN
To start with Nym mixnode installation please create your Nym wallet first. If you have already generated your wallet you can skip next step and go straight to [INSTALATION](https://github.com/kj89/testnet_manuals/tree/main/nym#installation)

### Generate nym wallet
1. Go to [https://nymtech.net](https://nymtech.net/download/) and download the latest available version of Nym Wallet
2. Install wallet application on your computer. Allow Smartscreen to install application from unknown publisher
3. Open aplication and create new account

<p align="center">
  <img width="500" height="auto" src="https://user-images.githubusercontent.com/50621007/162536087-f8eb9217-b668-491f-b1f6-853eb1e2312f.png">
</p>

> *Please make sure you have saved your `24 word mnemonic`, make sure to store it in a safe place for accessing your wallet in the future!*

4. After you have entered the wallet application, make sure you have selected correct network from dropdown at the top of the screen. Choose `Nym Mainnet` for mainnet

<p align="center">
  <img width="800" height="auto" src="https://user-images.githubusercontent.com/50621007/162532456-48f2f9c5-7150-4bf4-88e8-4813009bbc5e.png">
</p>

5. You can find your Nym wallet address in balance field. It should begins with `n1...`

## INSTALLATION
1. Run one-liner below to install your nym mixnode and follow the on-screen instructions
```
wget -O nym.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/nym/nym.sh && chmod +x nym.sh && ./nym.sh
```

<p align="center">
  <img width="800" height="auto" src="https://user-images.githubusercontent.com/50621007/162527668-5112e417-a60b-4080-8128-bf3b7a53c986.png">
</p>

2. When installation is finished, run command below to load variables into system
```
source $HOME/.bash_profile
```

3. Afterwards you can check your node details by running command
```
nym-mixnode node-details --id $NODENAME
```

<p align="center">
  <img width="800" height="auto" src="https://user-images.githubusercontent.com/50621007/162536842-008f5530-a6e0-4d1c-9fb2-aaa5af96291c.png">
</p>

## BOND YOUR MIXNODE
> *Your node will start mixing packets only when bonded*
1. First of all you will have to top up your wallet with nym tokens.

2. Navigate to Nym wallet and go to `Bond` section

<p align="center">
  <img width="700" height="auto" src="https://user-images.githubusercontent.com/50621007/162537550-9738ac56-d322-4667-8654-d165052d1b5c.png">
</p>

3. Fill out all fields with your mixnode details

> *make sure to leave some amount of coins for commission*

4. Set up your `Amount of pledge` (minimum 100 NYM tokens) and reasonable `Profit percentage` and click `Bond`

<p align="center">
  <img width="600" height="auto" src="https://user-images.githubusercontent.com/50621007/162538013-09d33f38-d966-4356-add2-34afee1a1b04.png">
</p>

5. Thats it, now your mixnode is bonded!

## CHECK YOUR MIXNODE STATUS
After bonding mixnode, it should start mixing packets

### To check mixed packets
```
journalctl -u nym-mixnode -o cat | grep "Since startup mixed" | tail -1
```
> *If you dont see any new packets mixed, just give it some **5-10** minutes and check again!*

## UPDATE YOUR MIXNODE
```
wget -O update.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/nym/update.sh && chmod +x update.sh && ./update.sh
```

## OTHER USEFUL COMMANDS
See your mixnode logs (CTRL+C to exit)
```
journalctl -u nym-mixnode -f -o cat
```

Add description
```
nym-mixnode describe --id $NODENAME
```

Restart your node
```
systemctl restart nym-mixnode
```

Decypher your Public Identity and Sphinx keys
```
ls -1 $HOME/.nym/mixnodes/*/data/public_identity.pem | while read F; do echo === $F ===; grep -v ^- $F | openssl base64 -A -d | base58; echo; done
ls -1 $HOME/.nym/mixnodes/*/data/public_sphinx.pem | while read F; do echo === $F ===; grep -v ^- $F | openssl base64 -A -d | base58; echo; done
```
