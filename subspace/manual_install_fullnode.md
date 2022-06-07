<p style="font-size:14px" align="right">
Join our telegram <a href="https://t.me/kjnotes" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
Visit our website <a href="https://kjnodes.com/" target="_blank"><img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/171398816-7e0432f4-4d39-42ad-a72e-cd8dd008028f.png">
</p>

# Install Subspace node
To setup Subspace node follow the steps below

## Setting up vars
>Replace `YOUR_NODENAME` below with the name of your node\
>Replace `YOUR_WALLET_ADDRESS` below with your account address from Polkadot.js wallet\
>Replace `YOUR_PLOT_SIZE` with plot size in gigabytes or terabytes, for instance 100G or 2T (but leave at least 10G of disk space for node)
```
NODENAME=<YOUR_NODENAME>
WALLET_ADDRESS=<YOUR_WALLET_ADDRESS>
PLOT_SIZE=<YOUR_PLOT_SIZE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET_ADDRESS=$WALLET_ADDRESS" >> $HOME/.bash_profile
echo "export PLOT_SIZE=$PLOT_SIZE" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl jq -y
```

## Update executables
```
cd $HOME
rm -rf subspace-*
APP_VERSION=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name")
wget -O subspace-node https://github.com/subspace/subspace/releases/download/${APP_VERSION}/subspace-node-ubuntu-x86_64-${APP_VERSION}
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/${APP_VERSION}/subspace-farmer-ubuntu-x86_64-${APP_VERSION}
chmod +x subspace-*
mv subspace-* /usr/local/bin/
```

## Create subspace-node service
```
sudo tee <<EOF >/dev/null /etc/systemd/system/subspaced.service
[Unit]
Description=Subspace Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which subspace-node) \\
--chain="gemini-1" \\
--execution="wasm" \\
--pruning=1024 \\
--keep-blocks=1024 \\
--validator \\
--reserved-nodes="/dns/bootstrap-0.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWF9CgB8bDvWCvzPPZrWG3awjhS7gPFu7MzNPkF9F9xWwc" \\
--reserved-nodes="/dns/bootstrap-1.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWLrpSArNaZ3Hvs4mABwYGDY1Rf2bqiNTqUzLm7koxedQQ" \\
--reserved-nodes="/dns/bootstrap-10.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWNGf1qr5411JwPHgwqftjEL6RgFRUEFnsJpTMx6zKEdWn" \\
--reserved-nodes="/dns/bootstrap-11.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWM7Qe4rVfzUAMucb5GTs3m4ts5ZrFg83LZnLhRCjmYEJK" \\
--reserved-nodes="/dns/bootstrap-2.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWNN5uuzPtDNtWoLU28ZDCQP7HTdRjyWbNYo5EA6fZDAMD" \\
--reserved-nodes="/dns/bootstrap-3.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWM47uyGtvbUFt5tmWdFezNQjwbYZmWE19RpWhXgRzuEqh" \\
--reserved-nodes="/dns/bootstrap-4.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWNMEKxFZm9mbwPXfQ3LQaUgin9JckCq7TJdLS2UnH6E7z" \\
--reserved-nodes="/dns/bootstrap-5.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWFfEtDmpb8BWKXoEAgxkKAMfxU2yGDq8nK87MqnHvXsok" \\
--reserved-nodes="/dns/bootstrap-6.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWHSeob6t43ukWAGnkTcQEoRaFSUWphGDCKF1uefG2UGDh" \\
--reserved-nodes="/dns/bootstrap-7.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWKwrGSmaGJBD29agJGC3MWiA7NZt34Vd98f6VYgRbV8hH" \\
--reserved-nodes="/dns/bootstrap-8.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWCXFrzVGtAzrTUc4y7jyyvhCcNTAcm18Zj7UN46whZ5Bm" \\
--reserved-nodes="/dns/bootstrap-9.gemini-1b.subspace.network/tcp/30333/p2p/12D3KooWNGxWQ4sajzW1akPRZxjYM5TszRtsCnEiLhpsGrsHrFC6" \\
--reserved-nodes="/ip4/135.181.110.33/tcp/30333/p2p/12D3KooWBpnzaT6dNEYPK2E24oy3smGkCjbqAMrXzLi1RtZN5H11" \\
--reserved-nodes="/ip4/138.201.127.254/tcp/30333/p2p/12D3KooWCt5RDU7KVEGcyBTPdku6ReyBwgzT74JiELrM5Pn8iFzq" \\
--reserved-nodes="/ip4/139.59.64.225/tcp/30333/p2p/12D3KooWNMEKxFZm9mbwPXfQ3LQaUgin9JckCq7TJdLS2UnH6E7z" \\
--reserved-nodes="/ip4/139.59.70.211/tcp/30333/p2p/12D3KooWNGf1qr5411JwPHgwqftjEL6RgFRUEFnsJpTMx6zKEdWn" \\
--reserved-nodes="/ip4/143.198.232.248/tcp/30333/p2p/12D3KooWLrpSArNaZ3Hvs4mABwYGDY1Rf2bqiNTqUzLm7koxedQQ" \\
--reserved-nodes="/ip4/144.126.132.228/tcp/30333/p2p/12D3KooWJzsBEqbnJtFS27B6iPGZmAqjAmjyQmQh2AnfjJqCHJ1z" \\
--reserved-nodes="/ip4/146.0.40.38/tcp/30333/p2p/12D3KooWLZFw5FJ2SDETdd7u2AjQDUjpXx4KqTw5GmpEqnLKoj82" \\
--reserved-nodes="/ip4/159.223.51.101/tcp/30333/p2p/12D3KooWM7Qe4rVfzUAMucb5GTs3m4ts5ZrFg83LZnLhRCjmYEJK" \\
--reserved-nodes="/ip4/167.86.121.150/tcp/30333/p2p/12D3KooWSBvBzm4wGZoSC8HDSh3ybxAtJbCiZWFVDMtJoYqpp4pe" \\
--reserved-nodes="/ip4/167.86.82.227/tcp/30333/p2p/12D3KooWCdYiSzRjqYFtfnmnUB9SH8qjgUV8GjcgGmhS7TsPgTJT" \\
--reserved-nodes="/ip4/167.86.82.238/tcp/30333/p2p/12D3KooWC7GySYsuXkbXVc9LyjQ83bTmovdurbtbEGd31hDTtfFA" \\
--reserved-nodes="/ip4/173.249.14.30/tcp/30333/p2p/12D3KooWNnL7hcf5WHxTRC528nQoS9oeMMaNcVroQ2XnHCieScMJ" \\
--reserved-nodes="/ip4/178.18.247.142/tcp/30333/p2p/12D3KooWEFGfH7rqhr488qmVMuRqbHD18af8NtuaEpVG46G8jBGW" \\
--reserved-nodes="/ip4/185.185.80.43/tcp/30333/p2p/12D3KooWFp9CFe2jkPjz2UVGPEbQ9Kw5N3xRKUWAWdxYfNYLaC19" \\
--reserved-nodes="/ip4/194.163.170.195/tcp/30333/p2p/12D3KooWPRVsJVmcUrjxhx8PBVsdFATaeCLnagGgenW7mmgA7Dna" \\
--reserved-nodes="/ip4/195.201.220.11/tcp/30333/p2p/12D3KooWA5EdptEpimDhwywRMAot4EtzuyZznqjyPma4HYgAfChM" \\
--reserved-nodes="/ip4/198.211.106.29/tcp/30333/p2p/12D3KooWHSeob6t43ukWAGnkTcQEoRaFSUWphGDCKF1uefG2UGDh" \\
--reserved-nodes="/ip4/23.88.96.88/tcp/30333/p2p/12D3KooWJp4k6xUxtDXVCWksr7q7GAPvQWWUS6kYRkKZhqaTvTFC" \\
--reserved-nodes="/ip4/37.157.254.6/tcp/30333/p2p/12D3KooWKvUKqi2NnJ6ZocRnDRYK7qT4bqcciTc2YA75PEVD39i9" \\
--reserved-nodes="/ip4/38.242.199.248/tcp/30333/p2p/12D3KooWKXGRDiJLRgmimk9BQGDq6j4xPx3ojV1Z6PPtyhqa4Etj" \\
--reserved-nodes="/ip4/49.12.190.178/tcp/30333/p2p/12D3KooWS3G5YBmwLuicRqz6aZzQgsdzJ3VPp9oMbckPfZh4WPPW" \\
--reserved-nodes="/ip4/65.108.77.27/tcp/30333/p2p/12D3KooWNGpP6taJdFZ816j6ALNu7Vptznf7rzfd2LfohLc2thar" \\
--reserved-nodes="/ip4/65.109.9.12/tcp/30333/p2p/12D3KooWQd55cLyNRSXAG2L2u29fvY5hH9vRHdXhgbAPhs5bXxeG" \\
--reserved-nodes="/ip4/65.21.183.180/tcp/30333/p2p/12D3KooWDQrtT2FUYk9wQmXwFuC9iizcLgaZHbCrv3KVHhaBqGeP" \\
--reserved-nodes="/ip4/82.146.34.66/tcp/30333/p2p/12D3KooWPmPQZr8ytMdwaDBWGoiuBf7G5gJpEmQ2ZCCdeqsAaNnR" \\
--reserved-nodes="/ip4/94.103.87.148/tcp/30333/p2p/12D3KooWMWJP5A9mHn9FpGjf622WK1hLxmNkhzpHA32Aa6nTkWug" \\
--reserved-nodes="/ip4/95.111.253.211/tcp/30333/p2p/12D3KooWJZPWB64HnAkfnQMQQP5qLf8AxKqDLkEnhmU9tTKrN1r8" \\
--reserved-nodes="/ip4/142.132.131.158/tcp/30333/p2p/12D3KooWEUbb4VxpwHxkRCTB2RG59whnHeYs4631iwefYzQZSA58" \\
--reserved-nodes="/ip4/161.97.86.119/tcp/30333/p2p/12D3KooWKn317boS3z5eKu9tL5koyuBRzTZXU1cvULmAFu8qAJSB" \\
--reserved-nodes="/ip4/164.92.167.41/tcp/30333/p2p/12D3KooWFRWdKxmkGCfLCM29Kwpjws18Wy66piC1Rup4ZfmFrki6" \\
--reserved-nodes="/ip4/173.249.28.128/tcp/30333/p2p/12D3KooWSG7ZKU1prLsR2XYqJetYKMBq132hxEu3PwA3LR9FP3CK" \\
--reserved-nodes="/ip4/176.122.88.128/tcp/30335/p2p/12D3KooWEWmUX8futkbi8YodaRGFuuuxyngmKWDPazVob4JwT1TE" \\
--reserved-nodes="/ip4/185.241.52.110/tcp/30333/p2p/12D3KooWFxZn3t7pPTZzcF6HTPMgbfAwDwG3af64T82rWrgVsMKr" \\
--reserved-nodes="/ip4/185.252.232.79/tcp/30333/p2p/12D3KooWG2qiXqpt9mB6MBYuwxcwU8E9tJugoJ79BU9MeMujTzCo" \\
--reserved-nodes="/ip4/194.146.12.210/tcp/30333/p2p/12D3KooWNY2HDY3VgbFTUtuxtqBLVwfPzQoqMrKETxQsJPxCybwN" \\
--reserved-nodes="/ip4/194.163.172.244/tcp/30333/p2p/12D3KooWEjTgq1QEt2mS9p3ztNxcp2KC3NijCk6B31jS7CdKvDwr" \\
--reserved-nodes="/ip4/195.3.220.211/tcp/30333/p2p/12D3KooWDHWjr3cKhQMAHuZ5twfj6wehdwMrr9WnwifXx7Ay5BeR" \\
--reserved-nodes="/ip4/38.242.202.59/tcp/30333/p2p/12D3KooWC9Ec6xNJ8oNZ87XgKyN9HWq3GUTmA5EKLdJjviAEksom" \\
--reserved-nodes="/ip4/38.242.209.251/tcp/30333/p2p/12D3KooW9x1S2B8w88jn6gAbNt3f4UmXdf59qxT3tGtLN5BKWGNh" \\
--reserved-nodes="/ip4/38.242.224.226/tcp/30333/p2p/12D3KooWMJw8iXs7jFYC3YLTJnwZfVhhy36F6V2889zFDebfKnfR" \\
--reserved-nodes="/ip4/45.144.67.67/tcp/30333/p2p/12D3KooWPQpjxmANthC2xYd4mEAh4evCpMw8dSLBwZEy65pw12jf" \\
--reserved-nodes="/ip4/46.101.140.85/tcp/30333/p2p/12D3KooWNGxWQ4sajzW1akPRZxjYM5TszRtsCnEiLhpsGrsHrFC6" \\
--reserved-nodes="/ip4/5.182.227.103/tcp/30333/p2p/12D3KooWEcMQudRP1U5eCqACqGLeEJmpqfGPau3LY4cRJytBqRLe" \\
--reserved-nodes="/ip4/62.171.134.63/tcp/30333/p2p/12D3KooWPy4Dz9i19Cyrpu9jhtRMEWwtYDi1XFmpXJpN3iqXugKC" \\
--reserved-nodes="/ip4/62.171.138.196/tcp/30333/p2p/12D3KooWHtrAtkEjW6f4vRhyVQbU4dZo5ryfQoiNCf84ZkFYWqXZ" \\
--reserved-nodes="/ip4/65.108.130.178/tcp/30333/p2p/12D3KooWLUH8FqxJti1rFAmrFo9HHZQhhygg8qHx2bSJurk7NhQQ" \\
--reserved-nodes="/ip4/65.108.227.146/tcp/30333/ws/p2p/12D3KooWN5uEJ3awLVKkDdcF6RHvxLXVjYMzdFYDYECpt3aoGq49" \\
--reserved-nodes="/ip4/65.108.246.217/tcp/30333/p2p/12D3KooWMEbLfvRYdJnfVqcpNn5VyEUyQeiG5R6cp8qsvspAtxsP" \\
--reserved-only \\
--name="$NODENAME"
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Create subspaced-farmer service
```
tee $HOME/subspaced-farmer.service > /dev/null <<EOF
[Unit]
Description=Subspaced Farm
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-farmer) farm --reward-address $WALLET_ADDRESS --plot-size $PLOT_SIZE
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
mv $HOME/subspaced-farmer.service /etc/systemd/system/
```

## Run subspace services
```
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 30
sudo systemctl restart subspaced-farmer
```

## Check node status
```
service subspaced status
```

## Check farmer status
```
service subspaced-farmer status
```
