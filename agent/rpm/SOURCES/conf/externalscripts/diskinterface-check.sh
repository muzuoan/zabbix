#/bin/bash
flag="1"
sdev=$1
ddev=$(ls  /dev | grep -E 'sd[a-z]$|hd[a-z]$' |grep $sdev$)
if [ -z "$ddev" ]; then
	flag="0"
fi 

if [ $flag -eq "1" ]; then
#echo "flag is null"
	Vendor=`sudo smartctl --info /dev/$ddev |grep -i "Vendor" |awk  '{print $2}'`

		case $Vendor in
		"VMware" )
			echo "Not Support"

			;;
		* )
			#sudo smartctl --info /dev/$ddev |grep "Transport protocol:" |awk  '{print $3}'
	
			sudo /usr/bin/lsscsi -t |grep -E "\/dev\/$ddev" |awk  '{print $3}'|cut -d ":" -f 1	
			 ;;
		esac
	else
		echo "Not Check"

fi
