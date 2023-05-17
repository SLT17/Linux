#!/bin/bash

vm="namevm"
dir="/root/Linux/script/backup/$vm"
data=$(date+"%Y_%m_%d")
file1=$(ls $dir | grep /*.qcow2)
file2=$(ls $dir | grep /*.xml)

cd $dir
    if [ -d $dir ]; then
        if [ -f $file1 || $file2 ]; then
            tar -czvf $vm_"$data".tar.gz $file1 $file2
        else
            echo "Dir isn't exist" > text1.txt
        fi 
    else
    echo 
    fi
    if [ -f $zipfile]; then
    else
    fi
    echo | mail -s "" prok@gmail.com

exit 0



