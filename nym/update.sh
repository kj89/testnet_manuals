node_id=$(systemctl cat nym-mixnode | grep id | awk '{print $4}' | sed 's/.$//' | sed 's/^.//')
version=$(nym-mixnode --version | grep "Build Version" | awk '{print $3}')
wallet=$(nym-mixnode node-details --id $node_id | grep "wallet address:" | awk '{print $7}')
sleep 1
echo "You are running mixnode version" $version "with id" $node_id
sleep 1
sudo systemctl stop nym-mixnode
echo "Downloading new binaries (v1.1.18)"
sudo wget -O $(which nym-mixnode) https://github.com/nymtech/nym/releases/download/nym-binaries-v1.1.18/nym-mixnode
version=$(nym-mixnode --version | grep "Build Version" | awk '{print $3}')
echo "Current mixnode version:" $version
echo "Initialize your mixmode"
nym-mixnode init --id $node_id --host $(curl ifconfig.me) --wallet-address $wallet
echo "Upgrading your mixnode config"
nym-mixnode upgrade --id $node_id
echo "DefaultLimitNOFILE=65535" >> /etc/systemd/system.conf
sed -i "s/validator_api_urls = \[/validator_api_urls = \['https:\/\/validator.nymtech.net\/api',/" $HOME/.nym/mixnodes/$node_id/config/config.toml
sudo systemctl daemon-reload
sudo systemctl enable nym-mixnode
sudo systemctl restart nym-mixnode
echo "Upgrade complete!"
