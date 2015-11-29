def dict_to_csv(obj):
  return reduce(lambda x,y:x+","+y,obj.values())

def with_open_file(process,fileName):
  file = open(fileName)
  list = []
  for line in file.readlines():
    obj=process(line)
    list.append(obj)
  return list


def load_by_xls(file,colnameindex=0,table_name=u'Sheet1'):
    import xlrd
    def open_excel(file):
        try:
            data = xlrd.open_workbook(file)
            return data
        except Exception,e:
            print str(e)
    data = open_excel(file)
    table = data.sheet_by_name(table_name)
    nrows = table.nrows
    colnames =  table.row_values(colnameindex)
    list =[]
    for rownum in range(1,nrows):
         row = table.row_values(rownum)
         if row:
             app = {}
             for i in range(len(colnames)):
                app[colnames[i]] = row[i]
             list.append(app)
    return list

def load_by_csv(file,colnameindex=0):
    file = open(file)
    list =[]
    index =0
    colnames=[]
    for line in file.readlines():
        items=line.split(",")
        items= map(lambda x:x.strip(),items)

        if index==colnameindex:
            colnames=items
        else:
            obj={}
            for x in range(len(colnames)):
                obj[colnames[x]]=items[x]
            list.append(obj)
        index = index+1
    return list