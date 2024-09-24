#!/bin/bash

sudo dnf install httpd-tools -y
sudo htpasswd -cb /etc/nginx/.htpasswd linehandler Qfpy65OWa6cRBxoctkqEtr2SKl1gNuQLOP42u8j25Gi5NykPkUm7KHsABjLGyvel
sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
sudo cp -f utilities/nginx.conf /etc/nginx/sites-available/enera
sudo rm -f /etc/nginx/sites-enabled/default

# Define the nginx.conf file path
NGINX_CONF="/etc/nginx/nginx.conf"

# Define the include line to be added
INCLUDE_LINE="    include /etc/nginx/sites-enabled/*;"

# Check if the include line is already present
if grep -Fxq "$INCLUDE_LINE" "$NGINX_CONF"; then
    echo "Include line is already present in $NGINX_CONF."
else
    # Backup the current nginx.conf file
    sudo cp "$NGINX_CONF" "$NGINX_CONF.bak"

    # Add the include line inside the http block
    sudo sed -i "/http {/a\\$INCLUDE_LINE" "$NGINX_CONF"

    echo "Include line added to $NGINX_CONF."
fi

sudo ln -sf /etc/nginx/sites-available/enera /etc/nginx/sites-enabled/
if ! [ -d "/etc/nginx/ssl" ]; then
    sudo mkdir /etc/nginx/ssl
fi
sudo openssl req  -x509 -nodes -days 365 -new \
 -subj "/C=SE/ST=Enera/L=Gothenburg/O=Dis/CN=www.enera.se" \
 -keyout /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt

sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx
# SELinux allow network access
sudo setsebool -P httpd_can_network_connect 1

username=$(whoami)
if [ -f "enera-api.service" ]; then
    rm enera-api.service
fi
cat <<EOF > "enera-api.service"
[Unit]
Description=Enera API server
After=network.target

[Service]
ExecStart=/usr/bin/node /home/$username/enera-asterisk-api-server/package/dist/index.js
Restart=always
User=$username
Group=$username
Environment=NODE_ENV=production
WorkingDirectory=/home/$username/enera-asterisk-api-server/package
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=enera-asterisk-api-server

[Install]
WantedBy=multi-user.target
EOF
sudo cp -f enera-api.service /etc/systemd/system/enera-api.service

sudo systemctl daemon-reload
sudo systemctl enable enera-api
sudo systemctl start enera-api

./utilities/firewall-add-port.sh public 80 tcp
./utilities/firewall-add-port.sh public 443 tcp

echo "Installation completed."
