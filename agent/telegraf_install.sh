#!/bin/bash

if [[ $influx_server == "localhost" ]]; then
    echo "Tha variable 'influx_server' on './config/variables.sh' can't be 'localhost'."
    echo "You must enter the IP or FQDN were your influx server is running."
    exit 1
fi

# Import the InfluxData repository key and add it to your system
curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key \
&& echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum -c - && cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list

# Update package lists and install telegraf
sudo apt-get update && sudo apt-get install -y telegraf

sudo bash -c "source ./config/variables.sh && envsubst < ./config/telegraf.conf > /etc/telegraf/telegraf.conf"

# Start and enable telegraf service
sudo systemctl enable telegraf
sudo systemctl restart telegraf
