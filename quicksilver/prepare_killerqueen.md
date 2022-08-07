<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/fRVzvPBh" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>
<p style="font-size:14px" align="right">
<a href="https://m.do.co/c/17b61545ca3a" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus for 60 days <img src="https://user-images.githubusercontent.com/50621007/183284313-adf81164-6db4-4284-9ea0-bcb841936350.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/166148846-93575afe-e3ce-4ca5-a3f7-a21e8a8609cb.png">
</p>

# Quicksilver node setup for Testnet — killerqueen-1

#### Quicksilver `killerqueen-1` network will start @ 09:00 UTC on Thursday 23rd June.

First of all please lookup for your submitted gentx data in [genesis file](https://raw.githubusercontent.com/ingenuity-build/testnets/main/killerqueen/genesis.json)
![image](https://user-images.githubusercontent.com/50621007/175129276-9705a6fc-c6ec-4c1e-8944-d1fd0b84732d.png)

If you have found your validator address in genesis, congratulations, you have been selected as genesis validator for `killerqueen-1` testnet and you will receive `100 QCK` tokens at the chain start.

Folks who did not submit a gentx, will be able to call the faucet once. This will give them a decent amount of tokens and will be able to get in the set easily if any genesis validators fail to start.

The first task will involved being up immediately after genesis. Every block missed in the first 100 blocks will reduce the points you can earn for this task so make sure your nodes are set up and ready to rock

## What should I do next?

Please follow the instructions to prepare your validator before 09:00 UTC on Thursday 23rd June
1) Install fresh Ubuntu 20.04 server
2) Use our [guide](https://github.com/kj89/testnet_manuals/tree/main/quicksilver) to setup your quicksilver fullnode 
3) Recover your wallet (24-word mnemonic phrase) that we used to create `gentx`
```
quicksilverd keys add $WALLET --recover
```
4) Copy your `priv_validator_key.json` that we used to create `gentx` into `.quicksilverd/config/` directory
5) Restart quicksilver service
```
sudo systemctl restart quicksilverd
```
6) Check service logs
```
journalctl -u quicksilverd -o cat
```
7) You should see output `This node is a validator addr=XXXXXXXXX module=consensus pubKey=XXXXXXXXX`
8) Also output should show that node is waiting for genesis time `Genesis time is in the future. Sleeping until then... genTime=2022-06-23T09:00:00Z`

![image](https://user-images.githubusercontent.com/50621007/175128488-f7981ef5-98fb-4b0d-bfc0-8135a05a847b.png)

If you see this output your node is ready and should start signing blocks when genesis time will ocure.