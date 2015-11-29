print_usage() {
  echo ""
  echo "Usage: install.sh  -S server[,server2...]  [-A ServerActive -H hostname]"
  echo ""
  echo "Flags:"
  echo "  -S  <server1,server2...> : zabbix server addr list;"
  echo "  -A  ServerActive : zabbix server addr in active;not required"
  echo "  -H  <hostname> : zabbix agent hostname;not required"
  echo "  -h  Show this page"
  echo ""
}

# Parse parameters
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            print_usage
            exit
            ;;
        -S | --server)
            shift
            server=$1
            ;;
        -A | --active)
            shift
            serverActive=$1
            ;;
        -H | --hostname)
            shift
            hostname=$1
            ;;
        *)  echo "Unknown argument: $1"
            print_usage
            exit
            ;;
        esac
    shift
done

if [[ -z $server ]];
then
  print_usage
  exit
fi

if [[ -z $hostname ]];
then
  hostname=`hostname|awk -F '.' '{print $1}'`
fi

if [[ -z $serverActive ]];
then
  serverActive=`echo $server|cut -d "," -f1`
fi
echo $server $hostname $serverActive
echo `date` install start >>/var/log/zabbix/zabbix_install.log

sed -i "s/Hostname=.*/Hostname=$hostname/" /tmp/zabbix/conf/zabbix_agentd.conf
sed -i "s/Server=.*/Server=$server/" /tmp/zabbix/conf/zabbix_agentd.conf
sed -i "s/ServerActive=.*/ServerActive=$serverActive/" /tmp/zabbix/conf/zabbix_agentd.conf

mkdir -p /etc/zabbix
mv -f /tmp/zabbix/conf/zabbix_agentd.conf /etc/zabbix/
mv -f /tmp/zabbix/conf/version /etc/zabbix/
cp -rf /tmp/zabbix/conf/zabbix_agentd.d /etc/zabbix/
cp -rf /tmp/zabbix/conf/cron.d/* /etc/cron.d/

mkdir -p /usr/lib/zabbix/externalscripts
cp -rf /tmp/zabbix/conf/externalscripts/* /usr/lib/zabbix/externalscripts/
chmod 755 -Rf /usr/lib/zabbix/externalscripts/*
chmod 755 /usr/lib/zabbix
chmod 755 /usr/lib/

if [ -f '/usr/local/squid/bin/squidclient'  ];then
  chmod 755 /usr/local/ /usr/local/squid /usr/local/squid/bin /usr/local/squid/bin/squidclient
fi

mv /tmp/zabbix/conf/zabbix.sudo /etc/sudoers.d/zabbix
chown root:root /etc/sudoers.d/zabbix
chmod 440 /etc/sudoers.d/zabbix

chkconfig crond on
service crond start

chkconfig zabbix-agent on

service zabbix-agent stop >/dev/null
service zabbix-agent start >/dev/null
service zabbix-agent stop >/dev/null
kill `ps -ef|grep zabbix_agentd.conf|grep -v grep|awk '{print $2}'`>>/dev/null 2>&1
service zabbix-agent start

echo `date` install over >>/var/log/zabbix/zabbix_install.log
rm -rf /tmp/zabbix/ 
