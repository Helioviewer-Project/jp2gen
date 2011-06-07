import ConfigParser

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


data = ConfigParser.ConfigParser()
data.optionxform = str
data.read('aia.config.ini')

output = Config2Dictionary(data)

output['Observations']['measurements'] = eval(output['Observations']['measurements'])
output['Observations']['minimumFileSize'] = eval(output['Observations']['minimumFileSize'])

local = ConfigParser.ConfigParser()
local.optionxform = str
local.read('local.config.ini')
