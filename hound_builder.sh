#!/bin/bash
TARGET_PATH="./include"
TARGET_BASENAME="HoundElint"
TARGET_FILE="${TARGET_PATH}/${TARGET_BASENAME}.lua"
MINIFIED_PATH=${TARGET_PATH}/minified
mkdir -p ${MINIFIED_PATH}

SED_ARGS="-i"
LUAROCKS="luarocks"
$(echo $OSTYPE | grep -q darwin)
isMacOs=$?
if [ $isMacOs -eq 0 ]; then
    export PATH="$PATH:$HOME/.luarocks/bin"
    SED_ARGS="-i .orig -e"
    LUAROCKS="luarocks --lua-dir=$(brew --prefix)/opt/lua@5.1 --lua-version=5.1"
fi

LDOC=$(which ldoc) 
LUACHECK=$(which luacheck)
LUASRCDIET=$(which luasrcdiet)
MD_TOC="${HOME}/gh-md-toc"

# initial function setup
LINT_SRC=0
BUILD_DOCS=0
COMPILE=0
MINIFY=0
RELEASE=0
UPDATE_MISSIONS=0
FETCH_LIB=0

GREEN="\e[01;32m"
WHITE_ON_BLUE="\e[1;37;1;44m"
BLUE="\e[1;34m"
CLEAR="\e[0m"

function highlight {
    echo -e "${WHITE_ON_BLUE}${1}${CLEAR}"
}

function check_dependecies {
    APT=""
    ROCKS=""
    if [ -z ${LDOC} ]; then
        APT="lua-ldoc ${APT}"
        ROCKS="ldoc ${ROCKS}"
    fi

    if [ -z ${LUACHECK} ]; then
        APT="lua-check ${APT}"
        ROCKS="luacheck ${ROCKS}"
    fi

    if [ -z ${LUASRCDIET} ]; then
        ROCKS="luasrcdiet ${ROCKS}"
    fi

    if [ ! -f ${MD_TOC} ]; then
      MD_TOC_VERSION=1.4.0
      MD_TOC_URL="https://github.com/ekalinin/github-markdown-toc.go/releases/download/v${MD_TOC_VERSION}/gh-md-toc_${MD_TOC_VERSION}_linux_amd64.tar.gz"
      if [ $isMacOs -eq 0 ]; then
      MD_TOC_URL=$(echo ${MD_TOC_URL} | $SED 's/linux/darwin//')
      fi
      curl -L ${MD_TOC_URL} -o ${MD_TOC}.tar.gz
      tar -xzvf ${MD_TOC}.tar.gz -C ${HOME} gh-md-toc
      rm  ${MD_TOC}.tar.gz
      #chmod a+x ${MD_TOC}
    fi

    if [ ! -z "${APT}" ] || [ ! -z "${ROCKS}" ]; then
      echo "missing Dependecies to install please run"
      echo "using apt"
      echo "sudo apt update; sudo apt install -y ${APT}"
      echo ""
      echo "using rocks"
      for rock in ${ROCKS[@]}; do
        echo "${LUAROCKS} install ${rock}"
      done 
      exit 1
    fi
}

function lint_src {
    highlight "lint Hound source"
    for FILE in src/*.lua; do
        luacheck -g --no-self --no-max-line-length "${FILE}"
    done
}
function build_docs {
    # build Docs
    highlight "building public docs"
    $LDOC -p "Hound<br> ELINT for DCS" --merge --style !fixed .

    highlight "Building Dev Docs$"
    $LDOC -p "Hound<br> ELINT for DCS" -a -d docs/dev_docs --merge --style !fixed src
}

function build_toc {
    local README=${1:-README.MD}
    highlight "Buding TOC for ${README}"

   TOC_CONTENT=$(/home/uri/gh-md-toc --hide-footer ./docs/src/${README}) \
     envsubst < ./docs/src/${README} > ./${README}
} 

function lint_compiled {
    highlight "lint compiled Hound"
    luacheck -g --no-self --no-max-line-length "${TARGET_FILE}"

    if [ -f ${TARGET_BASENMAE}_.lua ]; then
        highlight "lint minified Hound"
        luacheck -g --no-self --no-max-line-length "${TARGET_BASENMAE}_.lua"
    fi
}

function compile {
    set -e
    highlight "Compile script"
    echo "-- Hound ELINT system for DCS" > ${TARGET_FILE}
    # echo 'env.info("[Hound] - start loading (".. HOUND.VERSION..")")' >> ${TARGET_FILE}

    mkdir -p $TARGET_PATH
    for FILE in src/*; do
        cat "${FILE}" >> ${TARGET_FILE}
    done

    # remove dev stuff
    highlight "cleaning Dev comments"
    sed -E ${SED_ARGS} '/StopWatch|:Stop()/d' ${TARGET_FILE}
    sed ${SED_ARGS} '/HOUND.Logger.trace("/d' ${TARGET_FILE}

    # disable logging
    sed ${SED_ARGS} "s/DEBUG = true/DEBUG = false/" ${TARGET_FILE}

    # clean comments
    sed ${SED_ARGS} '/^[[:space:]]*--/d' ${TARGET_FILE}
    sed ${SED_ARGS} '$!N;/^[[:space:]]*$/{$q;D;};P;D;' ${TARGET_FILE}

    GIT_BRANCH="-$(git branch --show-current | sed 's/[^a-zA-Z 0-9]/\\&/g')-$(date +%Y%m%d)"
    if [ ${GIT_BRANCH} == "-main-$(date +%Y%m%d)" ] || [ $RELEASE -eq 1 ]; 
       then GIT_BRANCH="";
    fi
    sed ${SED_ARGS} "s/-TRUNK/""${GIT_BRANCH}""/" ${TARGET_FILE}

    VERSION=$(grep '        VERSION = ' ${TARGET_FILE} | cut -d\" -f2)
    echo "-- Hound version ${VERSION} - Compiled on $(TZ=UTC date +%Y-%m-%d' '%H:%M)" >> ${TARGET_FILE}

    if [ -f  ${TARGET_FILE}.orig ]; then
    rm -f ${TARGET_FILE}.orig
    fi
    set +e
} 

function minify_compiled {
     # create minified versions
    mkdir -p ${MINIFIED_PATH}
    ${LUASRCDIET} --basic --opt-emptylines ${TARGET_FILE} -o ${MINIFIED_PATH}/${TARGET_BASENAME}_.lua

}
function fetch_mist {
    MIST_BRANCH=${1:-development}
    curl -L https://raw.githubusercontent.com/mrSkortch/MissionScriptingTools/${MIST_BRANCH}/mist.lua -o ${TARGET_PATH}/mist.lua
    # ${LUASRCDIET} --basic --opt-emptylines ${TARGET_PATH}/mist.lua -o ${MINIFIED_PATH}/mist_.lua
}

function print_includes {
    for FILE in src/*.lua; do
    echo "assert(loadfile(currentDir..'${FILE}'))()" | sed 's/\//\\\\/g'
    done
}

function update_mission {
    set -e
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
    set +e
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
            shift
        ;;
        --minify )
            MINIFY=1
            shift
        ;;

        --lib | -l )
            FETCH_LIB=1
            shift
        ;;
        --missions | -m )
            FETCH_LIB=1
            UPDATE_MISSIONS=1
            shift
        ;;
        --release )
            FETCH_LIB=1
            RELEASE=1
            BUILD_DOCS=1
            COMPILE=1
            UPDATE_MISSIONS=1
            shift
        ;;
        --all )
            LINT_SRC=1
            BUILD_DOCS=1
            COMPILE=1
            UPDATE_MISSIONS=1
            FETCH_LIB=1
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

if [ $FETCH_LIB -eq 1 ]; then
    fetch_mist
fi

if [ $COMPILE -eq 1 ]; then
    compile
    if [ $MINIFY -eq 1 ]; then
        minify_compiled
    fi
    lint_compiled
fi

if [ $BUILD_DOCS -eq 1 ]; then
    build_docs
    build_toc
fi

if [ $UPDATE_MISSIONS -eq 1 ]; then
    update_mission "demo_mission/Caucasus_demo" "HoundElint_demo"
    update_mission "demo_mission/Syria_POC" "Hound_Demo_SyADFGCI"
    update_mission "demo_mission/Syria_HARM" "Hound_Demo_syria"
fi