<p align="center">
  <img width="100" height="auto" src="https://user-images.githubusercontent.com/50621007/165930080-4f541b46-1ae3-461c-acc9-de72d7ab93b7.png">
</p>

# Aptos validator node setup for Incentivized Testnet (Updated 16.05.2022)
Official documents:
> [Run a Validator Node](https://aptos.dev/tutorials/validator-node/intro)

## Hardware requirements:
#### For running an aptos node on incentivized testnet we recommend the following:
- CPU: 4 cores (Intel Xeon Skylake or newer)
- Memory: 8GiB RAM
- Storage: 300GB (You have the option to start with a smaller size and adjust based upon demands)

## Set up your aptos fullnode
### Option 1 (automatic)
Use script below for a quick installation
```
wget -qO aptos.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/aptos/testnet/aptos.sh && chmod +x aptos.sh && ./aptos.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/aptos/testnet/manual_install.md) if you better prefer setting up node manually

## Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

## Check your node health
1. Navigate to https://aptos-node.info/
2. Enter your node public IP address
3. You should see data like in example below:

![image](https://user-images.githubusercontent.com/50621007/168446824-2be781b5-1288-48cb-a9e9-0e2ea922be5c.png)

## Register your node for Aptos Incentivized Testnet
1. Head to [community.aptoslabs.com](https://community.aptoslabs.com) and *Sign Up* using one of provided methods
2. Approve your email
3. Fill up node verification form with your keys
```
cat ~/$WORKSPACE/$NODENAME.yaml
```

You can find example below:

![2022-05-14_02h26_49](https://user-images.githubusercontent.com/50621007/168401158-72557d7e-fb9b-4b49-a44b-a9161c2624e5.png)

4. Complete KYC process

## Useful commands
### Check validator node logs
```
docker logs -f testnet-validator-1 --tail 50
```

### Check fullnode logs
```
docker logs -f testnet-fullnode-1 --tail 50
```

### Check sync status
```
curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type
```

### Restart docker containers
```
docker compose restart
```
