#/bin/bash
sdev=$1
ddev=$(ls  /dev | grep -E 'sd[a-z]$|hd[a-z]$' |grep $sdev$)
flag="1"

if [ -z "$ddev" ]; then
        flag="0"
fi
if [ $flag -eq "1" ]; then
	Vendor=`sudo /usr/bin/lsscsi -d |grep -E "\/dev\/$ddev" |awk '{print $3} '`	
	case $Vendor in
        	"SEAGATE" )
                	sudo /usr/sbin/smartctl -A /dev/$ddev |grep -i "Current Drive Temperature:" |awk  '{print $4}'
        	;;	
     	  	 "ATA" )
               		sudo /usr/sbin/smartctl -A /dev/$ddev |grep -i "Temperature_Celsius" |awk '{print $10}'
        	;;
        	* )
                	sudo /usr/sbin/smartctl -A /dev/$ddev |grep -i "Current Drive Temperature:" |awk  '{print $4}'
       		 ;;
	esac
	
	else
		echo "0"

fi
