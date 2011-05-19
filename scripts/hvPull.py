import ConfigParser,datetime,os,subprocess,sys,hvdb

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

# createTimeStamp
def CreateTimeStamp(string=True):
	""" Creates a time-stamp to be used by all log files. """
	now = datetime.datetime.now()
        timestamp = now.strftime('%Y%m%d_%H%M%S')
        nowDirectory = DateStructure(now)
        if string:
            return timestamp
        else:
            return timestamp, nowDirectory, now

def DefineStaging(d,local):
    stagingRoot = os.path.expanduser(local['Operation']['staging'])
    staging = stagingRoot + 'jp2' + os.sep + d
    return staging

def DefineIngestion(d,local):
    ingestionRoot = os.path.expanduser(local['Operation']['ingestion'])
    ingestion = ingestionRoot + 'jp2' + os.sep + d
    return ingestion

def DefineLog(local):
    stagingRoot = os.path.expanduser(local['Operation']['staging'])
    timestamp, nowDirectory, now = CreateTimeStamp(string=False)
    log = stagingRoot + 'log' + os.sep + nowDirectory + os.sep
    return log

def DefineQuarantine(d,local):
    stagingRoot = os.path.expanduser(local['Operation']['staging'])
    timestamp, nowDirectory, now = CreateTimeStamp(string=False)
    quarantine = stagingRoot + 'quarantine' + os.sep + nowDirectory + os.sep
    return quarantine

def DefineRemote(d,repository):
    locationRoot = repository['Remote']['location']
    location = locationRoot + d
    return location

def CreateLocalSubdirectories(d,local):
    staging = DefineStaging(d,local)
    if not os.path.exists(staging):
        os.makedirs(staging)

    ingestion = DefineIngestion(d,local)
    if not os.path.exists(ingestion):
        os.makedirs(ingestion)

    log = DefineLog(local)
    if not os.path.exists(log):
        os.makedirs(log)
    return staging,ingestion

def DefineStderr(local,timeStampString):
    log = DefineLog(local)
    if not os.path.exists(log):
        os.makedirs(log)
    errFilename = timeStampString + '.stderr.log'
    return log,errFilename

def DefineStdout(local,timeStampString):
    log = DefineLog(local)
    if not os.path.exists(log):
        os.makedirs(log)
    stdFilename = timeStampString + '.stdout.log'
    return log,stdFilename
    
def StageDataFromRepository(d,local,repository):
    remoteLocation =  DefineRemote(d,repository)
    staging = DefineStaging(d,local)
    localDir = ' -P'+staging+ ' '
    command = 'wget'
    argument = ' -r -l1 -nd -q --no-parent --timestamping -A.jp2 -R.html '+localDir+remoteLocation

    timeStampString = CreateTimeStamp()
    attempted = timeStampString + ': attempted command: '+command + argument+'\n'
    try:
        retcode = subprocess.call(command + argument, stderr = stderr, stdout = stdout,shell=True)
        if retcode < 0:
            stderr.write( timeStampString + ': wget: Child was terminated by signal,'+ str(-retcode)+'\n')
            stderr.write( attempted )
        else:
            stderr.write( timeStampString + ': wget: Child returned,'+ str(retcode)+'\n')
            stderr.write( attempted )
    except OSError, e:
        stderr.write( timeStampString + ': wget: Execution failed,'+ str(e)+'\n')
        stderr.write( attempted )

    return remoteLocation

def ListFilesInStagingDirectory(staging):
    if not os.path.exists(staging):
        return []
    fileList = os.listdir(staging)
    return fileList

def isFileGood(fullPathAndFilename,minimumFileSize,endsWith='.jp2'):
    """ Tests to see if a file meets the minimum requirements to be ingested into the database.
    An entry of -1 means that the test was not performed, 0 means failure, 1 means pass.
    """
    tests = {"fileExists":-1,"minimumFileSize":-1,"endsWith":-1}
    isFileGoodDB = 1
    fileProblem = 0
    
    # Does the file exist?
    if os.path.isfile(fullPathAndFilename):
        tests["fileExists"] = 1
        # test for file size
        s = os.stat(fullPathAndFilename)
        if s.st_size > minimumFileSize:
            tests["minimumFileSize"] = 1
        else:
            fileProblem = fileProblem + 2
            tests["minimumFileSize"] = 0
		
        # test that the file has the right extension
        if endsWith != '':
            if fullPathAndFilename.endswith(endsWith):
                tests["endsWith"] = 1
            else:
                fileProblem = fileProblem + 4
                tests["endsWith"] = 0
    else:
        fileProblem = fileProblem + 1
        tests["fileExists"] = 0

    # Has the file passed all the tests?
    isFileGoodDB = 1
    for i in tests.itervalues():
        if i == 0:
            isFileGoodDB = 0

    return isFileGoodDB, fileProblem

def MoveFilesFromStagingIntoIngestionAndUpdateDB(newFilesList):
    pass

def ClassifyNewFiles(candidates,acquired):
    pass

def QuarantineAndUpdateDB(badFiles):
    pass

class JP2:
    def __init__(self,value):
        self.name = value

    def __

def Get(repository,local,directories):
    # Open the standard error file
    timeStampString = CreateTimeStamp()
    err,errFilename = DefineStderr(local,timeStampString)
    out,outFilename = DefineStdout(local,timeStampString)

    global stderr,stdout
    stderr = open(err + errFilename,'a')
    stdout = open(out + outFilename,'a')

    # flatten the directories
    flatDirectories = [item for sublist in directories for item in sublist]
    # acquire data from the repository
    for d in flatDirectories:
        staging, ingestion = CreateLocalSubdirectories(d,local)
        remoteLocation = StageDataFromRepository(d,local,repository)
        fileList = ListFilesInStagingDirectory(staging)

        # at least one file found in the staging directory
        if len(fileList) > 0:
            alreadyInDB = hvdb.query()
            goodNewFiles, badNewFiles = ClassifyNewFiles(fileList,alreadyInDB)

            # at least one bad file
            if len(badNewFiles) > 0:
                # quarantine the bad files
                QuarantineAndUpdateDB(badNewFiles)
                # write information about quarantined files to stdout
                for filename in badNewFiles:
                    stdout.write(CreateTimeStamp() + ': quarantined '+ filename)

            # at least one goodfile
            if len(goodFiles) > 0:
                # move the good files, make sure the directory and file
                # permissions are set correctly, and update database
                MoveNewFilesFromStagingIntoIngestionAndUpdateDB(goodNewFiles)
                # write information about good new files to stdout
                for filename in goodNewFiles:
                    stdout.write(CreateTimeStamp() + ': moved to ingestion '+ filename)
            else:
                stdout.write(CreateTimeStamp() + ': no new files comparing database entries to '+remoteLocation)
        else:
            stdout.write(CreateTimeStamp() + ': no files found at '+remoteLocation)

    stderr.close()
    stdout.close()
