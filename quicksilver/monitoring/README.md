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
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/166148846-93575afe-e3ce-4ca5-a3f7-a21e8a8609cb.png">
</p>

# Set up monitoring and alerting for quicksilver validator

## Prerequisites

### Install exporters on validator node
First of all you will have to install exporters on validator node. For that you can use one-liner below
```
wget -O install_exporters.sh https://raw.githubusercontent.com/kj89/cosmos_node_monitoring/master/install_exporters.sh && chmod +x install_exporters.sh && ./install_exporters.sh
```

| KEY |VALUE |
|---------------|-------------|
| **bond_denom** | Denominated token name, for example, `uqck` for quicksilver testnet. You can find it in genesis file |
| **bench_prefix** | Prefix for chain addresses, for example, `quick` for quicksilver testnet. You can find it in public addresses like this **quick**_valoper1zyyz4m9ytdf60fn9yaafx7uy7h463n7alv2ete_ |
| **rpc_port** | Your validator `rpc` port that is defined in `config.toml` file. Default value for quicksilver is `11657` |
| **grpc_port** | Your validator `grpc` port that is defined in `app.toml` file. Default value for quicksilver is `11090` |

make sure following ports are open:
- `9100` (node-exporter)
- `9300` (cosmos-exporter)

prometheus metrics should be `enabled` and port `11660` should be available on validator instance

To enable prometheus you have to run command below and after that please restart service to apply changes
```
# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.quicksilverd/config/config.toml
```

## Deployment
Monitoring stack needs to be deployed on seperate machine to be able to notify in case if validator goes down! 
To run monitoring stack you dont need beastly server with multiple cores. It will be more than enough to run it on smallest available vps

### System requirements
Ubuntu 20.04 / 1 VCPU / 2 GB RAM / 20 GB SSD

### Install monitoring stack
To install monitirng stack you can use one-liner below
```
wget -O install_monitoring.sh https://raw.githubusercontent.com/kj89/cosmos_node_monitoring/master/install_monitoring.sh && chmod +x install_monitoring.sh && ./install_monitoring.sh
```

### Copy _.env.example_ into _.env_
```
sudo cp $HOME/cosmos_node_monitoring/config/.env.example $HOME/cosmos_node_monitoring/config/.env
```

### Update values in _.env_ file
```
sudo vim $HOME/cosmos_node_monitoring/config/.env
```

| KEY | VALUE |
|---------------|-------------|
| TELEGRAM_ADMIN | Your user id you can get from [@userinfobot](https://t.me/userinfobot). The bot will only reply to messages sent from the user. All other messages are dropped and logged on the bot's console |
| TELEGRAM_TOKEN | Your telegram bot access token you can get from [@botfather](https://telegram.me/botfather). To generate new token just follow a few simple steps described [here](https://core.telegram.org/bots#6-botfather) |

### Export _.env_ file values into _.bash_profile_
```
echo "export $(xargs < $HOME/cosmos_node_monitoring/config/.env)" > $HOME/.bash_profile
source $HOME/.bash_profile
```

### Add validator into _prometheus_ configuration file
To add validator use command with specified `VALIDATOR_IP`, `QUICKSILVER_PROM_PORT`, `QUICKSILVER_VALOPER_ADDRESS`, `QUICKSILVER_WALLET_ADDRESS` and `PROJECT_NAME`
```
$HOME/cosmos_node_monitoring/add_validator.sh VALIDATOR_IP QUICKSILVER_PROM_PORT QUICKSILVER_VALOPER_ADDRESS QUICKSILVER_WALLET_ADDRESS PROJECT_NAME
```

> example: ```$HOME/cosmos_node_monitoring/add_validator.sh 1.2.3.4 11660 quickvaloper1zyyz4m9ytdf60fn9yaafx7uy7h463n7alv2ete quick1zyyz4m9ytdf60fn9yaafx7uy7h463n7a05eshc quicksilver```

To add more validators just run command above with validator values

### Run docker compose
Deploy the monitoring stack
```
cd $HOME/cosmos_node_monitoring
sudo docker compose up -d
```

ports used:
- `8080` (alertmanager-bot)
- `9090` (prometheus)
- `9093` (alertmanager)
- `9999` (grafana)

## Configuration

### Configure Grafana
1. Open Grafana in your web browser. It should be available on port `9999`

![image](https://user-images.githubusercontent.com/50621007/160622455-09af4fbf-2efb-4afb-a8f8-57a2b247f705.png)

2. Login using defaults `admin/admin` and change password

3. Import custom dashboard

3.1. Press "+" icon on the left panel and then choose **"Import"**

![image](https://user-images.githubusercontent.com/50621007/160622732-aa9fe887-823c-4586-9fad-4c2c7fdf5011.png)

3.2. Input grafana.com dashboard id `15991` and press **"Load"**

![image](https://user-images.githubusercontent.com/50621007/160625753-b9f11287-a3ba-4529-96f9-7c9113c6df3a.png)

3.3. Select Prometheus data source and press **"Import"**

![image](https://user-images.githubusercontent.com/50621007/160623287-0340acf8-2d30-47e7-8a3a-56295bea8a15.png)

4. Congratulations you have successfully configured Cosmos Validator Dashboard


### Configrure Telegram alerting
1. Open conversation with your Telegram bot you created with [@botfather](https://telegram.me/botfather) and type `/start` to activate bot

![image](https://user-images.githubusercontent.com/50621007/160623782-e18a42c4-659d-477b-9189-43d9027d518c.png)

2. Now you are all set! If you want see other commands type `/help`

> If you want learn more about `alermanager-bot` please visit [their github repo](https://github.com/metalmatze/alertmanager-bot/)

## Testing

### Test alerts
1. For simple test you can stop `node-exporter` service for 5 minutes. It should trigger alert
```
sudo systemctl stop node_exporter
```
2. You will see message from bot firing

![image](https://user-images.githubusercontent.com/50621007/161050843-889edc5e-4e27-4778-9010-b9e9e861cc74.png)

3. Now you can start `node-exporter` service back
```
sudo systemctl start node_exporter
```
4. You will get confirmation from bot that issue is resolved

![image](https://user-images.githubusercontent.com/50621007/161051501-6e87cbb1-6699-4557-81ed-9564db57a76f.png)

## Dashboard contents
Grafana dashboard is devided into 4 sections:
- **Validator health** - main stats for validator health. connected peers and missed blocks

![image](https://user-images.githubusercontent.com/50621007/160629676-bc3c4f0f-66df-4a5f-9844-dca308072e7a.png)

- **Chain health** - summary of chain health stats and list of top validators missing blocks

![image](https://user-images.githubusercontent.com/50621007/160629937-52253f35-8782-4dd2-80cc-ad31d0231a84.png)

- **Validator stats** - information about validator such as rank, bounded tokens, comission, delegations and rewards

![image](https://user-images.githubusercontent.com/50621007/160630119-0abad099-b138-4f61-9e73-49506c2295ff.png)

- **Hardware health** - system hardware metrics. cpu, ram, network usage

![image](https://user-images.githubusercontent.com/50621007/160630213-5e92b3ce-92c9-4f48-8856-383ca884b621.png)

## Cleanup all container data
```
cd $HOME/cosmos_node_monitoring
sudo docker compose down
sudo docker volume prune -f
```

## Reference list
Resources I used in this project:
- Grafana Validator stats [Cosmos Validator by freak12techno](https://grafana.com/grafana/dashboards/14914)
- Grafana Hardware health [AgoricTools by Chainode](https://github.com/Chainode/AgoricTools)
- Stack of monitoring tools, docker configuration [node_tooling by Xiphiar](https://github.com/Xiphiar/node_tooling/)
- Alertmanager telegram bot [alertmanager-bot by metalmatze](https://github.com/metalmatze/alertmanager-bot)
