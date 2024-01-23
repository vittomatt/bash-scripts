#!/bin/bash

for i in $(seq 1 254); do
	for port in 21 22 23 25 54 80 139 443 445 8080; do
		timeout 1 bash -c "echo '' > /dev/tcp/192.168.0.$i/$port" &>/dev/null && echo "Host: 192.168.0.$i (UP) -- Port: $port" &
	done
done

wait