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
  serverActive=$server
fi
echo $server $hostname $serverActive

rpm -ivh zabbix-2.2.9-1.el6.x86_64.rpm
rpm -ivh zabbix-agent-2.2.9-1.el6.x86_64.rpm
rpm -e zabbix-agent-conf
rpm -ivh zabbix-agent-conf-0.0.1-1.el6.x86_64.rpm

sed -i "s/Hostname=.*/Hostname=$hostname/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/Server=.*/Server=$server/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=.*/ServerActive=$serverActive/" /etc/zabbix/zabbix_agentd.conf
service zabbix-agent restart
if [ -f /etc/zabbix/version ];then
cat /etc/zabbix/version
fi
