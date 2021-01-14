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
    DEMO_PATH="demo_mission"
    SCRIPT_PATH="l10n/DEFAULT"
    MISSION_FILE="HoundElint_demo"
    mkdir -p ${DEMO_PATH}/${SCRIPT_PATH}
    cp ./include/*.lua ./${DEMO_PATH}/${SCRIPT_PATH}
    cp ./${DEMO_PATH}/${MISSION_FILE}.lua ./${DEMO_PATH}/${SCRIPT_PATH}

    cd ${DEMO_PATH}
    /usr/bin/zip -ur ${MISSION_FILE}.miz ${SCRIPT_PATH}
    cd ..
    rm -r ./${DEMO_PATH}/l10n
    }

## main
compile
update_mission
