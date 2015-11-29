#!/bin/bash

CPUS=`sar -u -P ALL 1 1|grep -e  "平均时间:" -e "Average:"|grep -v "CPU\|all"|awk '{ print $2 }'
`

COUNT=`echo "$CPUS" | wc -l`
INDEX=0
echo '{"data":['
echo "$CPUS" | while read LINE; do
    echo -n '{"{#CPUINDEX}":"'$LINE'"}'
    INDEX=`expr $INDEX + 1`
    if [ $INDEX -lt $COUNT ]; then
        echo ','
    fi
done
echo ']}'

