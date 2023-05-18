#!/bin/bash

vm="namevm"
dir="way_dir/$vm"
data=$(date "+%Y_%m_%d")
file1=$(ls $dir | grep /*.qcow2)
file2=$(ls $dir | grep /*.xml)
logfile=("$vm"_"$data".txt)

if [ -d "$dir" ]; then
        cd $dir
        if [ -f "$dir/$file1" ] || [ -f "$dir/$file2" ]; then
            tar -czvf "$vm"_"$data".tar.gz $file1 $file2
                                process_id0=$!
                                wait $process_id0
                                rm -f $file1 $file2
                                zipfile=$(ls $dir | grep /*.tar.gz)
                                if [ -f $zipfile ]; then
                                    chown backup0:backup0 $zipfile
                                else
                                    echo "Error file owner" > $dir/$logfile
                        fi
                
        else
            echo "Files isn't exist" > $dir/$logfile
        fi
    else
        echo "Dir isn't exist" > $dir/$logfile
fi
if [ -f "$dir/$logfile" ]; then
	# Предварительно настроить отправку писем с сервера (mail+ssmtp)
    cat $dir/$logfile | mail -s "Zip $vm $data" mail@gmail.com
    process_id1=$!
    wait $process_id1
    rm -f $dir/$logfile
fi
exit 0
