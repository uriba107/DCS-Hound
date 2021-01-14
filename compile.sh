#!/bin/bash
TARGET_PATH="./include"
TARGET_FILE="${TARGET_PATH}/HoundElint.lua"

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
