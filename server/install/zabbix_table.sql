CREATE DATABASE zabbix CHARACTER SET UTF8;
grant all privileges on zabbix.* to zabbixuser@localhost identified by 'zabbixpass';
FLUSH PRIVILEGES;