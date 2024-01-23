#!/bin/bash

if [ $1 ]; then
	result=$(ping -c 1 $1 | grep ttl | cut -c1-3)

	if [ $result -eq "64" ]; then
		echo "Linux"
	elif [$result -eq "128" ]; then
		echo "Windows"
	else
		echo "Unknown"
	fi
else
	echo "Usage: $0 <domain>"
	exit 1
fi