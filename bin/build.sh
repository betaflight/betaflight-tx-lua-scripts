#!/bin/bash

if [ -d obj ]; then
    rm -fR obj/*
else
    mkdir obj
fi

cp -fR src/* obj

MANIFEST=(`find obj/ -name *.lua -type f`);

if [ ${#MANIFEST[@]} -eq 0 ]; then
    echo -e "\e[1m\e[39m[\e[31mTEST FAILED\e[39m]\e[21m No scripts could be found!."
    exit 1
fi

for f in ${MANIFEST[@]};
do
    SRC_NAME=$f
    OBJ_NAME=$(dirname ${f})/$(basename ${f} .lua).luac
    echo -e "Compiling file \e[1m${SRC_NAME}\e[21m..." || \
    luac -o ${OBJ_NAME} ${SRC_NAME} || \
    echo -e "\e[1m\e[39m[\e[31mBUILD FAILED\e[39m]\e[21m Compilation error in file \e[1m${SRC_NAME}\e[21m!" || \
    exit 1
done

echo -e "\e[1m\e[39m[\e[32mTEST SUCCESSFUL\e[39m]\e[21m All lua files built successfully!"
