#! /bin/bash

data=$(date "+%Y_%m_%d")
dir="dirbackup"
poolname="rbd_pool"
vm="nm"
vmconf="nm"
allspace="dirspace"
spacebackup=$(df -h "$allspace" | grep "$allspace" | awk '{print $5}' | sed 's/%//g')
usedspace=80

if [[ $spacebackup -gt $usedspace ]]; then
         echo "Free space off $dir/"$vm"_"$data"" | mail -s ""$vm"_"$data"" -S smtp="post.mail.ru" email@mail.ru 
else
        if [[ -d "$dir"/"$vm" ]]; then
                echo "Dir for backup "$vm"_"$data" is exist"
        else mkdir "$dir"/"$vm"
fi
                scp node5:/etc/libvirt/qemu/"$vmconf".xml  $dir/$vm/"$vmconf"_"$data".xml
                process_id0=$!
                wait $process_id0
                rbd snap create $poolname/$vm@"$vm"_"$data".snapshot;
                process_id1=$!
                wait $process_id1
                rbd -p $poolname export $vm@"$vm"_"$data".snapshot $dir/$vm/"$vm"_"$data";
                process_id2=$!
                wait $process_id2
                qemu-img convert -f rbd -O qcow2 $dir/$vm/"$vm"_"$data" $dir/$vm/"$vm"_"$data".qcow2
                process_id3=$!
                wait $process_id3
                rbd snap rm $poolname/$vm@"$vm"_"$data".snapshot
                process_id4=$!
                wait $process_id4
                rm -f $dir/$vm/"$vm"_"$data"
                process_id5=$!
                wait $process_id5
                echo "Backup "$vm"_"$data" completed successfully" | mail -s "Backup "$vm"_"$data"" -S smtp="post.mail.ru" email@mail.ru
fi
exit 0
