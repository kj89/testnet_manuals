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
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/165930080-4f541b46-1ae3-461c-acc9-de72d7ab93b7.png">
</p>

![image](https://user-images.githubusercontent.com/50621007/185746675-68afb222-02c7-4759-be04-930116c9745e.png)

# Aptos AIT3 Registration

To participate in the AIT-3 program, follow the below steps. Use these steps as a checklist to keep track of your progress. Click on the links in each step for a detailed documentation.

## Sign-in, connect Wallet and complete survey

![image](https://user-images.githubusercontent.com/50621007/185742643-7821a7b6-75e2-40fb-85a1-410bfea018ad.png)

1. Navigate to the [Aptos Community page](https://aptoslabs.com/community) and follow the steps, starting with registering or signing in to your Discord account.

2. Before you click on Step 2 CONNECT WALLET:
- Delete any previous versions of Aptos Wallet you have installed on Chrome
- Install the Petra (Aptos Wallet) extension using Step 3 instructions, and
- Create the first wallet using Step 4 instructions.

3. Install the Petra (Aptos Wallet) extension on your Chrome browser by following the instructions:
- Download the latest [Petra Wallet release](https://github.com/aptos-labs/aptos-core/releases?q=wallet&expanded=true) and unzip.
- Open a Chrome window and navigate to the Extensions using any of the below methods:
  - At the top right corner of the browser window, click the three vertical dots and then More tools and then Extensions, or
  - On a new tab or a window type chrome://extensions in the URL field and press return.
- Enable Developer mode at the top right of the Extensions page.
- Click on Load unpacked at the top left, and point it to the folder where you just unzipped the downloaded Wallet release.

Now you will see Wallet in your Chrome extensions.

4. Create the first wallet using Petra (Aptos Wallet).
*This first wallet will always be the owner wallet*
- Open the Aptos Wallet extension from the Extensions section of the Chrome browser, or by clicking on the puzzle piece on top right of the browser and selecting Aptos Wallet.
- Click Create a new wallet.
- Make sure to store your seed phrase somewhere safe. This account will be used in the future.

5. Navigate to [AIT3 Registration Page](https://aptoslabs.com/it3) and click on Step 2 `CONNECT WALLET` to register the owner wallet address to your Aptos Community account. The Aptos team will airdrop coins to this owner wallet address.

6. Click on the Step 3 COMPLETE SURVEY to complete the survey.

7. Next, proceed to install and deploy the validator node.

## Deploy the validator node and register the node

![image](https://user-images.githubusercontent.com/50621007/185742656-e4b18499-d968-4ea6-9b72-f8be4754466c.png)

### Hardware requirements:
#### For running an Aptos node on incentivized testnet we recommend the following:
- CPU: 8 cores (Intel Xeon Skylake or newer)
- Memory: 32GB RAM
- Storage: 300GB (You have the option to start with a smaller size and adjust based upon demands)

### Set up your aptos validator
#### Option 1 (automatic)
Use script below for a quick installation
```
wget -qO aptos_validator.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/aptos_validator.sh && chmod +x aptos_validator.sh && ./aptos_validator.sh
```

#### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/aptos/testnet/validator_manual_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

### Check your node health
1. Navigate to https://node.aptos.zvalid.com/
2. Enter your node public IP address
3. You should see data like in example below:

![image](https://user-images.githubusercontent.com/50621007/176846383-7ebe2df6-17ec-41c6-bd34-d7c796761a36.png)

### Register your validator node
1. Come back to the Aptos Community page and register your node by clicking on Step 4: `NODE REGISTRATION` button.

2. Provide the details of your validator node on this node registration screen, all the public key information you need is in the `~/$WORKSPACE/keys/public-keys.yaml` file (please don't enter anything from private keys).
```
cat ~/$WORKSPACE/keys/public-keys.yaml
```

![image](https://user-images.githubusercontent.com/50621007/185745845-7a507495-bc86-4c66-ac49-d8a6273c4fb9.png)

- *OWNER KEY*: the first wallet public key. From `Settings -> Credentials`
- *CONSENSUS KEY*: **consensus_public_key** from `public-keys.yaml`
- *CONSENSUS POP*: **consensus_proof_of_possession** from `public-keys.yaml`
- *ACCOUNT KEY*: **account_public_key** from `public-keys.yaml`
- *VALIDATOR NETWORK KEY*: **validator_network_public_key** from `public-keys.yaml`

![image](https://user-images.githubusercontent.com/50621007/185746074-4bc199a5-19d3-45ad-b506-dfa584b6b294.png)

4. Next, click on VALIDATE NODE. If your node passes healthcheck, you will be prompted to complete the identity verification process.
> The Aptos team will perform a node health check on your validator, using the Node Health Checker. When Aptos confirms that your node is healthy, you will be asked to complete the KYC process.

![image](https://user-images.githubusercontent.com/50621007/185746723-87d7476a-9a01-4cbc-bbec-3922468e59c8.png)

5. Wait for the selection announcement. If you are selected, the Aptos team will airdrop coins into your owner wallet address. If you do not see airdropped coins in your owner wallet, you were not selected.

## Useful commands
### Check validator node logs
```
docker logs -f testnet-validator-1 --tail 50
```

### Check sync status
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
```

### Restart docker container
```
docker restart testnet-validator-1
```

## Clean up preveous installation
(**WARNING!**) Before this step make sure you have backed up your Aptos keys as this step will completely remove your Aptos working directory
```
cd ~/$WORKSPACE && docker-compose down; cd
rm ~/$WORKSPACE -rf
docker volume rm aptos-validator
unset NODENAME
```

## (OPTIONAL) You can install fullnode on a seperate machine but its optional
Guide can be found [here](https://github.com/kj89/testnet_manuals/blob/main/aptos/testnet/fullnode_manual_install.md)
