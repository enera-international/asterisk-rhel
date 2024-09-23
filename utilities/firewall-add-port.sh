#!/bin/bash

# Usage: firewall-add-port <zone> <port> <protocol>
# Example: firewall-add-port public 5060 tcp

if [ $# -ne 3 ]; then
  echo "Usage: $0 <zone> <port> <protocol>"
  exit 1
fi

ZONE=$1
PORT=$2
PROTOCOL=$3

# Check if the port is already added to the zone
sudo firewall-cmd --zone="$ZONE" --query-port="$PORT/$PROTOCOL" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Port $PORT/$PROTOCOL is already open in zone $ZONE."
else
  echo "Adding port $PORT/$PROTOCOL to zone $ZONE..."
  sudo firewall-cmd --zone="$ZONE" --add-port="$PORT/$PROTOCOL" --permanent

  if [ $? -eq 0 ]; then
    echo "Port $PORT/$PROTOCOL added successfully."
  else
    echo "Failed to add port $PORT/$PROTOCOL."
    exit 1
  fi

  # Reload firewall to apply changes
  sudo firewall-cmd --reload
  echo "Firewall reloaded."
fi
