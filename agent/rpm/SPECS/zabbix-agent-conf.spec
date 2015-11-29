Name:       zabbix-agent-conf
Version:    0.0.1 
Release:    1%{?dist}
Summary:    zabbix agent conf
 
Group:      Application/Conf
License:    GPL
URL:        http://fonsview.com
Packager:   Tao <tao@fonsview.com>
Source0:    install.sh
Source1:    conf

BuildRoot:  %_topdir/BUILDROOT
 
Requires:   zabbix-agent 

%description
zabbix agent conf
 
%prep
echo %{_topdir}
 
%build

%install
echo test
rm -rf $RPM_BUILD_ROOT

# Setup required directories
mkdir -p $RPM_BUILD_ROOT/tmp/zabbix
install -m 0755 %{SOURCE0} $RPM_BUILD_ROOT/tmp/zabbix/
cp -r  %{SOURCE1} $RPM_BUILD_ROOT/tmp/zabbix/

%pre
service zabbix-agent stop

%post
/bin/sh /tmp/zabbix/install.sh -S 172.16.0.60,127.0.0.1

%preun
rm -rf /tmp/zabbix/ 

%postun
 
%clean
echo clean

%files
%defattr(-,root,root)
%dir /tmp/zabbix
%attr(0775,zabbix,zabbix)  /tmp/zabbix/install.sh
%attr(0640,zabbix,zabbix)  /tmp/zabbix/conf
