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
docker logs -f goerli
```

Open geth console
```
docker exec -it goerli geth attach http://127.0.0.1:8545
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
