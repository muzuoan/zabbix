SVNVERSION=$1
mkdir -p zabbix-agent
cp  *rpm install.sh uninstall.sh zabbix-agent/
tar -zcf Fonsview.zagent_r2.2.9_${SVNVERSION}_CentOS_release_6.3_Final.x86_64.tar.gz --exclude=*.svn zabbix-agent/
rm -rf zabbix-agent