#!/bin/bash

# LOG="/pia-shared/send-port.txt" #change according to your needs

# Append all output to the log file
# exec >> "$LOG" 2>&1

echo -e "\n$(date) Starting a new run of trport.sh"

until pidof transmission-daemon > /dev/null; do
    echo "$(date) Waiting for Transmission process..."
    sleep 5
done
echo "Transmission is running."

until /usr/bin/curl -s http://localhost:9091/transmission/rpc | /bin/grep -q 'session-id'; do
    echo "$(date) Waiting for Transmission RPC..."
    sleep 5
done
echo "Transmission RPC is ready."

# Wait for the forwarded port file to appear
FORWARDED_PORT_FILE="/pia-shared/port.dat" #change according to your needs
while [[ ! -f "$FORWARDED_PORT_FILE" ]]; do
    echo "$(date) Waiting for wireguard to generate the forwarded port..."
    sleep 5
done

port="$( cat /pia-shared/port.dat )"
echo "Forwarded port retrieved: $port"

transmission-remote -p $port

# Log completion and enter big sleep so container doesn't restart me
echo "$(date): trport.sh completed.  Going to sleep indefinitely now."
sleep infinity
