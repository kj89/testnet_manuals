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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/177323789-e6be59ae-0dfa-4e86-b3a8-028a4f0c465c.png">
</p>

# SubQuery node setup for Frontier Testnet

Official documentation:
- frontier dashboard: https://frontier.subquery.network
- Github: https://github.com/subquery/subql
- Discord: https://discord.gg/KefTcqQq
- Frontier Testnet Mission list: https://frontier.subquery.network/missions/my-missions

Frontier tasks:
- Instructions for the Frontier Testnet tasks can be found [here](https://github.com/kj89/testnet_manuals/blob/main/subquery/tasks/README.md)

## Project information

### Description
The SubQuery project is a complete API for organizing and querying data from layer 1. Currently serving the Polkadot, Substrate, Avalanche, Terra, and Cosmos projects (starting with Juno), this data as a service allows developers to focus on their core use case and external interface, without wasting time creating your own data processing backend.

### Phases
At this stage, everyone can participate in testnet. You will need to complete the tasks for which you will get points. All the tasks and scores can be found in the [Dashboard](https://frontier.subquery.network/missions/my-missions)

### Rewards
According to the information provided by the team, rewards will be given to the participants with the most points::
- Guaranteed allocation in the sale
- Chance to get into genesis indexers (validators)


## Hardware requirements
- CPU: 4 CPU
- Memory: 8 GB RAM
- Disk: 160 GB SSD Storage (to start)

## Node setup
### Option 1 (automatic)
You can setup your subquery node in few minutes by using automated script below
```
wget -O subquery.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/subquery/subquery.sh && chmod +x subquery.sh && ./subquery.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/subquery/manual_install.md) if you better prefer setting up node manually

## Set up your Metamask
1. Add Acala network
Metamask -> Settings -> Networks -> Add Network
- Network Name: `Acala`
- New RPC URL: `https://tc7-eth.aca-dev.network`
- Chain ID: `595`
- Currency Symbol: `ACA`
- Block Explorer URL: `https://blockscout.mandala.acala.network/`

![2022-07-05_15h54_27](https://user-images.githubusercontent.com/50621007/177332482-58a48785-1b13-430e-bdcc-d4b22eea52af.png)

2. Add new Metamask account for `SubQuery Indexer`

![image](https://user-images.githubusercontent.com/50621007/177339027-28d93457-6c82-4ca6-8ccd-f4cc4ad3eae8.png)

3. Top up your wallet
- Go to [SubQuery Discord](https://discord.gg/KefTcqQq)
- Navigate to `#faucet` channel
- Request tokens by using command:
```
!drip <your_wallet_address>
```

![image](https://user-images.githubusercontent.com/50621007/177337543-09c8f7fe-5aa9-49ab-9315-5bfa77b287b1.png)

>We strongly suggest you not to milk the faucet! Your points in the leaderboard will not increase based on the number of tokens. You will need a faucet 2-3 times for the entire testnet.

4. Import $SQT token to your Metamask Assets:
- Token contract: `0x6B3953381f777Fa7136f1EA263e37174440090D1`

![image](https://user-images.githubusercontent.com/50621007/177336255-5cac2bc5-7e49-4d83-a603-c9493b5dde6e.png)
![image](https://user-images.githubusercontent.com/50621007/177339126-830946db-f738-4ee5-bdc3-ddd4c14b8163.png)

## Set up SubQuery Indexer
1. To register Indexer you have to open SubQuery Dashboard. You can find a link using command:
```
echo "http://$(wget -qO- eth0.me):8000"
```

2. Connect your Metamask to your DashBoard
Connect with Metamask -> Get started -> Approve -> Register Indexer -> Sync
- Indexer Name: Nickname of your Indexer that will be visible in a Dashboard
- Proxy Endpoint: Should be `http://<your_node_ip>`
- Stkaing: `1000` (its minimum stake to register Indexator)
- Commission rate (%): `10`

![image](https://user-images.githubusercontent.com/50621007/177342405-06b4d3f7-8bb2-4520-997f-7dd8b3ef7a64.png)

3. Register Controller
- Press `Manage Controllers` button
- Create an Account
- Top up your controller wallet using `#faucet` channel in [SubQuery Discord](https://discord.gg/KefTcqQq)
- Press Active button
Result should look like this:

![image](https://user-images.githubusercontent.com/50621007/177345252-cff347d6-0bfb-4545-b24d-fb044971ab2a.png)

## Congratz! You have all set and ready to start doing SubQuery tasks.
BTW you already have finished two taks by completing steps above!

![image](https://user-images.githubusercontent.com/50621007/177345931-cdac21ec-c707-474c-a951-3d44c8db4bbd.png)

All tasks with points can be found [here](https://frontier.subquery.network/missions/my-missions)
