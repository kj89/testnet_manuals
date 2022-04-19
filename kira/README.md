### Create VPS on Hetzner
For kira you have to choose CX41 and add extra 500GB volume to it
![image](https://user-images.githubusercontent.com/50621007/148678170-a3c36e8d-d5d2-4f1f-8284-07249e64f514.png)

LOGIN as root

### First of all you have to initialize new 500GB volume and make it primary data container for kira node
```
VOLUME="$(ls /mnt)"
{ cd /var/lib && tar cf - . ; } | { cd /mnt/$VOLUME/ && tar xvf -  ; echo EXIT=$? ; }
sed -i "s|/mnt/$VOLUME|/var/lib|g" /etc/fstab
```

### Move old lib folder and mount new lib to 500GB volume disk
```
mv /var/lib /var/lib-
mkdir /var/lib 
mount /var/lib
```

### Create kira user and setup password
```
sudo useradd kira -m -s /bin/bash
sudo passwd kira
```

### Give permissions to  kira user
```
sudo usermod -aG sudo kira
```

### Login as kira user
```
sudo su - kira
sudo -s
```

### Create mnemonic file and paste your mnemonic content there
```
cd /home/kira && mkdir ./.secrets && nano ./.secrets/mnemonics.env
```
After that press CTRL+O and ENTER to overwrite file contents

Then press CTRL+x to close the file

### Install dependencies
```
sudo apt update && sudo apt -y upgrade
sudo apt-get install -y network-manager
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
```

### Run command

```
cd /tmp && read -p "Input branch name: " BRANCH && \
 wget https://raw.githubusercontent.com/KiraCore/kira/$BRANCH/workstation/init.sh -O ./i.sh && \
 chmod 555 -v ./i.sh && H=$(sha256sum ./i.sh | awk '{ print $1 }') && read -p "Is '$H' a [V]alid SHA256 ?: "$'\n' -n 1 V && \
 [ "${V,,}" != "v" ] && echo "INFO: Setup was cancelled by the user." || ./i.sh "$BRANCH"
```
### Press ENTER

### Type

`
testnet-9
`

![image](https://user-images.githubusercontent.com/70693118/148641294-24dd5d89-a547-45bc-bc89-16bfe3dfcf48.png)

### Press V

![image](https://user-images.githubusercontent.com/70693118/148641341-d67f7305-e7b2-413e-8727-5f7a4ad36498.png)

### Press any key

![image](https://user-images.githubusercontent.com/70693118/148641513-c64d89b0-2026-4e13-b961-3bd1e1fe6471.png)


### Press 1

![image](https://user-images.githubusercontent.com/70693118/148641540-94aaf951-8b95-4d4c-a5ec-15a7596ca12c.png)

### Press J

![image](https://user-images.githubusercontent.com/70693118/148641630-1cdc4823-21c0-4d66-bb40-ce9b6e70e7f0.png)

### Press S

![image](https://user-images.githubusercontent.com/70693118/148615964-317bc6c4-2f05-4538-9f6d-6819a3084fc3.png)

### Enter one of the following IPs:
`


18.135.115.225
3.11.224.235 
52.56.117.134

https://testnet-rpc.kira.network/download/peers.txt

https://testnet-rpc.kira.network/api/pub_p2p_list?ip_only=true&connected=true


`
![image](https://user-images.githubusercontent.com/70693118/148616510-7ec6e012-0a9b-4263-9619-1bc40756e2c3.png)

### Press C

![image](https://user-images.githubusercontent.com/70693118/148616566-21b4d3cf-c62c-4aee-9a5a-975b547cd03c.png)

### Press C

![image](https://user-images.githubusercontent.com/70693118/148616592-96a9b8df-d45f-4257-b293-36644592b049.png)

### Enter the link below and press ENTER
`
https://raw.githubusercontent.com/KiraCore/testnet/main/testnet-9/genesis.json
`
![image](https://user-images.githubusercontent.com/70693118/148616708-f31fa279-cb4b-40a2-ba8e-a1cc9c3c2f19.png)

### Press ENTER

![image](https://user-images.githubusercontent.com/70693118/148616754-c9ec39af-6a2d-4bdc-90fb-e7f4952cc5cc.png)

### Press A

![image](https://user-images.githubusercontent.com/70693118/148616843-567c8383-b227-4ea8-a84c-5e56f535a909.png)

### Press A

![image](https://user-images.githubusercontent.com/70693118/148616932-9bcd9704-f747-4378-ad2d-2f2588d0bdca.png)

### Press M

![image](https://user-images.githubusercontent.com/70693118/148617020-d98f0b77-d05c-4f96-8468-03b79396725b.png)

### Press P

![image](https://user-images.githubusercontent.com/70693118/148617081-30ad3734-6f2f-41bf-b7d2-11401aadc960.png)

### Press A

![image](https://user-images.githubusercontent.com/70693118/148617112-a28d632f-d6e1-4301-b7aa-9160dc29ab30.png)

### Enter ips from the list above or from RPC link and press NETER

![image](https://user-images.githubusercontent.com/70693118/148617253-2a47f5d8-7d2a-43c3-b975-b45ec85b232e.png)

### Press Y

![image](https://user-images.githubusercontent.com/70693118/148617306-64c15a15-67c8-41d5-aec5-1715839962af.png)

### Press Y

![image](https://user-images.githubusercontent.com/70693118/148617333-445a4695-7441-4901-a3c6-c5146d47d9a9.png)

### Repeat

### Press S

![image](https://user-images.githubusercontent.com/70693118/148617385-dadf8b80-5e86-47bb-b1ea-a9e372abb469.png)

### Press E

![image](https://user-images.githubusercontent.com/70693118/148617437-79fa86da-ca04-42b3-afe0-63187c4e2f9a.png)

### Press E

![image](https://user-images.githubusercontent.com/70693118/148617487-4a3de3fa-0966-4f0b-b36a-e1fcfb09fddb.png)

### Server will be rebooted
### Log in back.
`
sudo kira
`
### Press V

![image](https://user-images.githubusercontent.com/70693118/148617729-d7f69bc8-3351-4bf7-a9ea-831a57f676f0.png)

### Press Ctrl + C

![image](https://user-images.githubusercontent.com/70693118/148619063-25a74317-7dca-4603-bd57-21703c13f0e9.png)

### Type

`
sudo kira
`

![image](https://user-images.githubusercontent.com/70693118/148619160-26605f05-b2f3-4ab4-b277-20e751314fc5.png)



### STATE SYNC
STATE SYNC как и обещал. Нода будет весить пару гигов, и подключится к сети за 10 минут +-
Делаем на свой страх и риск)
Заходим под kira

1. curl -s http://194.163.141.23:26657/status — проверяем доступна ли моя нода ( Почему-то с подсети контабо с ip рядом не пингуется. Позже перенесу на хецнер если нужно бдует. Чуть что пингуем в чате)
2. docker ps. Видим Container id, записываем его (у меня будет fb0bac5166bd)
3. docker exec -it fb0bac5166bd /bin/bash
4. nano $HOME/.sekaid/config/config.toml и в persistent_peers вписываем tcp://c77daa77a6ad825326a9676610347c0aa8cc63ca@194.163.141.23:26656 (sed почему то не работает)
5. nano /self/home/container/validator/start.sh . В самом конце, перед echoInfo "INFO: Starting validator..." делаем как на скрине. Вставляем настройки прунинга и стейт синха
echoInfo "INFO: State SYNC"

pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="1000"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sekaid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sekaid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sekaid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sekaid/config/app.toml

SNAP_RPC1="http://194.163.141.23:26657" \
&& SNAP_RPC2="http://194.163.141.23:26657"
LATEST_HEIGHT=$(curl -s $SNAP_RPC2/block | jq -r .result.block.header.height) \
&& BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)) \
&& TRUST_HASH=$(curl -s "$SNAP_RPC2/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC1,$SNAP_RPC2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.sekaid/config/config.toml

sekaid unsafe-reset-all
6. Выходим с докера exit. Делаем рестарт контейнера валика с КМ. Валидатор может в джейл, лучше maintenance mode использовать
7. Смотрим свои логи синхронзации docker logs fb0bac5166bd --tail 100
