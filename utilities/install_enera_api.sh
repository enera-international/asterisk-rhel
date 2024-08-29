#!/bin/bash

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
