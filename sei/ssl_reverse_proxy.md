# Set up ping pub for your cosmos chains

## Set up vars
```
CHAIN_NAME=sei
API_PORT=12317
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install nginx
```
sudo apt install nginx -y
```

## Set up config
```
sudo tee /etc/nginx/sites-enabled/default > /dev/null <<EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name ${CHAIN_NAME}.api.kjnodes.com;

        location / {

                add_header Access-Control-Allow-Origin *;
                add_header Access-Control-Max-Age 3600;
                add_header Access-Control-Expose-Headers Content-Length;

                proxy_pass http://127.0.0.1:${API_PORT};
        }
}
EOF
```

## Install certbot
```
sudo apt install certbot python3-certbot-nginx -y
```

## Obtain our certificates
```
sudo certbot --nginx -d ${CHAIN_NAME}.api.kjnodes.com --register-unsafely-without-email
```

## Rename default file to match domain
```
mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/${CHAIN_NAME}.api.kjnodes.com.conf
```

## Reload nginx
```
systemctl reload nginx.service
```