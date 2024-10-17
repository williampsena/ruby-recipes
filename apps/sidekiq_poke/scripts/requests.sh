#!/bin/bash

function priorities() {
    options=("high" "low")
    value=$(printf "%s\n" "${options[@]}" | shuf -n 1)

    echo $value
}

function behaviours() {
    options=("default" "flaky" "fault" "slow")
    value=$(printf "%s\n" "${options[@]}" | shuf -n 1)

    echo $value
}

function _requests() {
    local temp_file="/tmp/poke.txt"
    declare -a pokemons

    cat pokemons.txt | shuf >$temp_file

    while IFS= read -r pokemon; do
        clear -x
        pokemons+=("$pokemon")        
    done <$temp_file
    
    pokemons_json=$(printf '%s\n' "${pokemons[@]}" | jq -R . | jq -s .)
    behaviour=$(behaviours)
    priority=$(priorities)

    curl -X POST http://localhost:4000/pokemon/batch \
     -H "Content-Type: application/json" \
     -d "{\"priority\": \"$priority\", \"behaviour\": \"$behaviour\", \"names\": $pokemons_json}"
}

for i in {1..10}; do
   _requests
   sleep 10
done
