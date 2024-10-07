#!/bin/bash

sudo dnf install -y nginx httpd-tools
sudo htpasswd -cb /etc/nginx/.htpasswd linehandler Qfpy65OWa6cRBxoctkqEtr2SKl1gNuQLOP42u8j25Gi5NykPkUm7KHsABjLGyvel
if [ ! -d "/etc/nginx/sites-available" ]; then
    sudo mkdir /etc/nginx/sites-available
fi
if [ ! -d "/etc/nginx/sites-enabled" ]; then
    sudo mkdir /etc/nginx/sites-enabled
fi
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

./utilities/firewall-add-port.sh public 80 tcp
./utilities/firewall-add-port.sh public 443 tcp

echo "Installation completed."
