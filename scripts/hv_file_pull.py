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
Reads a setup file, downloads files, and populates an SQLite
database with the entries.
The SQLite database is populated with the following entries
filename text = the filename of the file downloaded
nickname text = nickname of the instrument from which the file came
measurement text = measurement of the instrument
observationTimeStamp text (Python datetime timestamp) = observation time stamp in UTC
downloadTimeStart text (Python datetime timestamp) = when the download started in UTC
downloadTimeEnd text (Python datetime timestamp) = when the download ended in UTC
logFileName text = name of the wget log file
isFileGood int = is the file good (1) or bad (0)
fileProblem int = identified problems with the quarantined file; 0 if there are no problems
"""
from urlparse import urlsplit
from sgmllib import SGMLParser
import shutil, urllib2, urllib, os, time, sys, calendar, sqlite3, datetime

# URLLister
class URLLister(SGMLParser):
        def reset(self):
                SGMLParser.reset(self)
                self.urls = []

        def start_a(self, attrs):
                href = [v for k, v in attrs if k=='href']
                if href:
                        self.urls.extend(href)

# Begins with http://
def beginsWithHTTP(s):
	if s[0:7] == 'http://':
		answer = True
	else:
		answer = False
	return answer

# Do the quarantine
def hvDoQuarantine(quarantine,location,downloaded,staged):
	quarantined = hvCreateSubdir(quarantine + location,verbose = True) + downloaded
	jprint('Quarantining file  = '+ staged)
	shutil.move(staged, quarantined)
	return staged

# Get a list of files at the passed location

def hvGetFilesAtLocation(location):
	"""get a list of files at a given location, either from a webpage or from a directory somewhere"""
	if beginsWithHTTP(location):
		usock = urllib.urlopen(location)
		parser = URLLister()
		parser.feed(usock.read())
		usock.close()
		parser.close()
		files = parser.urls
		fileLocationExtension = '.newfiles.txt'
	else:
		files = os.listdir(location)
		fileLocationExtension = '.fromstaging.newfiles.txt'
	return files, fileLocationExtension

# isFileGood
def isFileGood(fullPathAndFilename,minimumFileSize,endsWith=''):
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
def change2hv(z):
	""" Changes the file permissions, and ownership from a local user to the helioviewer identity """
        os.system('chmod -R 775 ' + z)
	#if localUser != '':
	#	os.system('chown -R '+localUser+':helioviewer ' + z)

# hvCreateSubdir
def hvCreateSubdir(x,out=True, verbose=False):
	"""Create a helioviewer project compliant subdirectory."""
	if not os.path.isdir(x):
		try:
			os.makedirs(x)
			change2hv(x)
			if verbose:
				time.sleep(0)
				#jprint('Created '+x)
		except Exception, error:
			if verbose:
				jprint('Error found in hvCreateSubdir; error: '+str(error))
	else:
		time.sleep(0)
		#jprint('Directory already exists = '+x)
	return x

# hvSubdir
def hvSubdir(measurement,yyyy,mm,dd):
	"""Return the directory structure for helioviewer JPEG2000 files."""
	# New Style
	return [yyyy + '/', yyyy+'/'+mm+'/', yyyy+'/'+mm+'/'+dd+'/', yyyy+'/'+mm+'/'+dd+'/' + measurement + '/']
	# Old Style
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

# hvParseJP2FilenameToString
def hvParseJP2FilenameToString(filename):
	""" Parse a Helioviewer JP2 filename into its component parts """
	z0 = filename.split('.')
	z1 = z0[0].split('__')
	D = z1[0].split('_')
	T = z1[1].split('_')
	obs = z1[2].split('_')
	# return (int(D[0]),int(D[1]),int(D[2]),int(T[0]),int(T[1]),int(T[2]),int(T[3]),obs[0],obs[1],obs[2],obs[3])
	return {'date':[D[0],D[1],D[2]], 'time':[T[0],T[1],T[2],T[3]], 'observation':obs}

# hvJP2FilenameToTimeInSeconds
def hvJP2FilenameToTimeInSeconds(filename):
	""" Convert a JP2 file name into a time in seconds after epoch."""
	p = hvParseJP2Filename(filename)
	t = (p['date'][0],p['date'][1],p['date'][2],p['time'][0],p['time'][1],p['time'][2])
	return calendar.timegm(t)

# hvJP2FilenameToTimeStamp
def hvJP2FilenameToTimeStamp(filename):
	""" Convert a JP2 file name to a timestamp."""
	p = hvParseJP2FilenameToString(filename)
	milli = p['time'][3]
	if len(milli) == 1:
		milli = milli + '50'
	else:
		if len(milli) == 2:
			milli = milli + '5'
	return p['date'][0]+'-'+p['date'][1]+'-'+p['date'][2]+' '+p['time'][0]+':'+p['time'][1]+':'+p['time'][2]+'.'+ milli

# hvCheckForNewFiles
def hvCheckForNewFiles(urls,List):
	""" Compare one list to another """
	newList = ['']
	newFiles = False
	newFilesCount = 0
	for url in urls:
		if url.endswith('.jp2'):
			if not (url,) in List:
			#if not url + '\n' in List:
				newFiles = True
				newList.extend(url + '\n')
				newFilesCount = newFilesCount + 1
	if newFilesCount > 0:
		jprint('Number of new files found at location = ' + str(newFilesCount))
	else:
		jprint('No new files found at location.')
	return newFiles,newFilesCount,newList
			
# GetMeasurement
def GetMeasurement(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,timeStamp,minJP2SizeInBytes,dbName):
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
        quarantine = hvCreateSubdir(staging_root + 'quarantine/'+ nickname + '/',verbose = True)

	# Database: create the database subdirectory
	dbloc = hvCreateSubdir(staging_root + 'db/',verbose = True)

        # Ingestion: JP2s are moved to these directories and have their permissions changed.  The local user must be changed to helioviewer to allow access by the ingestion process.
        ingest_dir = hvCreateSubdir(ingest_root + 'jp2/', verbose = True)
        ingest_storage = hvCreateSubdir(ingest_dir + nickname + '/', verbose = True)

	# Database: Connect to the database
	try:
		if not os.path.isfile(dbloc + dbName):
			jprint('Creating database and connecting to it = ' + dbloc + dbName)
			conn = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
			c = conn.cursor()
			c.execute('''create table TableTest (filename text, nickname text, measurement text, observationTimeStamp timestamp, downloadTimeStart timestamp, downloadTimeEnd timestamp, logFileName text, isFileGood int, fileProblem int)''')
		else:
			jprint('Connecting to database = ' + dbloc + dbName)
			conn = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
			c = conn.cursor()
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

        # Logfile: Create the logfile filename
	jprint('Time stamp for this iteration = ' + timeStamp)
        logFileName = timeStamp + '.' + hvDateFilename(yyyy, mm, dd, nickname, measurement) + '.wget.log'    

	# Ingestion: create the ingestSubdir directory.  The local user must be changed to helioviewer to allow access by the ingestion process.
	for directory in hvss:
		ingestSubdir = hvCreateSubdir(ingest_storage + directory, verbose = True)

        # Calculate the remote directory
        remote_location = remote_root + nickname + '/' + hvss[-1]

	# Query start and end times
	queryTimeStart = yyyy + '-' + mm + '-' + dd + ' 00:00:00.000'
	queryTimeEnd   = yyyy + '-' + mm + '-' + dd + ' 23:59:59.999'

	# Now query the database: first compare the DB to the contents of the local staging directory, and then to the contents of the remote directory
	for i in range(0,2):
		# Database: Find the good files for this nickname, date and measurement.  Return the JP2 filenames
		try:
			query = (nickname,measurement,queryTimeStart,queryTimeEnd,1)
			c.execute('SELECT filename FROM TableTest WHERE nickname=? AND measurement=? and observationTimeStamp>? and observationTimeStamp<? AND isFileGood=?',query)
			#query = (nickname,measurement,1)
			#c.execute('SELECT filename FROM TableTest WHERE nickname=? AND measurement=? AND isFileGood=?',query)
			jp2list_good = c.fetchall()
		except Exception,error:
			jprint('Exception found querying database for the bad files from the database; error: '+str(error))

		# Database: Find the bad files for this nickname, date and measurement.  Return the JP2 filenames
		try:
			query = (nickname,measurement,queryTimeStart,queryTimeEnd,0)
			c.execute('SELECT filename FROM TableTest WHERE nickname=? AND measurement=? and observationTimeStamp>? and observationTimeStamp<? AND isFileGood=?',query)
			jp2list_bad = c.fetchall()
		except Exception,error:
			jprint('Exception found querying database for the bad files from the database; error: '+str(error))

		# First check the staging subdirectory for any files that were not transferred succesfully
		# Then check the remote location to find any new files there.
		if i == 0:
			fileLocation = stagingSubdir
		else:
			fileLocation = remote_location
		try:
			jprint('Querying file location = '+fileLocation)
			inLocation, fileLocationExtension = hvGetFilesAtLocation(fileLocation)
			newFiles, newFilesCount, newList = hvCheckForNewFiles(inLocation,jp2list_good)
			if newFiles:
				newFileListName = timeStamp + '.' + hvDateFilename(yyyy, mm, dd, nickname, measurement) + fileLocationExtension
				newFileListFullPath = logSubdir + newFileListName
				jprint('Writing new file list to ' + newFileListFullPath)
				f = open(newFileListFullPath,'w')
				f.writelines(newList)
				f.close()

				# Download the new files
				# When the download started
				downloadTimeStart = datetime.datetime.utcnow()
				jprint('Acquiring new files.')
				if beginsWithHTTP(fileLocation):
					localLog = ' -a ' + logSubdir + logFileName + ' '
					localInputFile = ' -i ' + logSubdir + newFileListName + ' '
					localDir = ' -P'+stagingSubdir + ' '
					remoteBaseURL = '-B ' + remote_location + ' '
					command = 'wget -r -l1 -nd --no-parent -A.jp2 ' + localLog + localInputFile + localDir + remoteBaseURL
					try:
						os.system(command)
					except Exception,error:
						jprint('Exception caught at executing wget command; error: '+str(error))
				else:
					files_found = os.listdir(fileLocation)

				# When the download time ends
				downloadTimeEnd = datetime.datetime.utcnow()

				# Get the filenames
				f = open(newFileListFullPath,'r')
				newListJP2 = f.readlines()
				f.close()
				#
				# Go through each file and ingest it
				#
				for DL in newListJP2:
					downloaded = DL[:-1]
					# full file paths
					staged = stagingSubdir + downloaded
					ingested = ingestSubdir + downloaded
					
					# return the analysis on each file
					isFileGoodDB, fileProblem = isFileGood(staged,  minJP2SizeInBytes, endsWith = '.jp2')
					
					# Observation time stamp
					observationTimeStamp = hvJP2FilenameToTimeStamp(downloaded)

					# Is the staged file good?
					if not isFileGoodDB:
						# Quarantine the staged file and update the database
						info = hvDoQuarantine(quarantine,hvss[-1],downloaded,staged)
						if (downloaded,) in jp2list_bad:
							# File is already in the DB as bad: update the details
							jprint('Quarantined file: updating database entry for file = ' + downloaded)
							ttt = (downloadTimeStart,downloadTimeEnd,logFileName,downloaded)
							c.execute('UPDATE TableTest SET downloadTimeStart=?,downloadTimeEnd=?,logFileName=? WHERE filename=?',ttt)
							conn.commit()
						else:
							# New bad file: enter it into the DB
							jprint('Quarantined file: creating database entry for file = ' + downloaded)
							ttt = (downloaded,nickname,measurement,observationTimeStamp,downloadTimeStart,downloadTimeEnd,newFileListName,0,fileProblem)
							c.execute('INSERT INTO TableTest VALUES (?,?,?,?,?,?,?,?,?)',ttt)
							conn.commit()
					else:
						# file is good - move it to the ingestion directory
						change2hv(staged)
						shutil.move(staged,ingested)
						isFileGoodDB, fileProblem = isFileGood(ingested,  minJP2SizeInBytes, endsWith = '.jp2')
						# Is the ingested file good?
						if not isFileGoodDB:
							# Quarantine the ingested file and update the database
							info = hvDoQuarantine(quarantine,hvss[-1],downloaded,ingested)
							if (downloaded,) in jp2list_bad:
							# File is already in the DB as bad: update the details
								jprint('Quarantined file: updating database entry for file = ' + downloaded)
								ttt = (downloadTimeStart,downloadTimeEnd,logFileName,downloaded)
								c.execute('UPDATE TableTest SET downloadTimeStart=?,downloadTimeEnd=?,logFileName=? WHERE filename=?',ttt)
								conn.commit()
							else:
							# New bad file: enter it into the DB
								jprint('Quarantined file: creating database entry for file = ' + downloaded)
								ttt = (downloaded,nickname,measurement,observationTimeStamp,downloadTimeStart,downloadTimeEnd,newFileListName,0,fileProblem)
								c.execute('INSERT INTO TableTest VALUES (?,?,?,?,?,?,?,?,?)',ttt)
								conn.commit()
						else:
							jprint('Moved file '+ staged + ' to ' + ingested)
							# Update the database
							try:
								# if the downloaded file is in the bad list, a download has already been attempted
								# this means that there is an entry in the database that must be updated with the latest
								# attempted download time, and the latest log file that contained the filename, and the
								# fact the file is now a good one.
								# Fix the download end time to now: process has finished.
								if (downloaded,) in jp2list_bad:
									jprint('Ingested: updating the database entry for the file = '+ downloaded)
									ttt = (downloadTimeStart,downloadTimeEnd,logFileName,downloaded)
									c.execute('UPDATE TableTest SET isFileGood=1,downloadTimeStart=?,downloadTimeEnd=?,logFileName=? WHERE filename=?',ttt)
									conn.commit()
								else:
									jprint('Ingested: creating a database entry for file = '+ downloaded)
									ttt = (downloaded,nickname,measurement,observationTimeStamp,downloadTimeStart,downloadTimeEnd,newFileListName,1,fileProblem)
									c.execute('INSERT INTO TableTest VALUES (?,?,?,?,?,?,?,?,?)',ttt)
									conn.commit()
							except Exception,error:
						       		jprint('Exception caught updating the new database; error: ' + str(error))
								# Test to see if the filename was entered in to the database correctly and print the results to screen
								ttt = (downloaded)
								c.execute('SELECT filename FROM TableTest where filename=?',ttt)
								print 'Exception updating database with a new file ',downloaded, c.fetchall(), len(c.fetchall())
			else:
				jprint('No new files found at ' + fileLocation)
				newFilesCount = 0
		except Exception,error:
			jprint('Exception caught at trying to read the file location: '+fileLocation+'; continuing with loop; error: '+str(error))
			newFilesCount = -1

	# Database: close the database
	c.close()
	return newFilesCount

# Get the JP2s
def GetJP2(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,minJP2SizeInBytes,beginTimeStamp, count = 0, redirect = False, daysBack = 0):
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
	currentFile.write('Acquisition script started at ' + beginTimeStamp +'.\n')
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
	jprint('Download script begun = ' + beginTimeStamp)
	jprint('Measurement = ' + measurement)
	jprint('Beginning remote location query number ' + str(count))
	jprint("Looking for files on this date = " + yyyy + mm + dd)
	jprint('Using options file '+ options_file)
	nfc = GetMeasurement(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,timeStamp,minJP2SizeInBytes,dbName)
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

def hvReadOptionsFile(optionsFiles):
    if len(optionsFiles) <= 2 :
        print 'Not enough options files given.  Ending.'
    else:
        # Options local and general for all data being ingested
        f = open(optionsFiles[1],'r')
        localOptions = f.readlines()
        f.close()
        options = {"stagingRoot":os.path.expanduser(localOptions[0][:-1]), "ingestRoot":os.path.expanduser(localOptions[1][:-1]), "monitorLoc":os.path.expanduser(localOptions[2][:-1]), "dbName": localOptions[3][:-1]}

        # Options specific to the data being ingested
        f = open(optionsFiles[2],'r')
        remoteOptions = f.readlines()
        f.close()

        dummy = options.setdefault("remote_root"      , remoteOptions[0][:-1])
        dummy = options.setdefault("startDate"        , remoteOptions[1][:-1].split('/'))
        dummy = options.setdefault("endDate"          , remoteOptions[2][:-1].split('/'))
        dummy = options.setdefault("nickname"         , remoteOptions[3][:-1])
        dummy = options.setdefault("measurements"     , remoteOptions[4][:-1].split(','))
        dummy = options.setdefault("minJP2SizeInBytes", int(remoteOptions[5][:-1]))
        dummy = options.setdefault("redirectTF"       , remoteOptions[6][:-1])
        dummy = options.setdefault("sleep"            , int(remoteOptions[7][:-1]))
        dummy = options.setdefault("daysBackMin"      , int(remoteOptions[8][:-1]))
        dummy = options.setdefault("daysBackMax"      , int(remoteOptions[9][:-1]))

        return options

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
beginTimeStamp = createTimeStamp()

options = hvReadOptionsFile(sys.argv)
options_file = sys.argv[1] + ' '+ sys.argv[2]

remote_root       = options["remote_root"]
staging_root      = options["stagingRoot"]
ingest_root       = options["ingestRoot"]
startDate         = options["startDate"]
endDate           = options["endDate"]
measurements      = options["measurements"]
nickname          = options["nickname"]
monitorLoc        = options["monitorLoc"]
minJP2SizeInBytes = options["minJP2SizeInBytes"]
redirectTF        = options["redirectTF"]
sleep             = options["sleep"]
daysBackMin       = options["daysBackMin"]
daysBackMax       = options["daysBackMax"]
dbName            = options["dbName"]

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
				nfc = GetJP2(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,minJP2SizeInBytes,beginTimeStamp,count = count,redirect = redirect,daysBack = daysBack)
				if nfc > 0:
					gotNewData = True
		if not gotNewData:
			jprint('Sleeping for '+str(sleep)+' seconds.')
			time.sleep(sleep)

else:
	getThisDay = time.mktime((int(startDate[0]),int(startDate[1]),int(startDate[2]),0, 0, 0, 0, 0, 0))
	finalDay = time.mktime((int(endDate[0]),int(endDate[1]),int(endDate[2]),0, 0, 0, 0, 0, 0))
	while getThisDay <= finalDay:
		yyyy = time.strftime('%Y',time.gmtime(getThisDay))
		mm = time.strftime('%m',time.gmtime(getThisDay))
		dd = time.strftime('%d',time.gmtime(getThisDay))
		for measurement in measurements:
			nfc = GetJP2(nickname,yyyy,mm,dd,measurement,remote_root,staging_root,ingest_root,monitorLoc,minJP2SizeInBytes,beginTimeStamp,count = 0,redirect = redirect)
		getThisDay = getThisDay + 24*60*60
