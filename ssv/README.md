## Set up SSV operator node

LOGIN as root

### Run script bellow to prepare your server
```
wget -O install.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/ssv/install.sh && chmod +x install.sh && ./install.sh
```

### To run Geth goerli node in a Docker container
```
docker run -d --name goerli --network eth-net -p 30303:30303 -p 8545:8545 --restart=always \
-v ~/.ethereum:/root/.ethereum \
ethereum/client-go:stable \
--goerli --syncmode=snap --http --http.addr=0.0.0.0 --ws --ws.addr=0.0.0.0 --http.vhosts=* --cache=8192 --maxpeers=30 --metrics 
```

### To run Lighthouse beacon-chain prater node in a Docker container
```
git clone https://github.com/sigp/lighthouse.git && cd lighthouse
docker build . -t lighthouse:local
docker run -d --name lighthouse --network=eth-net -p 9000:9000 -p 127.0.0.1:5052:5052 --restart=always \
-v ~/.lighthouse:/root/.lighthouse \
lighthouse:local lighthouse \
--network prater beacon --http --http-address 0.0.0.0 --eth1 --eth1-endpoint=http://goerli:8545 --monitoring-endpoint https://beaconcha.in/api/v1/client/metrics?apikey=cjk0NDh5TXZCUThGcUY0RndxaFIu
```

### Generate operator key
```
docker run -d --name=ssv_node_op_key -it 'bloxstaking/ssv-node:latest' \
/go/bin/ssvnode generate-operator-keys && docker logs ssv_node_op_key --follow \
&& docker stop ssv_node_op_key && docker rm ssv_node_op_key
```
Save the public and private keys!

### Create configruation file
Replacing <YOUR_BEACON_ETH2_ENDPOINT>, <YOUR_WSS_GOERLI_ETH_ENDPOINT> and <YOUR_OPERATOR_PRIVATE_KEY> with your values
```
export SSV_DB=$HOME/.ssv
mkdir -p $SSV_DB
yq n db.Path "$SSV_DB" | tee $SSV_DB/config.yaml \
&& yq w -i $SSV_DB/config.yaml eth2.Network "prater" \
&& yq w -i $SSV_DB/config.yaml eth2.BeaconNodeAddr "http://lighthouse:9000" \
&& yq w -i $SSV_DB/config.yaml eth1.ETH1Addr "wss://goerli:8546" \
&& yq w -i $SSV_DB/config.yaml eth1.RegistryContractAddr "0x687fb596F3892904F879118e2113e1EEe8746C2E" \
&& yq w -i $SSV_DB/config.yaml MetricsAPIPort "15000" \
&& yq w -i $SSV_DB/config.yaml OperatorPrivateKey "<YOUR_OPERATOR_PRIVATE_KEY>"
```

### To run SSV operator in a Docker container
```
docker run -d --name ssv_operator --network eth-net --restart=always \
-v $SSV_DB/config.yaml:/config.yaml -v $SSV_DB:/data \
bloxstaking/ssv-node:latest \
make BUILD_PATH=/go/bin/ssvnode start-node
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
