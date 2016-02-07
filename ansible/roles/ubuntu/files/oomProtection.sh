#!/bin/bash
protected=( /usr/sbin/mysqld /usr/sbin/sshd )

for prog in "${protected[@]}"
do
  pgrep -f $prog |
    while read PID
    do
      echo -17 > /proc/$PID/oom_adj
    done
done
