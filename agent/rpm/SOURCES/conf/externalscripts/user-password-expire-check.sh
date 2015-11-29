#!/bin/bash
USER_INDEX="$1"
cur_day=$((`(date +%s)`/60/60/24))
#warning_day=7
#echo $USER_INDEX
# Missing device to get data from
if [ -z "$USER_INDEX" ]; then
  echo $ERROR_MISSING_PARAM
  exit 1
fi

expired_day=`sudo cat  /etc/shadow |grep  -E "^$USER_INDEX:" |awk -F ":" '{print $3+$5}'`
#echo $expired_day
#echo $cur_day

let n=$expired_day-$cur_day
echo $n
