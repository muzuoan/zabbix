echo "ok status"
zabbix_agentd -t net.if.speed[eth0]
zabbix_agentd -t net.if.duplex[eth0]
zabbix_agentd -t net.if.enable[eth0]
zabbix_agentd -t net.if.link[eth0]

echo ""
echo "baid status"
zabbix_agentd -t net.if.speed[eth1]
zabbix_agentd -t net.if.duplex[eth1]
zabbix_agentd -t net.if.enable[eth1]
zabbix_agentd -t net.if.link[eth1]

zabbix_agentd -t diskstat[sdc]
zabbix_agentd -t corefile.num

zabbix_get -s 127.0.0.1 -k corefile.num