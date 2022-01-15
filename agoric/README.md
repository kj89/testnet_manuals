### Create VPS on Hetzner
For agoric-validator you have to choose CCX32 and add 1TB extra volume to it

LOGIN as root

### Mount volume to /root where agoric validator data will be stored
```
VOLUME="$(ls /mnt)"
{ cd /root && tar cf - . ; } | { cd /mnt/$VOLUME/ && tar xvf -  ; echo EXIT=$? ; }
sed -i "s|/mnt/$VOLUME|/root|g" /etc/fstab
mv /root /root-
mkdir /root 
mount /root
```

### Move old lib folder and mount new lib to volume disk
```
mv /root /root-
mkdir /root 
mount /root
```

### Run script bellow to prepare your server
```
wget -O agoric_mainnet.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/agoric/agoric_mainnet.sh && chmod +x agoric_mainnet.sh && ./agoric_mainnet.sh
```
