#
#
# Script cobbled together from
# 
# Dive Into Python 5.4
#
# Scrapes JP2 files from remote webspace and writes them to local subdirectories
# Based on hv_aia_pull2.py
#
# Requires: Python 2.5 or above
#
# TODO: better handling of spawned wget process through the subprocess module
# 
#
#
"""
Creates an SQLite database with entries in the following order
nickname text,
yyyy text,
mm text,
dd text,
hh text,
mmm text,
ss text,
milli text,
observationTime real,
measurement text,
downloadedTimeStamp text,
downloadedWhenTimeStart real,
downloadedWhenTimeEnd real,
downloadedFrom text,
downloadedFilename text,
goodfile 
"""
from urlparse import urlsplit
from sgmllib import SGMLParser
import shutil, urllib2, urllib, os, time, sys, calendar, sqlite3

# URLLister
class URLLister(SGMLParser):
        def reset(self):
                SGMLParser.reset(self)
                self.urls = []

        def start_a(self, attrs):
                href = [v for k, v in attrs if k=='href']
                if href:
                        self.urls.extend(href)

# isFileGood
def isFileGood(fullPathAndFilename,minimumFileSize,endsWith='', label = 'no label given'):
	""" Tests to see if a file meets the minimum requirements to be ingested into the database.
	An entry of -1 means that the test was not performed, 0 means failure, 1 means pass.
	"""
	answer ={"isFileGood":True,"fileExists":-1,"minimumFileSize":-1,"endsWith":-1,"label":label}

	# Does the file exist?
	if os.path.isfile(fullPathAndFilename):
		answer["fileExists"] = 1
		# test for file size
		s = os.stat(fullPathAndFilename)
		if s.st_size > minimumFileSize:
			answer["minimumFileSize"] = 1
		else:
			answer["minimumFileSize"] = 0
		
		# test that the file has the right extension
		if endswith != '':
			if fullPathAndFilename.endswith(endswith):
				answer["endsWith"] = 1
			else:
				answer["endsWith"] = 0
	else:
		answer["fileExists"] = 0

	# Has the file passed all the tests?
	isFileGood = True
	for i in answer.itervalues():
		if i == 0:
			isFileGood = False
	answer["isFileGood"] = isFileGood

	return answer


# createTimeStamp
def createTimeStamp():
	""" Creates a time-stamp to be used by all log files. """
	timeStamp = time.strftime('%Y%m%d_%H%M%S', time.localtime())
	return timeStamp

# jprint
def jprint(z):
	""" Prints out a message with a time stamp """
        print createTimeStamp() + ' : ' + z

# change2hv
def change2hv(z,localUser):
	""" Changes the file permissions, and ownership from a local user to the helioviewer identity """
        os.system('chmod -R 775 ' + z)
	if localUser != '':
		os.system('chown -R '+localUser+':helioviewer ' + z)

# hvCreateSubdir
def hvCreateSubdir(x, localUser='' ,out=True, verbose=False):
	"""Create a helioviewer project compliant subdirectory."""
	if not os.path.isdir(x):
		try:
			os.makedirs(x)
			change2hv(x,localUser)
			if verbose:
				jprint('Created '+x)
		except Exception, error:
			if verbose:
				jprint('Error found in hvCreateSubdir; error: '+str(error))
	else:
		jprint('Directory already exists = '+x)
	return x

# hvSubdir
def hvSubdir(measurement,yyyy,mm,dd):
	"""Return the directory structure for helioviewer JPEG2000 files."""
	return [yyyy + '/', yyyy+'/'+mm+'/', yyyy+'/'+mm+'/'+dd+'/', yyyy+'/'+mm+'/'+dd+'/' + measurement + '/']
	#return [measurement + '/', measurement + '/' + yyyy + '/', measurement + '/' + yyyy+'/'+mm+'/', measurement + '/' + yyyy+'/'+mm+'/'+dd+'/', measurement + '/' + yyyy+'/'+mm+'/'+dd+'/' ]

# hvDateFilename
def hvDateFilename(yyyy,mm,dd,nickname,measurement):
	"""Creates a filename from the date, nickname and measurement"""
	return yyyy + mm + dd + '__' + nickname + '__' + measurement

# hvParseJP2Filename
def hvParseJP2Filename(filename):
	""" Parse a Helioviewer JP2 filename into its component parts """
	z0 = filename.split('.')
	z1 = z0[0].split('__')
	D = z1[0].split('_')
	T = z1[1].split('_')
	obs = z1[2].split('_')
	# return (int(D[0]),int(D[1]),int(D[2]),int(T[0]),int(T[1]),int(T[2]),int(T[3]),obs[0],obs[1],obs[2],obs[3])
	return {'date':[int(D[0]),int(D[1]),int(D[2])], 'time':[int(T[0]),int(T[1]),int(T[2]),int(T[3])], 'observation':obs}

# hvJP2FilenameToTimeInSeconds
def hvJP2FilenameToTimeInSeconds(filename):
	""" Convert a JP2 file name into a time in seconds after epoch."""
	p = hvParseJP2Filename(filename)
	t = (p['date'][0],p['date'][1],p['date'][2],p['time'][0],p['time'][1],p['time'][2])
	return calendar.timegm(t)

# hvJP2FilenameToTimeInMilliseconds
def hvJP2FilenameToTimeInMilliseconds(filename):
	""" Convert a JP2 file name into a time in milliseconds after epoch."""
	seconds = hvJP2FilenameToTimeInSeconds(filename)
	p = hvParseJP2Filename(filename)
	return 1000.0*seconds + p['time'][3]

# hvCheckForNewFiles
def hvCheckForNewFiles(urls,List):
	""" Compare one list to another """
	newList = ['']
	newFiles = False
	newFilesCount = 0
	for url in urls:
		if url.endswith('.jp2'):
			if not url + '\n' in List:
				newFiles = True
				newList.extend(url + '\n')
				newFilesCount = newFilesCount + 1
	if newFilesCount > 0:
		jprint('Number of new files found at remote location = ' + str(newFilesCount))
	else:
		jprint('No new files found at remote location.')
	return newFiles,newFilesCount,newList
	
# check the remote location for files
def hvCheckRemoteLocation(location):
	"""Get a list of files at a given location. Can be used on files located on a remote webpage, or on a local file system.
	Default is to examine a remote webpage.
	"""
	if location.startswith('http://'):
		usock = urllib.urlopen(location)
		parser = URLLister()
		parser.feed(usock.read())
		usock.close()
		parser.close()
		output = parser.urls
	else:
		output = os.listdir(location)
	return output


# GetMeasurement
def GetMeasurement(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,timeStamp,minJP2SizeInBytes,localUser,dbName):
	""" Download JP2s from a remote website for a given device and measurement.
	nickname = device nickname
	yyyy = 4 digit year string
	mm = 2 digit month string
	dd = 2 digit day string
	measurement = the particular measurement we want to download
	remote_root = the location of the JP2 directory structure (http://)
	staging_root = files from remote location are originally copied here, and then transferred to the ingestion directory
	ingest_root = this directory holds the files to be ingested, and has all the correct permissions and ownerships set
	monitorLoc = the local website where monitoring information on the transfer process is stored
	timeStamp = the timeStamp associated with this particular query for data
	minJP2SizeInBytes = the minimum size of an acceptable JP2 file.  Anything smaller and the file is assumed to be bad, and the file is quarantined
	localUser = the name of the user who initiates the download.  This user must be in the helioviewer group.
	"""

	# Information for the user
	jprint('Remote root: as defined in options file')
        jprint('Local root: '+staging_root)
        jprint('Ingest root: '+ingest_root)

	#
	# Higher level storage for all dates and times
	#

        # Staging: Create the staging directory for the JP2s
        jp2_dir = hvCreateSubdir(staging_root + 'jp2/',verbose = True)
        staging_storage = hvCreateSubdir(jp2_dir + nickname + '/', verbose = True)

	# Quarantine: Creating the quarantine directory - bad JP2s go here
        quarantine = hvCreateSubdir(staging_root + 'quarantine/',verbose = True)

	# Database: create the database subdirectory
	dbloc = hvCreateSubdir(staging_root + 'db/',verbose = True)

        # Ingestion: JP2s are moved to these directories and have their permissions changed.  The local user must be changed to helioviewer to allow access by the ingestion process.
        ingest_dir = hvCreateSubdir(ingest_root + 'jp2/',localUser = localUser, verbose = True)
        ingest_storage = hvCreateSubdir(ingest_dir + nickname + '/',localUser = localUser, verbose = True)

	# Create a database if it is not already created
	try:
		jprint('Connecting to database = ' + dbloc + dbName)
		conn = sqlite3.connect(dbloc + dbName)
		c = conn.cursor()
		c.execute('''create table TableTest (jp2Filename text, yyyy int, mm int, dd int, nickname text, measurement text, isFileGood int)''')
	except Exception,error:
		jprint('Exception caught creating a new database file; error: '+str(error))

        # Logfile: The location of where the logfiles are stored
        logloc = hvCreateSubdir(staging_root + 'log/'+ nickname +'/',verbose=True)

	#
	# Lower level storage - specific to a particular date and measurement
	#

	# The helioviewer subdirectory structure
	hvss = hvSubdir(measurement,yyyy,mm,dd)

        # Staging: create the staging JP2 subdirectory required
	stagingSubdir = hvCreateSubdir(staging_storage + hvss[-1],verbose=True)

        # Logfile: create the logfile subdirectory for these data
        logSubdir = hvCreateSubdir(logloc + hvss[-1],verbose=True)

        # Quarantine: create the quarantine subdirectory for these data
        quarantineSubdir = hvCreateSubdir(quarantine + hvss[-1],verbose = True)

        # Logfile: Create the logfile filename
	jprint('Time stamp for this iteration = ' + timeStamp)
        logFileName = timeStamp + '.' + hvDateFilename(yyyy, mm, dd, nickname, measurement) + '.wget.log'    

	# Ingestion: create the ingestSubdir directory.  The local user must be changed to helioviewer to allow access by the ingestion process.
	for directory in hvss:
		ingestSubdir = hvCreateSubdir(ingest_storage + directory,localUser = localUser, verbose = True)

	#
	# All the necessary subdirectories have been created.  Now query the database 
	#

	# Database: Find the good files for this nickname, date and measurement currently in the database.  Return the JP2 filenames
        # table TableTest (jp2Filename text, yyyy int, mm int, dd int, nickname text, measurement text, isFileGood int)
	try:
		query = (nickname,yyyy,mm,dd,measurement,1)
		c.execute('select jp2Filename from TableTest where yyyy=? and mm=? and dd=? and nickname=? and measurement=? and isFileGood =?',query)
		jp2list_good = c.fetchall()
	except Exception,error:
		jprint('Exception found querying database for the good files from the database; error: '+str(error))

	# Database: Find the bad files for this nickname, date and measurement.  Return the JP2 filenames
	try:
		query = (nickname,yyyy,mm,dd,measurement,0)
		c.execute('select jp2Filename from TableTest where yyyy=? and mm=? and dd=? and nickname=? and measurement=? and isFileGood =?',query)
		jp2list_bad = c.fetchall()
	except Exception,error:
		jprint('Exception found querying database for the bad files from the database; error: '+str(error))


        # Calculate the remote directory
        remote_location = remote_root + nickname + '/' + hvss[-1]
	jprint('Querying remote location ' + remote_location)

        # Open the remote location and get the file list
	try:
		potentialJP2Files = hvCheckRemoteLocation(remote_location)

	        # Check which files are new at the remote location
		newFiles, newFilesCount, newList = hvCheckForNewFiles(potentialJP2Files,jp2list_good)

		# If there are some new files, download them and check them.
	        if newFiles:
			# Save the filenames we are attempting to download
			newFileListName = timeStamp + '.' + hvDateFilename(yyyy, mm, dd, nickname, measurement) + '.newfiles.txt'
			newFileListFullPath = logSubdir + newFileListName
	                jprint('Writing new file list to ' + newFileListFullPath)
	                f = open(newFileListFullPath,'w')
	                f.writelines(newList)
	                f.close()

	                # Download the new files
			startOfFileAcquisitionTime = calendar.timegm(time.gmtime())
	                jprint('Downloading new files.')
			# download from a website
			if remoteBaseURL.startswith('http://'):
				localLog = ' -a ' + logSubdir + logFileName + ' '
				localInputFile = ' -i ' + logSubdir + newFileListName + ' '
				localDir = ' -P'+stagingSubdir + ' '
				remoteBaseURL = '-B ' + remote_location + ' '
				command = 'wget -r -l1 -nd --no-parent -A.jp2 ' + localLog + localInputFile + localDir + remoteBaseURL
				try:
					os.system(command)
				except Exception,error:
					jprint('Exception caught at executing wget command; error: '+str(error))
			# copy from a local file system
			else:
				try:
					f = open(newFileListFullPath,'r')
					localFiles = f.readlines()
					f.close()
					for fName in localFiles:
						shutil.copy(remote_location + fName, stagingSubdir + fName)
				except Exception,error:
					jprint('Exception caught copying files from local file system; error: '+str(error))
			
			# Look at the downloaded files and see if they pass all the 'goodness' tests
			# 
			for downloaded in newFiles:
				
				# full file paths
				staged = stagingSubdir + downloaded
				quarantined = quarantineSubdir + downloaded
				ingested = ingestSubdir + downloaded

				# return the analysis on each file
				inStaging = isFileGood(staged,  minJP2SizeInByte, endswith = '.jp2', label ='staging')

				# Is the staged file good or bad?
				# table TableTest (jp2Filename text, yyyy int, mm int, dd int, nickname text, measurement text, isFileGood int)
				if not inStaging['isFileGood']:
					# the file is bad
					jprint('Quarantining file  = '+ staged)
					shutil.move(staged, quarantined)
					isFileGoodDB = 0
					confirmedIngestedTime = '-1.0'
				else:
					# the file is good; first move it to the ingestion directory
					change2hv(staged,localUser)
					shutil.move(staged,ingested)
					inIngest = isFileGood(ingested,  minJP2SizeInByte, endswith = '.jp2', label = 'ingestion')
					# Is the ingested file good?
					if not inIngest['isFileGood']:
						# the ingested file is bad
						jprint('Quarantining file  = '+ ingested)
						shutil.move(ingested, quarantined)
						isFileGoodDB = 0
						confirmedIngestedTime = '-1.0'
					else:
						# update the database with good files
						confirmedIngestedTime = calendar.timegm(time.gmtime())
						jprint('Moved file '+ staged + ' to ' + ingested)
						isFileGoodDB = 1
				# Update the database
				try:
					# Update the table of 
					ttt = (downloaded,yyyy,mm,dd,nickname,measurement,isFileGoodDB)
					c.execute('insert into TableTest values (?,?,?,?,?,?,?)',ttt)
					conn.commit()
					# Update the table that contains details on how precisely the bad file is bad
					# database table
					# failedWhere = 'staging' or 'ingestion'
					#
					# create table quarantineReasons (filename text, failedWhere text, fileExists int, minimumFileSize int, endsWith int
					# sss = (downloaded, fileTest['label'], fileTest['fileExists'], fileTest['minimumFileSize'], fileTest['endsWith']
					# c.execute('insert into quarantineReasons values (?,?,?,?,?)',sss)
					# conn.commit()
				except Exception,error:
					jprint('Exception caught trying to update the database; error = '+ str(error))

		else:
                	jprint('No new files found at ' + remote_location)
	except Exception,error:
		jprint('Exception caught at trying to read the remote location; error: '+str(error))
		jprint('Remote location: '+remote_location+'.  Continuing with loop.')
	        newFilesCount = -1

	# Database NEW: Close the database
	c.close()
	return newFilesCount

# Get the JP2s
def GetJP2(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,minJP2SizeInBytes,localUser,count = 0, redirect = False, daysBack = 0):
	t1 = time.time()
	timeStamp = createTimeStamp()
	# Standard output + error log file names
	stdoutFileName = timeStamp + '.' + hvDateFilename(yyyy, mm, dd, nickname, measurement) + '.stdout.log'
	stderrFileName = timeStamp + '.' + hvDateFilename(yyyy, mm, dd, nickname, measurement) + '.stderr.log'
	stdoutLatestFileName = 'latest.' + str(daysBack) + '__'+nickname+'__' + measurement + '.stdout.log'
	stderrLatestFileName = 'latest.' + str(daysBack) + '__'+nickname+'__' + measurement + '.stderr.log'

	# log subdirectory
	logSubdir = staging_root + 'log/' + nickname + '/' + hvSubdir(measurement,yyyy,mm,dd)[3] + '/'
	hvCreateSubdir(logSubdir)

	# Write a current file to web-space so you know what the script is trying to do right now.
	currentFile = open(monitorLoc + 'current.log','w')
	currentFile.write('Measurement = ' + measurement +'.\n')
	currentFile.write('Beginning remote location query number ' + str(count)+ '.\n')
	currentFile.write("Looking for files on this date = " + yyyy + mm + dd+ '.\n')
	currentFile.write('Using options file '+ options_file+ '.\n')
	currentFile.write('Time stamp = '+ timeStamp + '\n')
	currentFile.close()

	# Redirect stdout
	if redirect:
		saveout = sys.stdout
		fsock = open(logSubdir + stdoutFileName, 'w')
		sys.stdout = fsock
		saveerr = sys.stderr
		ferr = open(logSubdir + stderrFileName, 'w')
		sys.stderr = ferr

	# Get the data
	jprint(' ')
	jprint(' ')
	jprint('Measurement = ' + measurement)
	jprint('Beginning remote location query number ' + str(count))
	jprint("Looking for files on this date = " + yyyy + mm + dd)
	jprint('Using options file '+ options_file)
	nfc = GetMeasurement(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,timeStamp,minJP2SizeInBytes,localUser,dbName)
	t2 = time.time()
	jprint('Time taken in seconds =' + str(t2 - t1))
	if nfc > 0 :
		jprint('Average time taken in seconds = ' + str( (t2-t1)/nfc ) )
		
	# Put the stdout/stderr back
	if redirect:
		sys.stdout = saveout
		fsock.close()
		sys.stderr = saveerr
		ferr.close()

	# Copy the most recent stdout/stderr file to some webspace.
		shutil.copy(logSubdir + stdoutFileName, monitorLoc + stdoutLatestFileName)
		shutil.copy(logSubdir + stderrFileName, monitorLoc + stderrLatestFileName)

	return nfc



#
# Script must be called using an options file that defines the root of the
# remote directory and the root of the local directory
#
'''
Parse the options
[0] = remote http location
[1] = local subdirectory where the files are first saved to (staging)
[2] = local subdirectory where the JP2 files with the correct permissions are put for ingestion
[3] = start date
[4] = end date
[5] = specific measurements to download - must have the same measurement values as defined in the instrument Helioviewer setup file - see JP2Gen wiki notes. Comma separated list.
[6] = nickname of the device
[7] = webspace
[8] = minimum acceptable file size in bytes.  Files smaller than this are considered corrupted
[9] = redirect stout and stderr output to file (True)
[10] = number of seconds to pause the data download for if no daya was downloaded the last time
[11] = minimum number of days back from the present date to consider
[12] = maximum number of days back from the present date to consider (note that the range command used to implement this requires a minimum value of n to go back n-1 days)
[13] = name of the local User who is downloading the files.  This user must be in the "helioviewer" group.
[14] = name of the SQLite database to connect to
'''

if len(sys.argv) <= 1:
        jprint('No options file given.  Ending.')
else:
        options_file = sys.argv[1]
        try:
                f = open(options_file,'r')
                options = f.readlines()
        finally:
                f.close()

        remote_root = options[0][:-1]
        staging_root = options[1][:-1]
        ingest_root = options[2][:-1]
	startDate = (options[3][:-1]).split('/')
	endDate = (options[4][:-1]).split('/')
	measurements = options[5][:-1].split(',')
	nickname = options[6][:-1]
	monitorLoc = options[7][:-1]
	minJP2SizeInBytes = int(options[8][:-1])
	redirectTF = options[9][:-1]
	sleep = int(options[10][:-1])
	daysBackMin = int(options[11][:-1])
	daysBackMax = int(options[12][:-1])
	localUser = options[13][:-1]

	# Re-direct stdout to a logfile?
	if redirectTF == 'True':
		redirect = True
	else:
		redirect = False


	# Days back defaults
	if daysBackMin <= -1:
		daysBackMin = 0
	if daysBackMax <= -1:
		daysBackMax = 2

	# Main program
	if ( (startDate[0] =='-1') or (startDate[1]=='-1') or (startDate[2]=='-1') or (endDate[0]=='-1') or (endDate[1]=='-1') or (endDate[2]=='-1') ):
		# repeat starts here
		count = 0
		while 1:
			count = count + 1
			gotNewData = False
			for daysBack in range(daysBackMin,daysBackMax):

				# get  date in UT
				Y = calendar.timegm(time.gmtime()) - daysBack*24*60*60
				yyyy = time.strftime('%Y',time.gmtime(Y))
				mm = time.strftime('%m',time.gmtime(Y))
				dd = time.strftime('%d',time.gmtime(Y))

				# Go through each measurement
				for measurement in measurements:
					nfc = GetJP2(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,minJP2SizeInBytes,localUser,count = count,redirect = redirect,daysBack = daysBack)
					if nfc > 0:
						gotNewData = True
			if not gotNewData:
				time.sleep(sleep)

	else:
		getThisDay = time.mktime((int(startDate[0]),int(startDate[1]),int(startDate[2]),0, 0, 0, 0, 0, 0))
		finalDay = time.mktime((int(endDate[0]),int(endDate[1]),int(endDate[2]),0, 0, 0, 0, 0, 0))
		while getThisDay <= finalDay:
			yyyy = time.strftime('%Y',time.gmtime(getThisDay))
			mm = time.strftime('%m',time.gmtime(getThisDay))
			dd = time.strftime('%d',time.gmtime(getThisDay))
			for measurement in measurements:
				nfc = GetJP2(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,minJP2SizeInBytes,localUser,count = 0,redirect = redirect)
			getThisDay = getThisDay + 24*60*60
