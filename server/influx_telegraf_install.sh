#!/bin/bash

# Import the InfluxData repository key and add it to your system
curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key \
&& echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum -c - && cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list

# Update package lists and install telegraf/influxdb
sudo apt-get update && sudo apt-get install -y telegraf influxdb2

# Enable and start the influxdb service
sudo systemctl enable influxdb 
sudo systemctl restart influxdb 

# influxdb setup, vars at config/telegraf
curl http://localhost:$influx_port/api/v2/setup \
  --data "{
    \"username\": \"$user\",
    \"password\": \"$password\",
    \"token\": \"$influx_token\",
    \"bucket\": \"$influx_bucket\",
    \"org\": \"$influx_org\"
}"

# Copy telegraf configuration files
sudo bash -c "source ./config/variables.sh && export influx_server=localhost && envsubst < ./config/telegraf.conf > /etc/telegraf/telegraf.conf"

# Start and enable telegraf service
sudo systemctl enable telegraf
sudo systemctl restart telegraf
