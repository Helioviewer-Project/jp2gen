import ConfigParser,datetime,os,subprocess,sys

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


class Config:
    """Create a configuration object that stores all the information
    we need to locate and store the data from the repository.
    """
    def __init__(self,value):
        self.filename = value
        for v in value:
            r = ConfigParser.ConfigParser()
            r.optionxform = str
            r.read(v)

            rD = Config2Dictionary(r)

            self.type = rD['Type']['this']

            if self.type == 'from':
                self.location = rD['Where']['location']
                del rD['Type']
                del rD['Where']
                for key in rD.keys():
                    rD[key]['minimumFileSize'] = eval(rD[key]['minimumFileSize'])
                    rD[key]['measurements'] = eval(rD[key]['measurements'])
                    self.observations = rD

            if self.type == 'local':
                self.staging = os.path.expanduser(rD['Operation']['staging']) + os.sep
                self.ingestion = os.path.expanduser(rD['Operation']['ingestion']) + os.sep
                self.wait = eval(rD['Operation']['wait'])
                self.daysBackMin = eval(rD['Operation']['daysBackMin'])
                self.daysBackMax = eval(rD['Operation']['daysBackMax'])
                self.DBfilename = rD['Operation']['DBfilename']	
                self.log = self.staging + os.sep + \
                    'log' + os.sep + \
                    DateStructure(datetime.datetime.now()) + os.sep
                self.db  = self.staging + os.sep + 'db'  + os.sep

def Directories(info,rootDate):
    """Go through all the nicknames and dates and create subdirectories"""
    dirs = []
    for daysBack in range(info.daysBackMin,info.daysBackMax):
        dt = rootDate - datetime.timedelta(days=daysBack)
        dirs.append( DirectoriesForAllNicknames(info,dt) )
    return dirs

def DirectoriesForAllNicknames(info,dt):
    """Go through all the nicknames and create subdirectories"""
    dirs = []
    nicknames = info.observations.keys()
    print(nicknames)
    for nickname in nicknames:
        dirs.append(DirectoriesForAllMeasurements(nickname,info,dt))
    return dirs

def DirectoriesForAllMeasurements(nickname,info,dt):
    """go through all the measurements for a nickname and create a subdirectory"""
    dirs = []
    print info.observations[nickname]
    for measurement in info.observations[nickname]['measurements']:
        dirs.append(Directory(measurement,nickname,dt))
    return dirs
    
def Directory(measurement,nickname,dt):
    """creates the storage directory structure"""
    date = DateStructure(dt)
    return nickname + os.sep + date + os.sep + measurement

def DateStructure(dt):
    """ formats the date as a directory structure"""
    if os.name == 'posix':
        return dt.strftime('%Y/%m/%d')
    if os.name == 'nt':
        return dt.strftime('%Y\%m\%d')

# createTimeStamp
def CreateTimeStamp():
    """ Creates a time-stamp to be used by all log files. """
    return now.strftime('%Y%m%d_%H%M%S')

def DefineStaging(d,info):
    staging = info.staging + 'jp2' + os.sep + d + os.sep
    return staging

def DefineIngestion(d,info):
    ingestion = info.ingestion + 'jp2' + os.sep + d + os.sep
    return ingestion

def DefineQuarantine(d,local):
    stagingRoot = os.path.expanduser(local['Operation']['staging'])
    timestamp, nowDirectory, now = CreateTimeStamp(string=False)
    quarantine = stagingRoot + 'quarantine' + os.sep + nowDirectory + os.sep
    return quarantine

def DefineRemote(d,repository):
    locationRoot = repository['Remote']['location']
    location = locationRoot + d
    return location

def CreateLocalSubdirectories(d,info):
    staging = DefineStaging(d,info)
    if not os.path.exists(staging):
        os.makedirs(staging)

    ingestion = DefineIngestion(d,info)
    if not os.path.exists(ingestion):
        os.makedirs(ingestion)

    if not os.path.exists(info.log):
        os.makedirs(info.log)
    return staging,ingestion

def DefineStderr(info,timeStampString):
    if not os.path.exists(info.log):
        os.makedirs(info.log)
    errFilename = timeStampString + '.stderr.log'
    return errFilename

def DefineStdout(info,timeStampString):
    if not os.path.exists(info.log):
        os.makedirs(info.log)
    stdFilename = timeStampString + '.stdout.log'
    return stdFilename
    
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
        # dictionary of all the nicknames indexed by observatory, instrument, detector
        nicknameDict = {'SDO':{'AIA':{'AIA':'AIA'},\
                                   'HMI':{'HMI':'HMI'}},\
                            'STEREO-A':{'SECCHI':\
                                            {'EUVI':'EUVI-A','COR1':'COR1-A','COR2':'COR2-A'}},\
                            'STEREO-B':{'SECCHI':\
                                            {'EUVI':'EUVI-B','COR1':'COR1-B','COR2':'COR2-B'}},\
                            'SOHO':{'LASCO':{'C2':'LASCO-C2','C3':'LASCO-C3'},\
                                        'EIT':{'EIT':'EIT'},\
                                        'MDI':{'MDI':'MDI'}}}
        withoutExtension = value[:-4]
        components = withoutExtension.split('__')
        allParts = [components.split('_', 1) for v in components if '_' in v]

        # date
        dateParts = allParts[0]
        self.year = eval(dateParts[0])
        self.month = eval(dateParts[1])
        self.day = eval(dateParts[2])
        # time
        timeParts = allParts[1]
        self.hours = eval(timeParts[0])
        self.minutes = eval(timeParts[1])
        self.seconds = eval(timeParts[2])
        self.milliseconds = eval(timeParts[3])
        # datetime object
        self.datetime = datetime.datetime(self.year,self.month,self.day,\
                                              self.hours,self.minutes,self.seconds,\
                                              1000*self.milliseconds)
        # observation details
        obsParts = allParts[2]
        self.observatory = obsParts[0]
        self.instrument = obsParts[1]
        self.detector = obsParts[2]
        self.measurement = obsParts[3]
        self.nickname = nickname[self.observatory][self.instrument][self.detector]
                                            

    def getNickname(self):
        return self.nickname

    def getYear(self):
        return self.year

    def getMonth(self):
        return self.month

    def getDay(self):
        return self.day

    def getHour(self):
        return self.hours

    def getMinute(self):
        return self.minutes

    def getSecond(self):
        return self.seconds

    def getObservatory(self):
        return self.observatory

    def getInstrument(self):
        return self.instrument

    def getDetector(self):
        return self.detector

    def getMeasurement(self):
        return self.measurement

    def getDateTime(self):
        return self.datetime


def Get(info,directories):
    # Open the standard error file
    timeStampString = CreateTimeStamp()
    errFilename = DefineStderr(info,timeStampString)
    outFilename = DefineStdout(info,timeStampString)

    global stderr,stdout
    stderr = open(info.log + errFilename,'a')
    stdout = open(info.log + outFilename,'a')

    # flatten the directories
    flatDirectories = [item for sublist in directories for item in sublist]
    # acquire data from the repository
    for d in flatDirectories:
        staging, ingestion = CreateLocalSubdirectories(d,local)
        remoteLocation = StageDataFromRepository(d,local,repository)
        fileList = ListFilesInStagingDirectory(staging)

        # at least one file found in the staging directory
        if len(fileList) > 0:
            #alreadyInDB = hvdb.query()
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
