<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/174556037-0ab70712-94a0-4033-b885-38425158774e.png">
</p>

## Run SSV

login as root

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

### Login as user created above
```
sudo su - <USERNAME>
```

### Clone eth-docker repository to ssv folder and run config
```
cd ~ && git clone https://github.com/eth-educators/eth-docker.git ssv && cd ssv
./ethd config
```

### SSV stack configuration
*Select eth clients you prefer to use*
* Network: `Prater Testnet`
* Deployment type: `Blox SSV node`
* Consensus client: `Lighthouse (Rust)`
* Execution client: `Geth (Go)`
* Go to infura and create new ETH2 project. In project settings you will find endpoints for Prater(eth2)
* Lighthouse rapid sync: `yes --> <infura_eth2_prater_https_endpoint>`
* Grafana: `yes`

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

## SSV stack monitoring
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

## Set up SSV validator
### Generate validator keys
Run as Administrator this command in Powershell
```
$path = "$home\Desktop\ssv-validators"
If(!(test-path $path))
{
	# Create directory
	New-Item -ItemType Directory -Force -Path $path
	# Use TLS1.2 as security protocol as older powershell use tls 1.0 by default
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	# Download deposit app
	Invoke-WebRequest -Uri "https://github.com/ethereum/eth2.0-deposit-cli/releases/download/v1.2.0/eth2deposit-cli-256ea21-windows-amd64.zip" -OutFile "$path/temp.zip"
	# Load ZIP methods
	Add-Type -AssemblyName System.IO.Compression.FileSystem
	# Open ZIP archive for reading
	$zip = [System.IO.Compression.ZipFile]::OpenRead("$path/temp.zip")
	# Extract file into current directory
	$zip.Entries | ForEach-Object { 
		$FileName = $_.Name
		[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$path\$FileName", $true)
		}
	# Close ZIP file
	$zip.Dispose()
}
cd $path
# Run deposit.exe
Start-Process -Wait -FilePath "deposit.exe" -ArgumentList 'new-mnemonic --num_validators 1 --chain prater' -PassThru

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
