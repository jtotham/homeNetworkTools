#!/bin/bash

# Exits with 100 if < 1GiB free space.
# Exits with non-zero on error
# Exits with 0 if successfully resized disk

set -e 
set -u
set -o pipefail

DEBUG=

if [ "$UID" != "0" ]; then
    echo "root required"
    exit 1
fi

device=sda
$DEBUG echo 1 > /sys/block/${device}/device/rescan

free_space=$(parted -s /dev/$device unit B p free| awk '/Free Space/{sum += $3} END {printf "%.0f", sum}')

if [ $free_space -lt 1073741824 ]; then
    echo "disk has <1GB free space. Nothing to do"
    exit 100
fi

vg_name=$(pvs --noheadings -o vg_name /dev/${device}* 2>/dev/null|tr -d ' ' | head -n1 || true)
lv_path=$(lvs --noheadings -o lv_path $vg_name | tr -d ' ')
lvm_partition_num=$(parted -m -s /dev/$device print |grep -m1 'lvm' | cut -f1 -d:)

if [ -z "$lvm_partition_num" -o $lvm_partition_num -lt 3 ]; then
    echo "failed to find lvm partition number. Exiting"
    exit 1
fi

extended_partition_num=
for d in /sys/class/block/${device}? ; do
    if [ $(cat ${d}/size) -lt 50 ]; then
	extended_partition_num=$(cat $d/partition)
	break
    fi
done

if [ -z "$extended_partition_num" -o $extended_partition_num -lt 3 ]; then
    echo "failed to find extended partition number. Exiting"
    exit 1
fi

$DEBUG parted -s /dev/$device resizepart $extended_partition_num 100%
$DEBUG parted -s /dev/$device resizepart $lvm_partition_num 100%
$DEBUG echo 1 > /sys/block/${device}/device/rescan
$DEBUG pvresize /dev/${device}${lvm_partition_num}
# -r = extend underlying filesystem
$DEBUG lvextend -r -l 100%VG $lv_path
