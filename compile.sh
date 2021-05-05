#!/bin/bash
TARGET_PATH="./include"
TARGET_FILE="${TARGET_PATH}/HoundElint.lua"

function compile {
    echo "-- Hound ELINT system for DCS " > ${TARGET_FILE}
    echo 'env.info("Hound ELINT Loading...")' >> ${TARGET_FILE}

    mkdir -p $TARGET_PATH
    for FILE in src/*; do
        echo "${FILE}"
        cat "${FILE}" >> ${TARGET_FILE}
    done
    echo "" >> ${TARGET_FILE}
    echo "env.info(\"Hound ELINT Loaded Successfully\")" >> ${TARGET_FILE}
    echo "-- Build date $(date +%d-%m-%Y)" >> ${TARGET_FILE}
} 

function update_mission {
    SCRIPT_PATH="l10n/DEFAULT"
    MISSION_PATH=${1:-"demo_mission"}
    MISSION_FILE=${2:-"HoundElint_demo"}

    echo "Updating ${MISSION_FILE}"
    mkdir -p ${MISSION_PATH}/${SCRIPT_PATH}
    cp ./include/*.lua ./${MISSION_PATH}/${SCRIPT_PATH}
    cp ./${MISSION_PATH}/${MISSION_FILE}.lua ./${MISSION_PATH}/${SCRIPT_PATH}

    cd ${MISSION_PATH}
    /usr/bin/zip -ur ${MISSION_FILE}.miz ${SCRIPT_PATH}
    until [ -d "./include" ]; do
        cd ..
    done
    sleep 1
    IN_USE=0
    until [ $IN_USE == 1 ]; do
        lsof ./${MISSION_PATH}/l10n > /dev/null
        IN_USE=$?
    done
    echo "CleanUp ${MISSION_FILE}"
    rm -r  ./${MISSION_PATH}/l10n
    }

## main
compile
update_mission
update_mission "demo_mission/Syria_POC" "Hound_Demo_SyADFGCI"
update_mission "demo_mission/Syria_HARM" "SpudHound"
