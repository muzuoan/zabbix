bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
cd $bin
sed -i "s%baseurl=.*%baseurl=file://$bin/rpm%g" repos.d/local.repo
YUM_OPTION="--setopt=reposdir=repos.d"
yum install -y $YUM_OPTION mysql mysql-libs mysql-server 

yum install -y $YUM_OPTION zabbix-proxy-mysql zabbix-get zabbix-agent 

service httpd start
mysql -u root -p <zabbix_table.sql
mysql -u zabbixuser -pzabbixpass zabbix < /usr/share/doc/zabbix-proxy-mysql-2.2.9/create/schema.sql

cp -rf zabbix_proxy.conf /etc/zabbix/
service zabbix-proxy restart
chkconfig mysqld on
chkconfig zabbix-proxy on
chkconfig zabbix-agent on