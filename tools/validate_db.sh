#!/usr/bin/env bash

GREEN="\e[01;32m"
WHITE_ON_BLUE="\e[1;37;1;44m"
BLUE="\e[1;34m"
CLEAR="\e[0m"

function highlight {
    echo -e "${WHITE_ON_BLUE}${1}${CLEAR}"
}

function validate_syntax {
  highlight "check DB entries"
  lua5.1 validate_db.lua
}

function getDatamine {
    highlight "pull git"
    if [ -d ./dcs-lua-datamine/.git ]; then
        cd dcs-lua-datamine
        git pull
        cd ..
    else
        git clone https://github.com/Quaggles/dcs-lua-datamine.git --depth 1 -b master
    fi
}

function sedDatamine {
    highlight "sed lua"
    find ./dcs-lua-datamine/_G/db/Units/ -regex ".*\/\(Ships\|Cars\)\/.*lua" | while read file; do echo "${file}"; sed -i 's/<table [[:digit:]]*>/\{\}/g' "${file}"; sed -i 's/<[[:digit:]]*>//g' "${file}"; done
}

function parse_datamine {
    lua5.1 parse_dcs-lua-datamine_for_hound.lua
}
validate_syntax
parse_datamine