<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/EY35ZzXY" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/165930080-4f541b46-1ae3-461c-acc9-de72d7ab93b7.png">
</p>

# Aptos validator node setup for AIT2 (Updated 30.06.2022)
Official documents:
> [Run a Validator Node](https://aptos.dev/tutorials/validator-node/intro)\
> [Node Tester by Andrew | zValid](https://node.aptos.zvalid.com/)

## Hardware requirements:
#### For running an aptos node on incentivized testnet we recommend the following:
- CPU: 4 cores (Intel Xeon Skylake or newer)
- Memory: 8GiB RAM
- Storage: 300GB (You have the option to start with a smaller size and adjust based upon demands)

## Set up your aptos validator
### Option 1 (automatic)
Use script below for a quick installation
```
wget -qO aptos_validator.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/aptos_validator.sh && chmod +x aptos_validator.sh && ./aptos_validator.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/aptos/testnet/validator_manual_install.md) if you better prefer setting up node manually

## Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

## Check your node health
1. Navigate to https://node.aptos.zvalid.com/
2. Enter your node public IP address adn change API port to `80`
3. You should see data like in example below:

![image](https://user-images.githubusercontent.com/50621007/176846383-7ebe2df6-17ec-41c6-bd34-d7c796761a36.png)

## Register your node for Aptos Incentivized Testnet
1. Head to [community.aptoslabs.com](https://community.aptoslabs.com) and *Sign Up* using one of provided methods
2. Approve your email
3. Fill up node verification form with your keys
```
cat ~/$WORKSPACE/$NODENAME.yaml
```

You can find example below:

![image](https://user-images.githubusercontent.com/50621007/176886734-46e938fc-9b44-498b-92ec-d99c605f365d.png)

4. Complete KYC process

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
cd ~/$WORKSPACE && docker compose down; cd
rm ~/$WORKSPACE -rf
docker volume rm aptos-validator
unset NODENAME
```

## (OPTIONAL) You can install fullnode on a seperate machine but its optional
Guide can be found [here](https://github.com/kj89/testnet_manuals/blob/main/aptos/testnet/fullnode_manual_install.md)

# Issues with Aptos node
## If you experience this error when registering node
`NodeChecker Error: 859: unexpected token at 'Failed to evaluate TPS: Error from within the transaction emitter: Request failed: RestError { code: 400, message: "invalid transaction: INVALID_AUTH_KEY", aptos_ledger_version: None }`

![image](https://user-images.githubusercontent.com/50621007/176991421-71492723-d13f-4e13-b931-8fc93a8d4cc2.png)

Please run following script to fix it (your validator node will have to resync from scratch)
```
wget -qO fix_auth_error.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/fix_auth_error.sh && chmod +x fix_auth_error.sh && ./fix_auth_error.sh
```
>PS: if you run a full node, don't forget to update the waypoint.txt and genesis.blob files there too.

## To change default API port from 80 to 8080
```
cd ~/$WORKSPACE
wget -qO docker-compose.yaml https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/docker-compose.yaml
docker compose down
docker compose up -d
```
