#!/bin/bash

cur_day=$((`(date +%s)`/60/60/24))
expire_day=

USERS=`sudo cat /etc/shadow |awk -F ":" '$2 !="!!" && $5 !="99999" {print $1}'`
COUNT=`echo "$USERS" | wc -l`
INDEX=0

echo '{"data":['
echo "$USERS" | while read LINE; do
    echo -n '{"{#USERNAME}":"'$LINE'"}'
    INDEX=`expr $INDEX + 1`
    if [ $INDEX -lt $COUNT ]; then
        echo ','
    fi
done
echo ']}'



