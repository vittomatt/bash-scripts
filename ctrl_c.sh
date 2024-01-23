#!/bin/bash

function ctrl_c() {
	echo "Bye!"
	tput cnorm
	exit 1
}

tput civis

trap ctrl_c SIGINT

# Code

tput cnorm