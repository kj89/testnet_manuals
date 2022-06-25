echo -e "\e[1m\e[32mUpdating Sui fullnode... \e[0m" && sleep 1
sudo systemctl stop suid
sudo rm -rf /var/sui/db/* /var/sui/genesis.blob
source $HOME/.cargo/env
cd $HOME/sui
git fetch upstream
git checkout -B devnet --track upstream/devnet
cargo build --release -p sui-node
mv ~/sui/target/release/sui-node /usr/local/bin/
wget -O /var/sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
sudo cp crates/sui-config/data/fullnode-template.yaml /var/sui/fullnode.yaml
sudo yq e -i '.db-path="/var/sui/db"' /var/sui/fullnode.yaml \
&& yq e -i '.genesis.genesis-file-location="/var/sui/genesis.blob"' /var/sui/fullnode.yaml \
&& yq e -i '.metrics-address="0.0.0.0:9184"' /var/sui/fullnode.yaml \
&& yq e -i '.json-rpc-address="0.0.0.0:9000"' /var/sui/fullnode.yaml
sudo systemctl start suid
