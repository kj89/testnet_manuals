## Set up SSV operator node

LOGIN as root

### Run script bellow to prepare your server
```
wget -O install.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/ssv/install.sh && chmod +x install.sh && ./install.sh
```

## Set up SSV operator

### Create user and give persmissions to docker group
```
adduser <USERNAME>
usermod -aG sudo <USERNAME>
sudo usermod -aG docker <USERNAME>
newgrp docker
```

### Clone eth-docker repository to ssv folder and run config
```
cd ~ && git clone https://github.com/eth-educators/eth-docker.git ssv && cd ssv
./ethd config
```

### Choose execution and consensus clients and endpoints from grafana
I prefer geth + lighthouse setup. Also you have to choose infura fallback endpoints

### Generate operator keys
```
docker-compose run --rm ssv-generate-keys
```

### Add operator private key to config file
```
cp blox-ssv-config-sample.yaml blox-ssv-config.yaml
vim blox-ssv-config.yaml
```

### Run full SSV stack
```
./ethd up
```

## Set up SSV validator

### Generate validator keys
Run as Administrator this command in Powershell
```
$path = "$home\Desktop\ssv-validators"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

cd $path

# Download deposit app
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://github.com/ethereum/eth2.0-deposit-cli/releases/download/v1.2.0/eth2deposit-cli-256ea21-windows-amd64.zip" -OutFile "./temp.zip"

# Load ZIP methods
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Open ZIP archive for reading
$zip = [System.IO.Compression.ZipFile]::OpenRead("$pwd/temp.zip")

$zip.Entries | ForEach-Object { 
    $FileName = $_.Name
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$pwd\$FileName", $true)
    }

# Close ZIP file
$zip.Dispose()

Start-Sleep -Seconds 5

Start-Process -Wait -FilePath "$pwd\deposit.exe" -ArgumentList 'new-mnemonic --num_validators 1 --chain prater' -PassThru

```

## Usefull commands
list of containers
```
docker ps
```

list of images
```
docker images
```

delete stoped containers
```
docker container prune -f
```

Show container logs
```
docker logs -f ssv-execution-1
```

Open geth console
```
docker exec -it ssv-execution-1 geth attach http://127.0.0.1:8545
```

### Commands inside geth
Show sync status and current completion percent
```
eth.syncing
eth.syncing.currentBlock * 100 / eth.syncing.highestBlock

```

Peer count
```
net.peerCount
```

### Create ubuntu container for testing
```
docker pull ubuntu:latest
docker run -it --rm --network eth-net ubuntu:latest /bin/bash 
```

## Install Monitoring on ssv operator
Run script below to create prometheus and grafana containers
```
mkdir prometheus && wget -O ./prometheus/prometheus.yaml https://raw.githubusercontent.com/bloxapp/ssv/stage/monitoring/prometheus/prometheus.yaml
docker run --user root -p 9390:9090 -dit --name=prometheus -v $(pwd)/prometheus/:/data/prometheus -v $(pwd)/prometheus/prometheus.yaml:/etc/prometheus/prometheus.yml 'prom/prometheus:v2.24.0' --config.file="/etc/prometheus/prometheus.yml" --storage.tsdb.path="/data/prometheus"
mkdir grafana
sudo chown -R 472:472 grafana
docker run -p 3000:3000 -dti -v $(pwd)/grafana/:/var/lib/grafana --name=grafana 'grafana/grafana:8.0.0'
docker network create --driver bridge ssv-net
docker network connect --alias ssv-node-1 ssv-net ssv_node
docker network connect --alias prometheus ssv-net prometheus
docker network connect --alias grafana ssv-net grafana
```

Go to grafana web http://<SSV_OPERATOR_PUBLIC_IP>:3000
username: amdin
password: admin

### Grafana setup

In order to setup a grafana dashboard do the following:
1. Add http://prometheus:9090 as data source
    * Job name assumed to be '`ssv`'
2. Import dashboards to Grafana:
   * [SSV Operator Node dashboard](./grafana/dashboard_ssv_operator.json) 
   * [SSV Validator dashboard](./grafana/dashboard_ssv_validator.json)
3. Align dashboard variables:
    * `instance` - container name, used in 'instance' field for metrics coming from prometheus. \
      In the given dashboard, instances names are: `ssv-node-v2-<i>`, make sure to change according to your setup
    * `validator_dashboard_id` - exist only in operator dashboard, points to validator dashboard

**Note:** In order to show `Process Health` panels, the following K8S metrics should be exposed:
* `kubelet_volume_stats_used_bytes`
* `container_cpu_usage_seconds_total`
* `container_memory_working_set_bytes`


### Health Check

Health check route is available on `GET /health`. \
In case the node is healthy it returns an HTTP Code `200` with empty response:
```shell
$ curl http://localhost:15000/health
```

If the node is not healthy, the corresponding errors will be returned with HTTP Code `500`:
```shell
$ curl http://localhost:15000/health
{"errors": ["could not sync eth1 events"]}
```
