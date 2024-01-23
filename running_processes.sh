#!/bin/bash

# The name of the file is procmon.sh
# This filtered below

old_process=$(ps -eo user,command)

while true; do
	new_process=$(ps -eo user,command)
	# grep "[\>\<]" will filter the lines with differences. [] is an OR
	# grep -v deletes the lines with the expresion
	# -E allow multiple expression separated by comma
	diff <(echo "$old_process") <(echo "$new_process") | grep "[\>\<]" | grep -vE "command,kworker,procmon"
	old_process=$new_process
done