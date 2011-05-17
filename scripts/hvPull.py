import ConfigParser,datetime,os

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

    repository = ConfigParser.ConfigParser()
    repository.optionxform = str
    repository.read(file1)

    repositoryDict = Config2Dictionary(repository)

    repositoryDict['Observations']['measurements'] = eval(repositoryDict['Observations']['measurements'])
    repositoryDict['Observations']['minimumFileSize'] = eval(repositoryDict['Observations']['minimumFileSize'])

    local = ConfigParser.ConfigParser()
    local.optionxform = str
    local.read(file2)

    localDict = Config2Dictionary(local)
    
    localDict['Operation']['wait'] = eval(localDict['Operation']['wait'])
    localDict['Operation']['daysBackMin'] = eval(localDict['Operation']['daysBackMin'])
    localDict['Operation']['daysBackMax'] = eval(localDict['Operation']['daysBackMax'])

    return repositoryDict, localDict

def Directories(repository,local,rootDate):
    dirs = []
    for daysBack in range(local['Operation']['daysBackMin'],local['Operation']['daysBackMax']):
        dt = rootDate - datetime.timedelta(days=daysBack)
        dirs.append( DirectoriesForAllMeasurements(repository,dt) )
    return dirs

def DirectoriesForAllMeasurements(repository,dt):
    dirs = []
    for measurement in repository['Observations']['measurements']:
        dirs.append(Directory(repository,dt,measurement))
    return dirs
    
def Directory(repository,dt,measurement):
    instrument = repository['Observations']['instrument'] + os.sep
    date = DateStructure(dt)
    return instrument + date + os.sep + measurement

def DateStructure(dt):
    if os.name == 'posix':
        return dt.strftime('%Y/%m/%d')
    if os.name == 'nt':
        return dt.strftime('%Y\%m\%d')

def Get(repository,local,directories):
    # flatten the directories
    flatDirectories = [item for sublist in directories for item in sublist]
    # acquire data from the repository
    for d in flatDirectories:
        CreateLocalSubdirectories(d,local)
        AcquireDataFromRepository(d,repository)

def CreateLocalSubdirectories(d,local):
    stagingRoot = os.path.expanduser(local['Operation']['staging'])
    staging = stagingRoot + os.sep + d
    if not os.path.exists(staging):
        os.makedirs(staging)

    ingestionRoot = os.path.expanduser(local['Operation']['ingestion'])
    ingestion = ingestionRoot + os.sep + d
    if not os.path.exists(ingestion):
        os.makedirs(ingestion)

    log = 

def CreateLocalPath(d):
    pass

def AcquireDataFromRepository(d,repository):
    pass
