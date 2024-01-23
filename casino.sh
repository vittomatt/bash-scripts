----
# Ctrl+C
function ctrl_c() {
    echo -e "\n[!] Exiting..."
    tput cnorm
    exit 1
}

trap ctrl_c SIGINT

function help_panel() {
    echo -e "\nUsage: $0:"
    echo -e "\tm): Money to play"
    echo -e "\tt): Technique to use: (martingala | labrouchere)"
    exit 1
}

while getopts "m:t:h" arg; do
    case $arg in
        m) money=$OPTARG;;
        t) technique=$OPTARG;;
        h) help_panel;;
    esac
done

function play_martingala() {
    money=$1
    echo -e "\n[+] Current money: $money"
    echo -ne "[+] Enter the bet: " && read initial_bet
    echo -ne "[+] Choose even/odd: " && read even_odd

    backup_bet=$initial_bet
    play_counter=0
    bad_games=""

    tput civis
    while true; do
        let play_counter+=1
        money=$(( $money - $initial_bet ))
        random_number=$(( $RANDOM % 37 ))

        if [ "$money" -le 0 ]; then
            echo -e "\n[!] You don't have money"
            echo -e "[+] You played $play_counter times"
            echo -e "[+] Bad games: $bad_games"
            tput cnorm
            exit 0
        fi

        if [ "$random_number" -eq 0 ]; then
            let bad_games+="$random_number "
            initial_bet=$(( $initial_bet * 2 ))
            continue
        fi

        if [ "$(( $random_number % 2 ))" -eq 0 ]; then
            if [ "$even_odd" == "even" ]; then
                reward=$(( $initial_bet * 2 ))
                money=$(( $money + $reward ))
                initial_bet=$backup_bet
                bad_games=""
            else
                let bad_games+="$random_number "
                initial_bet=$(( $initial_bet * 2 ))
            fi
        else
            if [ "$even_odd" == "odd" ]; then 
                reward=$(( $initial_bet * 2 ))
                money=$(( $money + $reward ))
                initial_bet=$backup_bet
                bad_games=""
            else
                let bad_games+="$random_number "
                initial_bet=$(( $initial_bet * 2 ))
            fi
        fi
    done
    tpu cnorm
}

function play_labrouchere() {
    money=$1
    echo -e "\n[+] Current money: $money"
    echo -ne "[+] Choose even/odd: " && read even_odd

    declare -a my_sequence=(1 2 3 4)
    declare -i bet=0

    play_counter=0

    tput civis
    while true; do
        let play_counter+=1
        
        if [ "${#my_sequence[@]}" -eq 0 ]; then
            my_sequence=(1 2 3 4)
            last_position=$(( ${#my_sequence[@]} - 1 ))
            last_element=${my_sequence[$last_position]}
            bet=$((${my_sequence[0]} + ${last_element}))
            unset my_sequence[0]
            unset my_sequence[${last_position}]
        elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}
            unset my_sequence[0]
        else
            last_position=$(( ${#my_sequence[@]} - 1 ))
            last_element=${my_sequence[$last_position]}
            bet=$((${my_sequence[0]} + ${last_element}))
            unset my_sequence[0]
            unset my_sequence[${last_position}]
        fi
        
        my_sequence=(${my_sequence[@]})
        money=$(( $money - $bet ))
        
        if [ "$money" -le 0 ]; then
            echo -e "\n[!] You don't have money"
            echo -e "[+] You played $play_counter times"
            tput cnorm
            exit 0
        fi
        
        random_number=$(( $RANDOM % 37 ))

        if [ "$random_number" -eq 0 ]; then
            continue
        fi

        if [ "$(( $random_number % 2 ))" -eq 0 ]; then
            if [ "$even_odd" == "even" ]; then
                reward=$(( $bet * 2 ))
                money=$(( $money + $reward ))
                let my_sequence+=($bet)
                my_sequence=(${my_sequence[@]})
            fi
        else
            if [ "$even_odd" == "odd" ]; then 
                reward=$(( $bet * 2 ))
                money=$(( $money + $reward ))
                let my_sequence+=($bet)
                my_sequence=(${my_sequence[@]})
            fi
        fi

    done
    tput cnorm
}

if [ $money ] && [ $technique ]; then
    if [ "$technique" == "martingala" ]; then
        play_martingala $money
    elif [ "$technique" == "labrouchere" ]; then
        play_labrouchere $money
    else
        help_panel
    fi
else 
    help_panel
fi

exit 0