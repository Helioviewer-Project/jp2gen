import ConfigParser,datetime,os,subprocess,sys,itertools

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
                self.staging = os.path.expanduser(rD['Operation']['staging'])
                self.ingestion = os.path.expanduser(rD['Operation']['ingestion'])
                self.wait = eval(rD['Operation']['wait'])
                self.daysBackMin = eval(rD['Operation']['daysBackMin'])
                self.daysBackMax = eval(rD['Operation']['daysBackMax'])
                self.DBfilename = rD['Operation']['DBfilename']	
                self.log = self.staging + \
                    'log' + os.sep + \
                    DateStructure(datetime.datetime.now()) + os.sep
                self.db  = self.staging + os.sep + 'db'  + os.sep
                self.quarantine  = self.staging + os.sep + 'quarantine'  + os.sep

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
    for nickname in nicknames:
        dirs.append(DirectoriesForAllMeasurements(nickname,info,dt))
    return dirs

def DirectoriesForAllMeasurements(nickname,info,dt):
    """go through all the measurements for a nickname and create a subdirectory"""
    dirs = []
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
    return datetime.datetime.now().strftime('%Y%m%d_%H%M%S')

def DefineStaging(directory,info):
    return info.staging + 'jp2' + os.sep + directory + os.sep

def DefineIngestion(directory,info):
    return info.ingestion + 'jp2' + os.sep + directory + os.sep

def DefineQuarantine(directory,info):
    return info.quarantine + directory + os.sep

def DefineRemote(directory,info):
    return info.location + directory  + os.sep

def CreateLocalSubdirectories(directory,info):
    staging = DefineStaging(directory,info)
    if not os.path.exists(staging):
        os.makedirs(staging)

    ingestion = DefineIngestion(directory,info)
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
    
def StageDataFromRepository(directory,info):
    remoteLocation =  DefineRemote(directory,info)
    staging = DefineStaging(directory,info)

    localDir = ' -P'+staging+ ' '
    command = 'wget'
    argument = ' -v -r -l1 -nd --no-parent --timestamping -A.jp2 -R.html '+localDir+remoteLocation

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

class JP2transport:
    def __init__(self,value1,value2,value3):
        self.begin = value1
        self.end = value2
        self.fileProblem = value3

def ClassifyNewFiles(candidates,info):
    good = []
    bad =  []
    for candidate in candidates:
        isFileGoodDB, fileProblem = isFileGood(candidate,info.minimumFileSize)
        JP2 = JP2(candidate)
        if JP2.isFileGoodDB:
            transport = JP2transport(candidate,info.ingestion + JP2.subdirectory,fileProblem)
            good.append(transport)
        else:
            transport = JP2transport(candidate,info.quarantine + JP2.subdirectory,fileProblem)
            bad.append(transport)

def QuarantineAndUpdateDB(badFiles):

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

        # where the file gets stored
        self.subdirectory = Directory(self.measurement,self.nickname,self.datetime.date())

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

    # Create a database if need be

    # flatten the directories
    # flatDirectories = [item for sublist in directories for item in sublist]
    # from http://stackoverflow.com/questions/406121/flattening-a-shallow-list-in-python
    flatDirectories = list(itertools.chain(*list(itertools.chain(*directories))))
    # acquire data from the repository
    for directory in flatDirectories:
        # create the staging and ingestion directories
        staging, ingestion = CreateLocalSubdirectories(directory,info)

        # stage new data from the repository
        StageDataFromRepository(directory,info)

        # get a list of files in the staging directory
        fileList = ListFilesInStagingDirectory(staging)

        # at least one file found in the staging directory
        if len(fileList) > 0:
            good, bad = ClassifyNewFiles(fileList,info)

            # at least one bad file
            if len(bad) > 0:
                # quarantine the bad files and update the database
                MoveBadFilesToQuarantineAndUpdateDB(bad)

            # at least one goodfile
            if len(good) > 0:
                CopyNewFilesFromStagingIntoIngestionAndUpdateDB(good)
            else:
                stdout.write(CreateTimeStamp() + ': no new files comparing database entries to '+remoteLocation)
        else:
            stdout.write(CreateTimeStamp() + ': no files found at '+remoteLocation)

    stderr.close()
    stdout.close()
