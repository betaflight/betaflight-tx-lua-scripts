#!/bin/bash

if [ -d obj ]; then
    rm -fR obj/*
else
    mkdir obj
fi

cp -fR src/* obj

MANIFEST=(`find obj/ -name *.lua -type f`);
LAST_FAILURE=0

if [ ${#MANIFEST[@]} -eq 0 ]; then
    echo -e "\e[1m\e[39m[\e[31mTEST FAILED\e[39m]\e[21m No scripts could be found!."
    exit 1
fi

SCRIPTS_LUA=obj/SCRIPTS/BF/COMPILE/scripts.lua

echo 'local scripts = {' >> $SCRIPTS_LUA
for f in ${MANIFEST[@]};
do
    echo '    ''"'${f/\obj/}'",' >> $SCRIPTS_LUA
done
echo '}' >> $SCRIPTS_LUA
echo 'return scripts[...]' >> $SCRIPTS_LUA

MANIFEST+=($SCRIPTS_LUA);

for f in ${MANIFEST[@]};
do
    SRC_NAME=$f
    echo -e "Testing file \e[1m${SRC_NAME}\e[21m..."
    luac -p ${SRC_NAME}
    _fail=$?
    if [[ $_fail -ne 0 ]]; then
        LAST_FAILURE=$_fail
        echo -e "\e[1m\e[39m[\e[31mBUILD FAILED\e[39m]\e[21m Error in file ${SRC_NAME}\e[1m"
    fi
done

if [[ $LAST_FAILURE -eq 0 ]]; then
    echo -e "\e[1m\e[39m[\e[32mTEST SUCCESSFUL\e[39m]\e[21m"
fi
exit $LAST_FAILURE
