echo -e "\e[1m\e[32mUpdating Sui fullnode... \e[0m" && sleep 1
cd $HOME && rm -rf sui
mkdir sui && cd sui
wget -qO docker-compose.yaml https://raw.githubusercontent.com/MystenLabs/sui/main/docker/fullnode/docker-compose.yaml
wget -qO fullnode-template.yaml https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml
wget -qO genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
sed -i 's/127.0.0.1/0.0.0.0/' fullnode-template.yaml
docker-compose down --volumes
docker-compose pull
docker-compose up -d
