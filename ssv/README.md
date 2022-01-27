### Set up SSV operator node

LOGIN as root

## Run script bellow to prepare your server
```
wget -O install.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/ssv/install.sh && chmod +x install.sh && ./install.sh
```

## To run Geth in a Docker container
```
docker run -d -p 30303:30303 -p 8545:8545 --restart=always \
-v ~/.ethereum:/root/.ethereum \
ethereum/client-go:stable \
--http --http.addr "0.0.0.0" --http.vhosts * --ws --ws.addr "0.0.0.0" --goerli --maxpeers=30 --metrics --graphql --graphql.vhosts *
```

## To run Prysm beacon-chain node in a Docker container
```
docker run -d --restart=always -v ~/.eth2:/data -p 4000:4000 -p 13000:13000 -p 12000:12000/udp \gcr.io/prysmaticlabs/prysm/beacon-chain:stable \
--datadir=/data \
--rpc-host=0.0.0.0 \
--monitoring-host=0.0.0.0 \
--http-web3provider=http://$(hostname -I | awk '{print $1}'):8545 \
--accept-terms-of-use
```
Note: The $(hostname -I | awk '{print $1}') part of the command should return the IP address of the machine. This is needed for this container to talk to the Geth container

## Generate operator key
```
docker run -d --name=ssv_node_op_key -it 'bloxstaking/ssv-node:latest' \
/go/bin/ssvnode generate-operator-keys && docker logs ssv_node_op_key --follow \
&& docker stop ssv_node_op_key && docker rm ssv_node_op_key
```
Save the public and private keys!

## Create configruation file
Replacing <YOUR_BEACON_ETH2_ENDPOINT>, <YOUR_WSS_GOERLI_ETH_ENDPOINT> and <YOUR_OPERATOR_PRIVATE_KEY> with your values
```
export SSV_DB=$HOME/.ssv
mkdir -p $SSV_DB
yq n db.Path "$SSV_DB" | tee $SSV_DB/config.yaml \
&& yq w -i $SSV_DB/config.yaml eth2.Network "prater" \
&& yq w -i $SSV_DB/config.yaml eth2.BeaconNodeAddr "<YOUR_BEACON_ETH2_ENDPOINT>" \
&& yq w -i $SSV_DB/config.yaml eth1.ETH1Addr "<YOUR_WSS_GOERLI_ETH_ENDPOINT>" \
&& yq w -i $SSV_DB/config.yaml eth1.RegistryContractAddr "0x687fb596F3892904F879118e2113e1EEe8746C2E" \
&& yq w -i $SSV_DB/config.yaml MetricsAPIPort "15000" \
&& yq w -i $SSV_DB/config.yaml OperatorPrivateKey "<YOUR_OPERATOR_PRIVATE_KEY>"
```


### Set up SSV validator

## Generate validator keys
Run as Administrator this command in Powershell
```
$path = "$home\Desktop\ssv-validators"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

cd $path

# Download deposit app
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

Start-Process -Wait -FilePath "$pwd\deposit.exe" -ArgumentList 'new-mnemonic --num_validators 1 --chain prater' -PassThru

```

