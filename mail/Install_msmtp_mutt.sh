#!/bin/bash
#脚本用来一键安配置msmtp+mutt，实现代理发邮件功能。
# 
# http://nchc.dl.sourceforge.net/sourceforge/msmtp/msmtp-1.4.17.tar.bz2 

cat << EOF
+------------------------------------------------------------+
|=======================欢迎使用安装脚本=====================|
+------------------------------------------------------------+
EOF
CUR_PATH=$(cd "$(dirname "$0")"; pwd)
echo "********************安装配置msmtp***********************"
tar -jxf $CUR_PATH/msmtp-1.4.17.tar.bz2 -C /usr/src/
cd /usr/src/msmtp-1.4.17
./configure --prefix=/usr/local/msmtp 
make --jobs=`grep processor /proc/cpuinfo | wc -l`
make install 
mkdir -p /usr/local/msmtp/etc
cd /usr/local/msmtp/etc
echo '# msmtp config file
account default
logfile /var/log/mmlog
host smtp.exmail.qq.com
port 25
tls off
from mail-helper@fonsview.com
auth login
user mail-helper@fonsview.com
password Hello123' > msmtprc

touch /var/log/mmlog
chmod 755 /usr/local/msmtp -R #注意系统的umask

echo "********************安装配置mutt***********************"
tar -zxf $CUR_PATH/mutt-1.5.23.tar.gz -C /usr/src/
cd /usr/src/mutt-1.5.23
./configure 
make --jobs=`grep processor /proc/cpuinfo | wc -l`
make install
#zabbix用户家目录
zabbix_home=$(cat /etc/passwd |grep zabbix |awk -F : '{print $6}')

if [ ! -z $zabbix_home ]; 
	then
		echo "修改zabbix用户信息"
		mkdir -p $zabbix_home
		chown zabbix:zabbix  $zabbix_home
	    chown zabbix:zabbix /var/log/mmlog
		usermod -s /bin/bash zabbix  


echo '#~/.muttrc
set sendmail="/usr/local/msmtp/bin/msmtp"
set use_from=yes
set envelope_from=yes
set from=mail-helper@fonsview.com
set realname="zabbix_notify"
set editor="vim"
#群组功能设置
alias WeiRong Wei Rong <weirong@fonsview.com>
alias TaoChen Tao Chen <tao@fonsview.com>
alias test-group WeiRong,TaoChen' > $zabbix_home/.muttrc
chown zabbix:zabbix $zabbix_home/.muttrc

fi

echo "******************配置zabbix中调用shell*****************"
mailpath=$(cat  /etc/zabbix/zabbix_server.conf |grep AlertScriptsPath|awk -F "=" '{print $2}')
echo $mailpath
if [  -z $mailpath ];then echo "请先安装zabbix server,zabbix配置AlertScriptsPath路径"
else
mkdir $mailpath
touch $mailpath/mail.sh

chown zabbix:zabbix -R $mailpath
echo '
#!/bin/bash
# $1 sendmail address
# $2 sendmail subject
# $3 file
echo "$3" | mutt -s "$2" $1 ' > $mailpath/mail.sh
chmod u+x $mailpath/mail.sh
fi

echo "******************测试调用shell发邮件*****************"
ls -l $mailpath/mail.sh
echo "zabbix用户身份执行mail.sh测试邮件发送"
#echo "/usr/lib/zabbix/alertscripts/mail.sh    weirong@fonsview.com "zabbix_notify test"   "zabbix mail test"" |su - zabbix
echo "/usr/lib/zabbix/alertscripts/mail.sh    test-group  "zabbix_notify test"   "zabbix mail test"" |su - zabbix
if [ $? -eq 0  ]; then echo "邮件发送成功"
	else echo "请检查邮件配置信息！"
fi

