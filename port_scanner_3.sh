#!/bin/bash

for port in $(seq 1 65535); do
	# If it works it will return 0 -> && will execute the next line
	timeout 1 bash -c "echo '' > /dev/tcp/<ip>/$port" 2>/dev/null && echo "Port: $port -- OPEN" &
done

wait