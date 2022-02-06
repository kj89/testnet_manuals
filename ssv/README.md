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
Go through configuration process.
Select geth + lighthouse setup. Also you have to add infura fallback endpoints

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

## SSV operator stack commands
### Update ssv stack
```
./ethd update
./ethd restart
```

### Stop ssv stack
```
./ethd stop
```

### Start ssv stack
```
./ethd start
```

### Restart ssv stack
```
./ethd restart
```

### Completely remove all ssv stack (with volumes)
```
./ethd terminate
```

## Usefull commands
show container logs
```
docker logs -f <container_name>
```

list all docker containers
```
docker ps -a
```

list of images
```
docker docker images
```

list of docker volumes
```
docker volume ls
```

remove docker container
```
docker rm -f <container_name>
```

remove docker voliume
```
docker volume rm <volume_name>
```

Open geth console
```
docker exec -it ssv-execution-1 geth attach http://127.0.0.1:8545
```

### Commands inside geth
Show sync status and current completion percent
```
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

## SSV monitoring
SSV stack includes prometheus and grafana as monitoring solution
Go to grafana web http://<SSV_OPERATOR_PUBLIC_IP>:3000
username: admin
password: admin

### Grafana setup
1. Open `SSV Operator node` dashboard and adjust variables:
    * `instance` - ssv-node
	* `explorer` - https://explorer.ssv.network
	* `validator_dashboard_id`- you can find this value in the link of `SSV Validator` dashboard between ...d/ and /ssv-operator-node...
	* Save dashboard with `Save current variable values as dashboard default` checked
2. Open `SSV Validator` dashboard and adjust valriables:
	* `instance` - ssv-node
	* Save dashboard with `Save current variable values as dashboard default` checked
