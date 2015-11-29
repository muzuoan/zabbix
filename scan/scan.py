#!/usr/bin/python -u
from common import *
import commands
import socket
from functools import partial
import threading
from threading import Thread  
import time
import logging
import os

def with_file(filename):
  file = open(filename)

def with_log(filename):
  logging.basicConfig(filename = os.path.join(os.getcwd(), filename),filemode="w", level = logging.DEBUG)
  logging.debug('this is a message')

def with_server_list(process):
  list=load_by_xls(file="server2.xls",table_name=u"server")
  for server in list:
    process(server)

def with_server_list_thread(process):
  def thread_work(server):
    t =Thread(target=process,args=(server,))
    t.start()

  with_server_list(thread_work)

def server_check(server):
  command = "./ssh.sh %s %s %s" %(server["username"],server["password"],server["ip"])
  status,output = commands.getstatusoutput(command)
  if not status:
    logging.debug("good_server %s %s" %(server["name"],output))
    server["ssh_status"]="ok"
  else:
    logging.debug("bad_server %s %s" %(server["name"],output))
    if output:
      server["ssh_status"]=output
    else:
      server["ssh_status"]="Unknown Error"
  logging.debug("")
  return server

def server_print(server):
  logging.debug(reduce(lambda x,y:x+","+y,server.values()))



def ipmi_check(server):
  if server["on_cmd"] and server["on_cmd"].index("ipmitool")!=-1:
    status,output = commands.getstatusoutput(server["on_cmd"])
    if not status:
      logging.debug("ipmi_ok %s %s" % (server["on_cmd"],output))
      server["ipmi_status"]="ok"
    else:
      logging.debug("ipmi_bad %s %s" % (server["on_cmd"],output))
      if output:
        server["ipmi_status"]=output
      else:
        server["ipmi_status"]="Unknown Error"   
  else:
    server["ipmi_status"]="None"
  return server

def all_check(list,server):
  server = server_check(server)
  server = ipmi_check(server)
  list.append(server)

if __name__ == "__main__":
  print "ok"
  with_log("1.log");
  # with_server_list(server_print)
  # with_server_list(test_server)
  # with_server_list(test_server_thread)
  # with_server_list_thread(ipmi_check)
  # with_server_list_thread(server_test)
  list=[]
  with_server_list_thread(partial(all_check,list))

  while 1:
    time.sleep(1)
    print threading.activeCount()
    if threading.activeCount()  == 1:
      break
    pass
  file = open("server_status.csv","wb") 
  keys=["name","ip","username","password","on_cmd","ssh_status","ipmi_status"]
  file.write(list_to_csv(keys)+"\n")
  def getIp(ip):
    ip  = ip.strip()
    if not ip:
      return socket.inet_aton("10.10.10.10")
    else:
      return socket.inet_aton(ip)

  list = sorted(list,key = lambda server:getIp(server["ip"]))
  for server in list:
    file.write(reduce(lambda x,y:x+","+server[y].strip().replace(","," "),keys[1:],server["name"])+"\n")

  commands.getstatusoutput("chown -Rf fonsview:fonsview /home/fonsview/zabbix/")
