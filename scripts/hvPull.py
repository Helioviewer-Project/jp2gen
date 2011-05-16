import ConfigParser,datetime

def ConfigSectionMap(Config,section):
    dict1 = {}
    options = Config.options(section)
    for option in options:
        try:
            dict1[option] = Config.get(section, option)
        except:
            print("exception on %s!" % option)
            dict1[option] = None
    return dict1

def Config2Dictionary(Config):
    dict2 = {}
    sections = Config.sections()
    for section in sections:
        try:
            dict2[section] = ConfigSectionMap(Config,section)
        except:
            print("exception on %s!" % section)
            dict2[section] = None
    return dict2


def ReadConfig(file1,file2):

    data = ConfigParser.ConfigParser()
    data.optionxform = str
    data.read(file1)

    dataDict = Config2Dictionary(data)

    dataDict['Observations']['measurements'] = eval(dataDict['Observations']['measurements'])
    dataDict['Observations']['minimumFileSize'] = eval(dataDict['Observations']['minimumFileSize'])

    local = ConfigParser.ConfigParser()
    local.optionxform = str
    local.read(file2)

    localDict = Config2Dictionary(local)
    
    localDict['Operation']['wait'] = eval(localDict['Operation']['wait'])
    localDict['Operation']['daysBackMin'] = eval(localDict['Operation']['daysBackMin'])
    localDict['Operation']['daysBackMax'] = eval(localDict['Operation']['daysBackMax'])

    if localDict['DatesTimes']['start'] != '-1':
        localDict['DatesTimes']['start'] = datetime.datetime.strptime(localDict['DatesTimes']['start'], "%Y/%m/%d %H:%M:%S")
    if localDict['DatesTimes']['end'] != '-1':
        localDict['DatesTimes']['end'] = datetime.datetime.strptime(localDict['DatesTimes']['end'], "%Y/%m/%d %H:%M:%S")


    return dataDict, localDict
