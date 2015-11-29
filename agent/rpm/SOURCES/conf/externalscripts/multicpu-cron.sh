DEST_DATA=/var/log/zabbix/multicpu-data
TMP_DATA=/var/log/zabbix/multicpu-data.tmp

sar -P ALL 2 5 |grep Average|awk '{print $2 " " $NF}'> $TMP_DATA
mv $TMP_DATA $DEST_DATA