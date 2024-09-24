#!/bin/bash

username=$(whoami)
NODE_PATH=$(which node)
if [ -f "asterisk-api-server.service" ]; then
    rm asterisk-api-server.service
fi
cat <<EOF > "asterisk-api-server.service"
[Unit]
Description=Enera Asterisk API server
After=network.target

[Service]
ExecStart=$NODE_PATH /srv/asterisk-api-server/dist/index.js
Restart=always
User=$username
Group=$username
Environment=NODE_ENV=production
WorkingDirectory=/srv/asterisk-api-server
StandardOutput=journal
StandardError=journal
SyslogIdentifier=asterisk-api-server

[Install]
WantedBy=multi-user.target
EOF
sudo cp -f asterisk-api-server.service /etc/systemd/system/asterisk-api-server.service

sudo systemctl daemon-reload
sudo systemctl enable asterisk-api-server
sudo systemctl start asterisk-api-server
