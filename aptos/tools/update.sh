echo -e "\e[1m\e[32mUpdating Aptos fullnode... \e[0m" && sleep 1
docker stop aptos-fullnode
docker rm aptos-fullnode -f
docker volume rm aptos-fullnode -f
cd $HOME
rm aptos-fullnode -rf
mkdir aptos-fullnode && cd aptos-fullnode
mkdir data && \
curl -qO https://raw.githubusercontent.com/aptos-labs/aptos-core/devnet/config/src/config/test_data/public_full_node.yaml && \
curl -qO https://devnet.aptoslabs.com/waypoint.txt && \
curl -qO https://devnet.aptoslabs.com/genesis.blob
docker run --pull=always -d -p 8080:8080 -p 9101:9101 -v $(pwd):/opt/aptos/etc -v $(pwd)/data:/opt/aptos/data --workdir /opt/aptos/etc --name=aptos-fullnode aptoslabs/validator:devnet aptos-node -f /opt/aptos/etc/public_full_node.yaml
