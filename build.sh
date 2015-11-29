bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
cd $bin
yum install rpm-build
SVNVERSION=`svn info|grep "Last Changed Rev"|awk '{print $4}'`
# rm -rf `find ./|grep "\.svn"`
chmod +x `find ./|grep .sh`
chmod +x `find ./|grep .expect`
BUILD_PATH=$bin/build_tmp/zabbix
TARGET=target

mkdir -p $TARGET
mkdir -p $BUILD_PATH
mkdir -p server/package

./agent/build.sh $SVNVERSION

#clean
unlink server/deploy/curent >/dev/null 2>&1
rm -rf server/deploy/log >/dev/null 2>&1
rm -rf server/deploy/1 >/dev/null 2>&1
rm -rf server/tool/*.pyc 2>&1
rm -rf server/tool/log 2>&1

rm -rf server/package/*
cp agent/package/Fonsview.zagent_r2.2.9_${SVNVERSION}_CentOS_release_6.3_Final.x86_64.tar.gz server/package
cp -rf docs $BUILD_PATH/ 
cd server && cp -rf * $BUILD_PATH/ 

cd $BUILD_PATH/..
echo test
tar -zcf $bin/target/Fonsview.zall_r2.2.9_${SVNVERSION}_CentOS_release_6.3_Final.x86_64.tar.gz --exclude=*.svn  zabbix/
rm -rf $bin/build_tmp

#test
# cd $bin/$TARGET
# tar -vxf zabbix_all.tar.gz
# cd zabbix/deploy
# chmod +x zabbix_tool.sh
# ./zabbix_tool.sh -i