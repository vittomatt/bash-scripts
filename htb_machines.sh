#!/bin/bash

# Colours
GREEN="\e[0;32m\033[1m"
RED="\e[0;31m\033[1m"
BLUE="\e[0;34m\033[1m"
YELLOW="\e[0;33m\033[1m"
PURPLE="\e[0;35m\033[1m"
TURQUOISE="\e[0;36m\033[1m"
GRAY="\e[0;37m\033[1m"
END="\033[0m\e[0m"

# Ctrl+C
function ctrl_c() {
    echo -e "\n\n${RED}[!] Exiting...${END}\n"
    tput cnorm
    exit 1
}

trap ctrl_c SIGINT

# Global variables
main_url="https://htbmachines.github.io/bundle.js"

# Argument functions
function show_help_panel() {
    echo -e "\n${YELLLOW}[+]${END}${GRAY} Usage:${END}"
    echo -e "\t${PURPLE}u)${END}${GRAY} Download or update files${END}"
    echo -e "\t${PURPLE}m)${END}${GRAY} Search machine by name${END}"
    echo -e "\t${PURPLE}i)${END}${GRAY} Search machine by ip${END}"
    echo -e "\t${PURPLE}d)${END}${GRAY} Search machine by difficulty${END}"
    echo -e "\t${PURPLE}o)${END}${GRAY} Search machine by os${END}"
    echo -e "\t${PURPLE}s)${END}${GRAY} Search machine by skill${END}"
    echo -e "\t${PURPLE}y)${END}${GRAY} Show youtube video${END}"
    echo -e "\t${PURPLE}h)${END}${GRAY} Show this help panel${END}\n"
}

function update_files() {
    tput civis

    if [ ! -f bundle.js ]; then
        echo -e "\n${YELLOW}[+]${END}${GRAY} Downloading files...${END}"
        curl -s -X GET $main_url > bundle.js
        js-beautify bundle.js | sponge bundle.js
        echo -e "\n${YELLOW}[+]${END}${GRAY} All the files have been downloaded${END}"
    else
        echo -e "\n${YELLOW}[+]${END}${GRAY} Checking for updates...${END}"
        
        curl -s -X GET $main_url > bundle_temp.js
        js-beautify bundle_temp.js | sponge bundle_temp.js
        md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_original_value=$(md5sum bundle.js | awk '{print $1}')
        
        if [ "$md5_temp_value" == "$md5_original_value" ]; then
            echo -e "\n${YELLO}[+]${END}${GRAY} There are not updates availables${END}"
            rm bundle_temp.js
        else
            echo -e "\n${YELLOW}[+]${END}${GRAY} There are updates${END}"
            rm bundle.js && mv bundle_temp.js bundle.js
            echo -e "\n${YELLOW}[+]${END}${GRAY} All files have been updated${END}"
        fi
    fi
    tput cnorm
}

function search_machine() {
    machine_name="$1"
    machines="$(cat bundle.js | awk "/name: \"$machine_name\"/,/resuelta:/" | grep -vE 'id|sku|resuelta' | tr -d "," | tr -d '"' | sed 's/^ *//')"
    if [ "$machines" ]; then
        echo -e "\n${YELLOW}[+]${END}${GRAY}Listing properties of machine:${END} ${BLUE}$machine_name${END}${GRAY}:${END}\n"
        echo -e "$machines\n"
    else
        echo -e "\n${RED}[!] The machine does not exists${END}"
    fi
}

function search_ip() {
    ip_address="$1"
    machine_name="$(cat bundle.js | grep "ip: \"$ip_address\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d ',"'| tr -d '"')"
    if [ "$machine_name" ]; then
        echo -e "\n${YELLOW}[+]${END} ${GRAY}The machine with the ip:${END} ${BLUE}$ip_address${END} ${GRAY}is${END} ${PURPLE}$machine_name${END}"
    else
        echo -e "\n${RED}[!] The machine does not exists${END}"
    fi
}

function search_youtube() {
    machine_name="$1"
    youtube_url="$(cat bundle.js | awk "/name: \"$machine_name\"/,/resuelta:/" | grep -vE 'id|sku|resuelta' | tr -d ',' | tr -d '"' | sed 's/^ *//' | grep 'youtube' | awk 'NF{print $NF}')"
    if [ "$youtube_url" ]; then
        echo -e "\n${YELLOW}[+]${END} ${GRAY}The youtube video is:${END} ${BLUE}$youtube_url${END}\n"
    else
        echo -e "\n${RED}[!] The machine does not exists${END}"
    fi
}

function search_difficulty() {
    difficulty="$1"
    machines="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',"' | tr -d '"' | column)"
    if [ "$machines" ]; then
        echo -e "\n${YELLOW}[+]${END}${GRAY}The machines with difficulty: ${END}${BLUE}$difficulty${END} ${GRAY}are:${END}\n"
        echo -e "$machines\n"
    else
        echo -e "\n${RED}[!] There are not macchines with that difficulty${END}"
    fi
}

function search_os() {
    os="$1"
    machines="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',"' | tr -d '"' | column)"

    if [ "$machines" ]; then
        echo -e "\n${YELLOW}[+]${END} ${GRAY}Showing the machines with the os:${END} ${BLUE}$os${END}\n"
        echo -e "$machines\n"
    else
        echo -e "\n${RED}[!] There are not machines with that os${END}"
    fi
}

function search_skill() {
    skill="$1"
    machines="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d ',"' | tr -d '"' | column)"

    if [ "$machines" ]; then
        echo -e "\n${YELLOW}[+]${END} ${GRAY}Showing the machines with the skill:${END} ${BLUE}$skill${END}\n"
        echo -e "$machines\n"
    else
        echo -e "\n${RED}[!] There are not machines with that skills${END}"
    fi
}

function search_difficulty_with_os() {
    difficulty="$1"
    os="$2"

    machines="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',"' | tr -d '"' | column)"

    if [ "$machines" ]; then
        echo -e "\n${YELLOW}[+]${END} ${GRAY}Showing the machines with the os:${END} ${BLUE}$os${END} ${GRAY}and difficulty:${END} ${BLUE}$difficulty${END}\n"
        echo -e "$machines\n"
    else
        echo -e "\n${RED}[!] There are not machines with that os and difficulty${END}"
    fi
}

declare -i parameter=0;
declare -i difficulty_flag=0;
declare -i os_flag=0;

while getopts "m:ui:y:d:o:s:h" arg; do
    case $arg in
        m) machine_name="$OPTARG"; let parameter+=1;;
        u) let parameter+=2;;
        i) ip_address="$OPTARG"; let parameter+=3;;
        y) machine_name="$OPTARG"; let parameter+=4;;
        d) difficulty="$OPTARG"; difficulty_flag=1; let parameter+=5;;
        o) os="$OPTARG"; os_flag=1; let parameter+=6;;
        s) skill="$OPTARG"; let parameter+=7;;
        h) ;;
    esac
done

if [ $parameter -eq 1 ]; then
    search_machine $machine_name
elif [ $parameter -eq 2 ]; then
    update_files
elif [ $parameter -eq 3 ]; then
    search_ip $ip_address
elif [ $parameter -eq 4 ]; then
    search_youtube $machine_name
elif [ $parameter -eq 5 ]; then
    search_difficulty $difficulty
elif [ $parameter -eq 6 ]; then
    search_os $os
elif [ $parameter -eq 7 ]; then
    search_skill "$skill"
elif [ $difficulty_flag -eq 1 ] && [ $os_flag -eq 1 ]; then
    search_difficulty_with_os $difficulty $os
else
    show_help_panel
fi