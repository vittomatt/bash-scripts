#!/bin/bash

first_file_name="<file>"
decompressed_file_name="$(7z l $first_file_name | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"

7z x $first_file_name &>/dev/null

while []; do
	echo -e "\n Unziping: $decompressed_file_name"
	7z x $decompressed_file_name &>/dev/null
	decompressed_file_name="$(7z l $decompressed_file_name 2>/dev/null | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"
done