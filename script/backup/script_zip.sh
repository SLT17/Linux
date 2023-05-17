#!/bin/bash

vm="namevm"
dir="/root/Linux/scripts/backup/$vm"
data=$(date+"%Y_%m_%d")
file1=$(ls $dir | grep /*.qcow2)
file2=$(ls $dir | grep /*.xml)

cd $dir
    if [ -]; then

