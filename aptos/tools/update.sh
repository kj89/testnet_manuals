echo -e "\e[1m\e[32mUpdating Aptos fullnode... \e[0m" && sleep 1
cd $HOME/aptos
docker compose down
docker volume rm aptos_db -f
wget -qO genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -qO waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
docker compose pull
docker compose up -d
