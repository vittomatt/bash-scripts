#!/bin/bash

for i in $(seq 1 254); do
	timeout 1 bash -c "ping -c 1 192.168.0.$i" &>/dev/null && echo "Host: 192.168.0.$i (UP)" &
done

wait