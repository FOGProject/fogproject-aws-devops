#!/bin/bash
#
# Automates updateing of OS.

result="/root/patch_result"
output="/root/patch_output.log"


DEBIAN_FRONTEND=noninteractive


if [[ $(command -v dnf > /dev/null 2>&1;echo $?) -eq 0 ]]; then
    dnf -y update > $output 2>&1
    printf $? > $result
elif [[ $(command -v yum > /dev/null 2>&1;echo $?) -eq 0 ]]; then
    yum -y update > $output 2>&1
    printf $? > $result
elif [[ $(command -v apt-get > /dev/null 2>&1;echo $?) -eq 0 ]]; then
    apt-get -y update > $output 2>&1
    apt-get -y upgrade >> $output 2>&1
    printf $? > $result
else
    echo "Don't know how to update. Seems like it won't accept DNF, YUM, or APT-GET." > $output 2>&1
    printf "-1" > $result
fi


