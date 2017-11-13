#!/bin/bash

echo "test: ;" > Makefile

if [ -d sdcard ]; then
    rm -fR sdcard
fi

cp -fR src sdcard

MANIFEST=(`find sdcard/ -iname *.lua -type f`);
FAIL=0

if [ ${#MANIFEST[@]} -eq 0 ]; then
    echo -e "\e[1m\e[39m[\e[31mTEST FAILED\e[39m]\e[21m No scripts could be found!."
    exit 1
fi

for f in ${MANIFEST[@]};
do
    luamin -f $f > $f.mini
    mv $f.mini $f
    if [ `cat $f | wc -l` -ne 1 ]; then
        FAIL=1
        echo -e "\e[1m\e[39m[\e[31mFAIL\e[39m]\e[21m ${f}"
        cat $f
    else
        echo -e "\e[1m\e[39m[\e[32mPASS\e[39m]\e[21m ${f}"
    fi
done

if [ $FAIL -ne 0 ]; then
    echo -e "\e[1m\e[39m[\e[31mTEST FAILED\e[39m]\e[21m Please review your code and amend changes to the current branch."
    exit 1
fi

