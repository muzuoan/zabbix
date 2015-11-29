#!/bin/bash
ZBX_REQ_DATA_CPU_INDEX="$1"

# source data file
SOURCE_DATA=/var/log/zabbix/multicpu-data

ERROR_NO_DATA_FILE="-0.9900"
ERROR_OLD_DATA="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_MISSING_PARAM="-0.9903"

# No data file to read from
if [ ! -f "$SOURCE_DATA" ]; then
  echo $ERROR_NO_DATA_FILE
  exit 1
fi

# Missing device to get data from
if [ -z "$ZBX_REQ_DATA_CPU_INDEX" ]; then
  echo $ERROR_MISSING_PARAM
  exit 1
fi

#
# Old data handling:
#  - in case the cron can not update the data file
#  - in case the data are too old we want to notify the system
# Consider the data as non-valid if older than OLD_DATA minutes
#
OLD_DATA=5
if [ $(stat -c "%Y" $SOURCE_DATA) -lt $(date -d "now -$OLD_DATA min" "+%s" ) ]; then
  echo $ERROR_OLD_DATA
  exit 1
fi

# 
# Grab data from SOURCE_DATA for cpu idle
#
# 1st check the device exists and gets data gathered by cron job
device_count=$(grep -Ec "^$ZBX_REQ_DATA_CPUINDEX" $SOURCE_DATA)
if [ $device_count -eq 0 ]; then
  echo $ERROR_WRONG_PARAM
  exit 1
fi

# 2nd grab the data from the source file
idle=$(grep -E "^$ZBX_REQ_DATA_CPU_INDEX " $SOURCE_DATA | awk '{print $2}')

echo $(echo "100-$idle"|bc)
exit 0

