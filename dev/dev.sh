#
# for developer
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
../agent/build.sh
cd $bin/../agent/rpm
# test rpm install
rpm -e zabbix-agent-conf-0.0.1-1.el6.x86_64
rpm -ivh RPMS/x86_64/zabbix-agent-conf-0.0.1-1.el6.x86_64.rpm

#update yum
cp RPMS/x86_64/zabbix-agent-conf-0.0.1-1.el6.x86_64.rpm /home/yum/centos/6/x86_64/
createrepo /home/yum/centos/6/x86_64/

cd $bin/../agent
cp package/Fonsview.zagent_r2.2.9_CentOS_release_6.3_Final.x86_64.tar.gz /home/yum/

chown apache:apache -Rf /home/yum
