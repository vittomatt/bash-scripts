```bash
#!/bin/bash

function scan_port() {
	# Open file descriptor
	(exec 3<> /dev/tcp/$1/$2) 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "IP: $1, Port: $2 (OPEN)"
	fi
	
	# Close file descriptors
	exec 3>&-; exec 3<&-;
}

# -a -> Array
declare -a ports=($(seq 1 65535))
ip=$1

# Check at least 1 arg is passed
if [ $1 ]; then
	for port in "${ports[@]}"; do
		scan_port $ip $port &
	done
else
	echo "Usage: $0 <domain>"
fi

# wait for & proccess
wait