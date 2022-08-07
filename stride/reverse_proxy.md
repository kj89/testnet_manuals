<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discord.gg/fRVzvPBh" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
<a href="https://m.do.co/c/17b61545ca3a" target="_blank">Deploy your VPS using our referral link to get 100$ free bonus for 60 days <img src="https://user-images.githubusercontent.com/50621007/183284313-adf81164-6db4-4284-9ea0-bcb841936350.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/183283696-d1c4192b-f594-45bb-b589-15a5e57a795c.png">
</p>


# Set up ping pub for your cosmos chains

## Set up vars
```
CHAIN_NAME=stride-testnet
API_PORT=16317
RPC_PORT=16657
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install nginx and certbot
```
sudo apt install nginx certbot python3-certbot-nginx -y
```

## Cleanup default settings
```
sudo rm -f /etc/nginx/sites-{available,enabled}/default
```

## Set up config
```
sudo tee /etc/nginx/sites-available/${CHAIN_NAME}.api.kjnodes.com.conf > /dev/null <<EOF
server {
        listen 80;
        listen [::]:80;

        server_name ${CHAIN_NAME}.api.kjnodes.com;

        location / {

                add_header Access-Control-Allow-Origin *;
                add_header Access-Control-Max-Age 3600;
                add_header Access-Control-Expose-Headers Content-Length;

                proxy_pass http://127.0.0.1:${API_PORT};
        }
}
EOF
sudo ln -s /etc/nginx/sites-available/${CHAIN_NAME}.api.kjnodes.com.conf /etc/nginx/sites-enabled/${CHAIN_NAME}.api.kjnodes.com.conf
```

## Set up config
```
sudo tee /etc/nginx/sites-available/${CHAIN_NAME}.rpc.kjnodes.com.conf > /dev/null <<EOF
server {
        listen 80;
        listen [::]:80;

        server_name ${CHAIN_NAME}.rpc.kjnodes.com;

        location / {

                add_header Access-Control-Allow-Origin *;
                add_header Access-Control-Max-Age 3600;
                add_header Access-Control-Expose-Headers Content-Length;

                proxy_pass http://127.0.0.1:${RPC_PORT};
        }
}
EOF
sudo ln -s /etc/nginx/sites-available/${CHAIN_NAME}.rpc.kjnodes.com.conf /etc/nginx/sites-enabled/${CHAIN_NAME}.rpc.kjnodes.com.conf
```

## Reload nginx
```
sudo systemctl reload nginx.service
```

## Obtain our certificates
```
sudo certbot --nginx --register-unsafely-without-email
```
