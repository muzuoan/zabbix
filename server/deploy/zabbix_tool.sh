#!/bin/bash
# ========================================================================================
# zabbix tool  
#
# Description   : zabbix tool

PROGNAME=$(basename $0)
RELEASE="Revision 1.0"

print_usage() {
  echo ""
  echo "$PROGNAME $RELEASE -zabbix tool"
  echo ""
  echo "Usage: zabbix_tool.sh [flags]"
  echo ""
  echo "Flags:"
  echo "  -m|--command run command on agents "
  echo "  -i|--install install agent"
  echo "  -c|--config  server config file"
  echo "               default: ../conf/servers.csv"
  echo "  -p|--pacakge angent pacakge file "
  echo "               defualt:../target/xxx-zabbix-conf-xxxx.tar.gz"
  echo "  -rp|--password rootpassword "
  echo ""
  echo "Usage: $PROGNAME -i"
  echo "Usage: $PROGNAME -m hostname"
  echo "Usage: $PROGNAME --help"
  echo ""
}

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
cd $bin

SERVERS_CONF=../conf/servers.csv
MASTER_CONF=../conf/master.conf

PACKAGE_NAME=`ls ../package|grep Fonsview.zagent`
PACKAGE=../package/$PACKAGE_NAME

CONF_DELIMITER=","
TASK=""
# Parse parameters
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            print_help
            ;;
        -c | --config )
            shift
            SERVERS_CONF=$1
            ;;
        -p | --package )
           shift
           PACKAGE=$1
           ;;
        -rp | --password )
           shift
           rootpassword=$1
           ;; 
        -i | --install )
          TASK="INSTALL"    
          ;;
        -m | --command)
          TASK="COMMAND"
          shift
          COMMAND=$1
          ;;
        *)  echo "Unknown argument: $1"
            print_usage
            ;;
        esac
    shift
done

if [ ! -f $SERVERS_CONF ];then
  echo "servers conf not exit"
  exit
fi
echo $SERVERS_CONF

work_one()
{
  line=$1
  host=`echo $line|awk -F $CONF_DELIMITER '{print $1}'`
  ip=`echo $line|awk -F $CONF_DELIMITER '{print $2}'`
  port=`echo $line|awk -F $CONF_DELIMITER '{print $3}'`
  username=`echo $line|awk -F $CONF_DELIMITER '{print $4}'`
  password=`echo $line|awk -F $CONF_DELIMITER '{print $5}'`
  rootpassword=`echo $line|awk -F $CONF_DELIMITER '{print $6}'`
  INSTALL_PATH="/usr/src/zabbix"
  if [ -z $host ];then
    return
  fi
  echo "work " $host $ip $port $username $password $rootpassword
  date >>$LOG_PATH/$host
  case $TASK in 
    COMMAND )
      echo "exec " $COMMAND >>$LOG_PATH/$host
      sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip $COMMAND >>$LOG_PATH/$host 2>&1
      ;;
    INSTALL )
      echo "exec install.. "  >>$LOG_PATH/$host

      # echo "./scp.expect $ip $username $password $PACKAGE $INSTALL_PATH" >>$LOG_PATH/$host 2>&1
      #./scp.expect $ip $username $password $PACKAGE $INSTALL_PATH >>$LOG_PATH/$host 2>&1
      echo "">>$LOG_PATH/$host 2>&1
      if [ $username = "root" ];then
        sshpass -p $password ssh -o port=$port -o StrictHostKeyChecking=no $username@$ip "mkdir -p $INSTALL_PATH >/dev/null"
        sshpass -p $password scp -o port=$port $PACKAGE $username@$ip:$INSTALL_PATH  >>$LOG_PATH/$host 2>&1
        sshpass -p $password ssh -o port=$port -o StrictHostKeyChecking=no $username@$ip  "cd $INSTALL_PATH;tar -vxf $PACKAGE_NAME;cd zabbix-agent;./install.sh -S $MASTER_IP" >>$LOG_PATH/$host 2>&1
        echo "">>$LOG_PATH/$host 2>&1
      else
        ./sshsudologin.expect $ip $port $username $password root $rootpassword "mkdir -p $INSTALL_PATH;chown -R $username:$username $INSTALL_PATH" >>$LOG_PATH/$host 2>&1
        echo "" >>$LOG_PATH/$host 2>&1
        echo "sshpass -p $password scp -o port=$port $PACKAGE $username@$ip:$INSTALL_PATH" >>$LOG_PATH/$host 2>&1
        sshpass -p $password scp -o port=$port  $PACKAGE $username@$ip:$INSTALL_PATH  >>$LOG_PATH/$host 2>&1
        ./sshsudologin.expect $ip $port $username $password root $rootpassword  "cd $INSTALL_PATH;tar -vxf $PACKAGE_NAME;cd zabbix-agent;sudo ./install.sh -S $MASTER_IP" >>$LOG_PATH/$host 2>&1
        echo "">>$LOG_PATH/$host 2>&1
      fi
      ;;
      *)  echo "do nothing"
          exit
          ;;
      esac
  echo $host over
}


work_all()
{
  date=`date +%m%d%H%M%S`
  mkdir -p log/$date >/dev/null 2>&1
  LOG_PATH=log/$date
  echo $LOG_PATH
  rm curent -f
  ln $LOG_PATH -s curent
  servers=`cat $SERVERS_CONF`
  OLD_IFS="$IFS"
  IFS=$'\x0A'
  for line in $servers 
  do 
    if [ `echo $line|grep -c password` -eq 1 ];then
      echo  $line
      continue
    fi
    echo $line  
    work_one $line &
  done
  wait
}

case $TASK in 
  COMMAND )
    if [ -z $COMMAND ];then
      echo "please input command"
      exit
    fi

    echo "exec " $COMMAND
    work_all
    ;;
  INSTALL )
    if [ ! -f $PACKAGE ];then
      echo "pacakge file not exist"
      exit
    fi
    if [ ! -f $MASTER_CONF ];then
      echo "zabbix_server conf file not exist"
      exit
    fi
    echo $PACKAGE $MASTER_CONF
    MASTER_IP=`grep "ip:" $MASTER_CONF|awk '{print $2}'`
    if [ -z $MASTER_IP ];then
      echo "zabbix_server ip not exist"
      exit
    fi
    echo $MASTER_IP

    COMMAND="install"
    work_all
    ;;
    *)  echo "do nothing"
        print_usage
        ;;
    esac