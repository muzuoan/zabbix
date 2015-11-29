#!/usr/bin/python -u
from zabbix_api import ZabbixAPI
from zabbix_api import ZabbixAPIException
global zapi
def initZapi(conf):
  global zapi
  zapi = ZabbixAPI(conf["url"])
  zapi.login(conf["username"], conf["password"])
  print "Connected to Zabbix API Version %s" % zapi.api_version()
  return zapi

def with_host_list(process):
  for h in zapi.host.get(output="extend"):
      process(h)
