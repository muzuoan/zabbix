#!/bin/bash
#$1 /var/lib/mysql/zabbix
size=`sudo /usr/bin/du -m $1  | cut -f1 | cut -d "M" -f1 ` 
echo $size
