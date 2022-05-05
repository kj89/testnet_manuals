node_id=$(systemctl cat nym-mixnode | grep id | awk '{print $4}' | sed 's/.$//' | sed 's/^.//')
version=$(nym-mixnode --version | grep "version" | awk '{print $4}' | sed 's/.$//')
sleep 1
echo "You are running mixnode version" $version "with id" $node_id
sleep 1
echo "Rust installation"
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
echo "Downloading new binaries (v1.0.1)"
cd $HOME
rm -rf nym
git clone https://github.com/nymtech/nym.git
cd nym
git reset --hard
git pull
git checkout tags/v1.0.1
cargo build -p nym-mixnode --release
sudo mv target/release/nym-mixnode /usr/local/bin/
version=$(nym-mixnode --version | grep "version" | awk '{print $4}' | sed 's/.$//')
echo "Current mixnode version:" $version
echo "Initialize your mixmode"
echo "Upgrading your mixnode config"
nym-mixnode upgrade --id $node_id
echo "DefaultLimitNOFILE=65535" >> /etc/systemd/system.conf
sudo systemctl daemon-reload
sudo systemctl enable nym-mixnode
sudo systemctl restart nym-mixnode
echo "Upgrade complete!"
