#!/bin/bash
TARGET_PATH="./include"
TARGET_FILE="${TARGET_PATH}/HoundElint.lua"
LDOC=$(which ldoc)
LUACHECK=$(which luacheck)

SED_ARGS="-i"
$(echo $OSTYPE | grep -q darwin)
isMacOs=$?
if [ $isMacOs -eq 0 ]; then
    SED_ARGS="-i .orig -e"
fi

# initial function setup
LINT_SRC=0
BUILD_DOCS=0
COMPILE=0
LINT_COMPILED=0
UPDATE_MISSIONS=0

GREEN="\e[01;32m"
WHITE_ON_BLUE="\e[1;37;1;44m"
BLUE="\e[1;34m"
CLEAR="\e[0m"


function check_dependecies {
    APT=""
    ROCKS=""
    if [ -z ${LDOC} ]; then
        APT="lua-ldoc ${APT}"
        ROCKS="ldoc ${ROCKS}"
    fi

    if [ -z ${LUACHECK} ]; then
        APT="lua-check ${APT}"
        ROCKS="luachek ${ROCKS}"
    fi

    if [ ! -z "${APT}" ]; then
      echo "missing Dependecies to install please run"
      echo "using apt"
      echo "sudo apt update; sudo apt install -y ${APT}"
      echo ""
      echo "using rocks"
      for rock in ${ROCKS[@]}; do
        echo "lucarocks install ${rock}"
      done 
      exit 1
    fi
}

function lint_src {
    echo -e "${WHITE_ON_BLUE}lint Hound source${CLEAR}"
    for FILE in src/*.lua; do
        luacheck -g --no-self --no-max-line-length "${FILE}"
    done
}
function build_docs {
    # build Docs
    echo -e "${WHITE_ON_BLUE}building public docs${CLEAR}"
    $LDOC -p "Hound<br> ELINT for DCS" --merge --style !fixed .

    echo -e "${WHITE_ON_BLUE}Building Dev Docs${CLEAR}"
    $LDOC -p "Hound<br> ELINT for DCS" -a -d docs/dev_docs --merge --style !fixed src
}

function lint_compiled {
    echo -e "${WHITE_ON_BLUE}lint compiled Hound${CLEAR}"
    luacheck -g --no-self --no-max-line-length "${TARGET_FILE}"
}

function compile {
    echo -e "${WHITE_ON_BLUE}Compile script${CLEAR}"
    echo "-- Hound ELINT system for DCS" > ${TARGET_FILE}
    echo 'env.info("Starting to load Hound ELINT...")' >> ${TARGET_FILE}

    mkdir -p $TARGET_PATH
    for FILE in src/*; do
        cat "${FILE}" >> ${TARGET_FILE}
    done

    # remove dev stuff
    echo -e "${BLUE}cleaning Dev comments${CLEAR}"
    sed -E ${SED_ARGS} '/StopWatch|:Stop()/d' ${TARGET_FILE}
    sed ${SED_ARGS} '/HoundLogger.trace("/d' ${TARGET_FILE}

    # disable logging
    sed ${SED_ARGS} "s/DEBUG = true/DEBUG = false/" ${TARGET_FILE}

    # clean comments
    sed ${SED_ARGS} '/^[[:space:]]*--/d' ${TARGET_FILE}
    sed ${SED_ARGS} 's/^[[:space:]]*\n^[[:space:]]*\n/^$/g' ${TARGET_FILE}

    GIT_BRANCH="-$(git branch --show-current | sed 's/[^a-zA-Z 0-9]/\\&/g')"
    if [ ${GIT_BRANCH} == "-main" ]; 
       then GIT_BRANCH="";
    fi
    sed ${SED_ARGS} "s/-TRUNK/""${GIT_BRANCH}""/" ${TARGET_FILE}

    VERSION=$(grep '        VERSION = ' ${TARGET_FILE} | cut -d\" -f2)
    echo "-- Hound version ${VERSION} - Compiled on $(TZ=UTC date +%Y-%m-%d' '%H:%M)" >> ${TARGET_FILE}

    if [ -f  ${TARGET_FILE}.orig ]; then
    rm -f ${TARGET_FILE}.orig
    fi

    # basic lint
} 

function print_includes {
    for FILE in src/*.lua; do
    echo "assert(loadfile(currentDir..'${FILE}'))()" | sed 's/\//\\\\/g'
    done
}

function update_mission {
    SCRIPT_PATH="l10n/DEFAULT"
    MISSION_PATH=${1:-"demo_mission"}
    MISSION_FILE=${2:-"HoundElint_demo"}

    echo "Updating ${MISSION_FILE}"
    mkdir -p ${MISSION_PATH}/${SCRIPT_PATH}
    cp ./include/*.lua ./${MISSION_PATH}/${SCRIPT_PATH}
    cp ./${MISSION_PATH}/${MISSION_FILE}.lua ./${MISSION_PATH}/${SCRIPT_PATH}
    if [ -d ${MISSION_PATH}/extras ]; then
        cp ./${MISSION_PATH}/extras/*.lua ./${MISSION_PATH}/${SCRIPT_PATH}
    fi

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
        sleep 1
    done
    echo "CleanUp ${MISSION_FILE}"
    rm -rf ./${MISSION_PATH}/l10n
    }

## main

while (( $# ))
do
    case "$1" in
        --test | -t )
            LINT_SRC=1
            shift
        ;;
        --docs | -d )
            BUILD_DOCS=1
            shift
        ;;
        --compile | -c )
            COMPILE=1
            LINT_COMPILED=1
            shift
        ;;

        --missions | -m )
            UPDATE_MISSIONS=1
            shift
        ;;
        --all )
            LINT_SRC=1
            BUILD_DOCS=1
            COMPILE=1
            LINT_COMPILED=1
            UPDATE_MISSIONS=1
            break
        ;;
        * )
            shift
        ;;
    esac
done

# Main
check_dependecies

if [ $LINT_SRC -eq 1 ]; then
    lint_src
fi
if [ $BUILD_DOCS -eq 1 ]; then
    build_docs
fi
if [ $COMPILE -eq 1 ]; then
    compile
fi
if [ ${LINT_COMPILED} -eq 1 ]; then
    lint_compiled
fi
if [ $UPDATE_MISSIONS -eq 1 ]; then
    update_mission "demo_mission/Caucasus_demo" "HoundElint_demo"
    update_mission "demo_mission/Syria_POC" "Hound_Demo_SyADFGCI"
    update_mission "demo_mission/Syria_HARM" "SpudHound"
fi
