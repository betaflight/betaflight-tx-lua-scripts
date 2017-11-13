#!/bin/bash 

if [ -d obj ]; then
    rm -fR obj
fi

cp -fR src obj

MANIFEST=(`find obj/ -name *.lua -type f`);

if [ ${#MANIFEST[@]} -eq 0 ]; then
    echo -e "\e[1m\e[39m[\e[31mTEST FAILED\e[39m]\e[21m No scripts could be found!."
    exit 1
fi

for f in ${MANIFEST[@]};
do
    SRC_NAME=$f
    OBJ_NAME=$(dirname ${f})/$(basename ${f} .lua).luac
    luac -o ${OBJ_NAME} ${SRC_NAME} || exit 1
done

echo -e "\e[1m\e[39m[\e[31mTEST SUCCESSFUL\e[39m]\e[21m All lua files built successfully!"
