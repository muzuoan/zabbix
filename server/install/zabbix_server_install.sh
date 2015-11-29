bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
cd $bin
sed -i "s%baseurl=.*%baseurl=file://$bin/rpm%g" repos.d/local.repo
YUM_OPTION="--setopt=reposdir=repos.d"
yum install -y $YUM_OPTION httpd httpd-devel 
yum install -y $YUM_OPTION mysql mysql-libs mysql-server 
yum install -y $YUM_OPTION php php-cli php-common php-devel php-pear php-gd php-mbstring php-mysql php-xml

yum install -y $YUM_OPTION expect sshpass

service httpd start
service mysqld start

mysql_secure_installation

yum install -y $YUM_OPTION zabbix-server-mysql zabbix-web-mysql zabbix-get zabbix-agent 

mysql -u root -p <zabbix_table.sql
mysql -u zabbixuser -pzabbixpass zabbix < /usr/share/doc/zabbix-server-mysql-2.2.9/create/schema.sql
mysql -u zabbixuser -pzabbixpass zabbix < /usr/share/doc/zabbix-server-mysql-2.2.9/create/images.sql
mysql -u zabbixuser -pzabbixpass zabbix < /usr/share/doc/zabbix-server-mysql-2.2.9/create/data.sql

sed -i s%"# php_value date.timezone Europe/Riga"%"php_value date.timezone Asia/Shanghai"% /etc/httpd/conf.d/zabbix.conf
setenforce 0
cp -rf zabbix_server.conf /etc/zabbix/
service zabbix-server restart
service httpd restart

chkconfig mysqld on
chkconfig httpd on
chkconfig zabbix-server on
chkconfig zabbix-agent on


