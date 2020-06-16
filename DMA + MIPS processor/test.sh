#!/bin/bash

info=`tput setaf 5`
success=`tput setaf 2`
error=`tput setaf 1`
normal=`tput sgr0`
bold=`tput bold`

cd ../Verilog
{
diff out.txt out2.txt
} &> /dev/null
if [ $? -eq 0 ]; then
    echo "${success}${bold}Test case Successfully${normal}"
else
    echo "${error}${bold}Test case Failed${normal}"
fi
