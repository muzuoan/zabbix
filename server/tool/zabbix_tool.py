#!/usr/bin/python -u
from functools import partial
import json
from zabbix_common import *
from common import *
import argparse
import logging

log=logging.getLogger("zabbix_tool");
log.setLevel(logging.DEBUG)

ch =logging.FileHandler("zabbix_tool.log")
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s\t  - %(message)s")
ch.setFormatter(formatter)

log.addHandler(ch)

global zapi


COLORS=["C80000", "00C800", "0000C8", "C800C8", "00C8C8", "C8C800", "C8C8C8", 
        "960000", "009600", "000096", "960096", "009696", "969600", "969696", 
        "FF0000", "00FF00", "0000FF", "FF00FF", "00FFFF", "FFFF00", "FFFFFF"]
COLORS_LEN=len(COLORS)

class Interface:
    typ=1
    useip=1
    port=10050
    dns=""
    main=1
    ip=""
    hostid=""

    def __init__(self,ip,type=1,port=10050,main=1,useip=1,dns=""):
        self.ip= ip
        self.typ=type
        self.port=port
        self.main=main
        self.useip=useip
        self.dns=dns
    def useDns(self,dns):
        self.useip=0
        self.dns=dns
        return self
    def toJson(self):
        return {
            "ip": self.ip,
            "type": self.typ,
            "port": self.port,
            "main": self.main,
            "useip":self.useip,
            "dns": self.dns
        }


def host_get(host):
    params={
        "output": "extend",
        "filter": {
            "host": [
                host
            ]
        }
    }
    hosts=zapi.host.get(params)
    if len(hosts)>0:
        return hosts[0]
    else:
        return None

def genParams(arg,server):
    params={
            "interfaces": [
            Interface(server["ip"]).toJson()
        ]
    }
    if server.get("ipmi_ip") and server.get("ipmi_ip") != "None":
        interface= Interface(server["ipmi_ip"],type=3,port=623).toJson()
        params["interfaces"].append(interface)
    h=host_get(server["host"])
    log.info(str(params))
    params["host"]=server["host"]
    if arg.conf.get("templateids"):
        params["templates"]= map(lambda id:{"templateid":str(id)},arg.conf["templateids"])
    params["ipmi_username"]="ADMIN"
    params["ipmi_password"]="ADMIN"
    params["ipmi_authtype"]="-1"
    params["ipmi_privilege"]="2"
    if h == None:
        log.info("host not exist")
        if arg.conf.get("groupids"):
            params["groups"]= map(lambda id:{"groupid":str(id)},arg.conf["groupids"])
        log.info(params)
        return params;

    else:
        params["hostid"]=h["hostid"]
        log.info("host exist")
        return params;

def host_create(arg,server):
    params= genParams(arg,server);
    if params.get("hostid"):
        return;
    result= zapi.host.create(params)
    log.info(result)

def host_update(arg,server):
    params= genParams(arg,server);
    if not params.get("hostid"):
        return;
    result=zapi.host.update(params)
    log.info(result)

def ipmi_config(arg,server):
    h=host_get(server["host"])
    if h == None:
        log.info(server["host"]+" host not exist ")
        return
    params={}
    params["hostid"]=h["hostid"]
    params["ipmi_username"]="ADMIN"
    params["ipmi_password"]="ADMIN"
    params["ipmi_authtype"]="-1"
    params["ipmi_privilege"]="2"
    result=zapi.host.update(params)
    log.info(result);
    
def ipmi_add(arg,server):
    if not server.get("ipmi_ip") or server.get("ipmi_ip")=="None":
        log.info("no ipmi_ip")
        return
    h=host_get(server["host"])
    if h == None:
        log.info(server["host"]+" host not exist ")
        return
    log.info(server["host"]+" "+h["hostid"])
    try:
        hostid = h["hostid"]
        result=zapi.hostinterface.exists(hostid=hostid,ip=server["ipmi_ip"])
        if result:
            log.info("ip exist")
            return
        else:

            params= Interface(server["ipmi_ip"],type=3,port=623).toJson()
            params["hostid"]=hostid
            zapi.hostinterface.create(params)
            log.info("add ipmi_interface ok "+server["host"]+" "+server["ipmi_ip"])
    except Exception,e:
        log.exception(e)
        return

def graph_cpu(arg,server):
    host = server["host"]
    def createGraph(name,items):
        obj={
            "name": name,
            "width": 900,
            "height": 200,
            "gitems":items
        }
        zapi.graph.create(obj)
    obj= {
        "output": "extend",
        "host": host,
        "search": {
          "key_": "multicpu"
        },
        "sortfield": "key_"
    }
    items=[]
    index=0
    for item in zapi.item.get(obj):
        log.info(item["name"]+" "+item["itemid"]);
        items.append({"itemid":item["itemid"],"color":COLORS[index%COLORS_LEN],"sortorder":str(index)})
        index = index+1
    if len(items) == 0:
        log.info(host+" no cpu items")
        return;
    try:
        createGraph("CPU Core Util",items)
        log.info(host+" add graph ok")
    except ZabbixAPIException,e:
        log.exception(e)


def parse_conf(arg,filename):
    file= open(filename)
    for line in file.readlines():
        key,value=line.strip().split(":")
        value= value.strip()
        try:
            value=json.loads(value.strip())
        except Exception, e:
            # log.exception(e)
            pass

        arg.conf[key] = value


def parse_func(pro,arg):
    global zapi
    conf = json.load("zabbix.conf")
    zapi=initZapi()
    if arg.conf:
        conf_name= arg.conf
        arg.conf={}
        parse_conf(arg,conf_name)
    if pro =="graph":
        for h in zapi.host.get(output="extend"):
            print h["host"]
            func = pro+"_"+arg.commond+"(arg,h)"
            exec func
        return
    if arg.all_hosts:
        servers=load_by_csv(arg.servers)
        for server in servers:
            print server["host"]
            try:
                func = pro+"_"+arg.commond+"(arg,server)"
                exec func
            except Exception, e:
                log.exception(e)
                continue
    else:
        func = pro+"_"+args.commond+"(arg)"    
        exec func


def parse_arguments():
    parser = argparse.ArgumentParser(description="zabbix tool")
    parser.add_argument("-s",'--servers',
        default="../conf/servers.csv",
        help="agent server conf fil")
    parser.add_argument("-c",'--conf',
    default="../conf/master.conf",
    help="conf file")

    group = parser.add_mutually_exclusive_group()
    group.add_argument("-A",'--all_hosts',
        action="store_true",
        help="action on all hosts",
        default = "true")
    group.add_argument('--hosts',
        help="just given hosts: host1,host2,host3...")

    subparsers = parser.add_subparsers(help="commonds")
    def add_sub_command(name,choices):
        sub_parser = subparsers.add_parser(name,help=name+" commond")
        sub_parser.set_defaults(func=partial(parse_func,name))
        sub_parser.add_argument("commond",help=name,choices=choices)
        
    add_sub_command("host",["create","update"])
    add_sub_command("ipmi",["add","config"])
    add_sub_command("graph",["cpu"])
    return parser.parse_args()


def test():
    global zapi
    zapi=initZapi()
    # print host_get("toronto1")
    servers=load_by_csv("../conf/servers.csv")
    for server in servers:
        host_create(server)

if __name__=="__main__":
    arg = parse_arguments()
    arg.func(arg)
    # test()
