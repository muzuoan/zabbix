bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
cd $bin
echo "% _topdir $bin/rpm" >~/.rpmmacros
echo $1 > rpm/SOURCES/conf/version
mkdir -p /tmp/tmp_zabbix_rpm_buid
cp -rf rpm/SOURCES/ /tmp/tmp_zabbix_rpm_buid
rm -rf `find rpm/SOURCES/|grep "\.svn"`
rpmbuild -bb rpm/SPECS/zabbix-agent-conf.spec
rm -rf rpm/SOURCES
mv /tmp/tmp_zabbix_rpm_buid/SOURCES rpm/

#update tar
cp rpm/RPMS/x86_64/zabbix-agent-conf-0.0.1-1.el6.x86_64.rpm package/
cd package 
./tar.sh $1
cd ..

cat  rpm/SOURCES/conf/version

