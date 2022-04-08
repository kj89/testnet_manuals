# nym mixnode node setup guide (v0.12.1 - Testnet Sanbox)

## before you begin
To start with Nym mixnode installation please create your Nym wallet first. If you have already generated your wallet you can skip next step

### create nym wallet
1. Go to https://nymtech.net/ and download the latest version of Nym Wallet
2. Install wallet application on your computer
3. Create new account
> Please make sure you have saved your 24 word mnemonic, make sure to store it in a safe place for accessing your wallet in the future!
4. After you have entered the wallet application, make sure you have selected correct network. Choose `Testnet Sanbox` for current testnet
5. Now you can find your Nym wallet address in balance field. It should begins with `nymt1...`
6. Go to faucet page https://faucet.nymtech.net/ and input your Nym wallet address to get testnet tokens
7. After that tokens should apear in your wallet
> If you dont see tokens in your wallet just refresh it by navigating to another tab and back

## installation
### please run script below to install your nym mixnode
```
wget -O nym_testnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/nym/nym_testnet.sh && chmod +x nym_testnet.sh && ./nym_testnet.sh
```

### when installation is finished run comand below to load variables into system
```
source $HOME/.bash_profile
```

## configuration
In next steps you have to bond your mixnode to start mixing packets
1. Navigate to Nym wallet and go to `Bond` section
2. Fill out all fields with values you got from running command
```
nym-mixnode node-details --id $NODENAME
```
> make sure to leave some amount of coins for commission
3. Set up you `profit percentage` and click `Bond`
4. Thats it. Your Nym mixnode is now bonded!

## check your mixnode status
After all configuration is done, your mixnode should start mixing packets

### To check mixed packets
```
journalctl -u nym-mixnode -o cat | grep "Since startup mixed" 
```
> If you dont see any new packets mixed, just give it some 5-10 minutes and check again!


## usefull commands
See your mixnode logs (CTRL+C to exit)
```
journalctl -u nym-mixnode -f -o cat
```

Check how many packets your node mixed
```
journalctl -u nym-mixnode -o cat | grep "Since startup mixed" | tail -1
```

Restart your node
```
systemctl restart nym-mixnode
```

Decypher your public Identity and Sphinx keys:
```
ls -1 $HOME/.nym/mixnodes/*/data/public_identity.pem | while read F; do echo === $F ===; grep -v ^- $F | openssl base64 -A -d | base58; echo; done
ls -1 $HOME/.nym/mixnodes/*/data/public_sphinx.pem | while read F; do echo === $F ===; grep -v ^- $F | openssl base64 -A -d | base58; echo; done
```

To check your mixnode health you can use:
- [Nodes.Guru Nym Checker](https://nodes.guru/nym/mixnodecheck)
- [Sandbox Explorer](https://sandbox-explorer.nymtech.net/network-components/mixnodes)
