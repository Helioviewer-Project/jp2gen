#
#
# Script cobbled together from
# 
# Dive Into Python 5.4
#
# Scrapes all the JP2 files from LMSAL webspace and writes them to local subdirectories
#
# TODO: better handling of spawned wget process through the subprocess module
# 
#
#

from os.path import basename
from urlparse import urlsplit
import shutil
import urllib2
import urllib
from sgmllib import SGMLParser
import os, time, sys
import calendar

class URLLister(SGMLParser):
        def reset(self):
                SGMLParser.reset(self)
                self.urls = []

        def start_a(self, attrs):
                href = [v for k, v in attrs if k=='href']
                if href:
                        self.urls.extend(href)


# Create a time-stamp to be used by all log files
def createTimeStamp():
	TSyyyy = time.strftime('%Y',time.localtime())
	TSmm = time.strftime('%m',time.localtime())
	TSdd = time.strftime('%d',time.localtime())
	TShh = time.strftime('%H',time.localtime())
	TSmmm = time.strftime('%M',time.localtime())
	TSss =  time.strftime('%S',time.localtime())
	timeStamp = TSyyyy + TSmm + TSdd + '_' + TShh + TSmmm + TSss
	return timeStamp

# Forward compatibility with Python 3
def jprint(z):
        print createTimeStamp() + ' : ' + z

# Element has the correct permissions and ownership
def change2hv(z):
        os.system('chmod -R 775 ' + z)
        os.system('chown -R ireland:helioviewer ' + z)

# Create a HV - compliant subdirectory
def hvCreateSubdir(x,out=True):
        try:
                os.makedirs(x)
                change2hv(x)
        except:
		if out:
			jprint('Directory already exists: ' + x)

# Directory Structure
def hvSubdir(measurement,yyyy,mm,dd):
	return [ yyyy+'/', yyyy+'/'+mm+'/', yyyy+'/'+mm+'/'+dd+'/', yyyy+'/'+mm+'/'+dd+'/' + measurement + '/']

# Define the log directory
def hvLogSubdir(nickname,measurement,yyyy,mm,dd):
	a = hvSubdir(measurement,yyyy,mm,dd)
	return 'log/' + nickname + '/' + a[3]

# Create the log directory
def hvCreateLogSubdir(root,nickname,measurement,yyyy,mm,dd):
	a = hvLogSubdir(nickname,measurement,yyyy,mm,dd)
	hvCreateSubdir(root + a,out = False)
	return root + a


# yyyy - four digit year
# mm - two digit month
# dd - two digit day
# remote_root - remote location of the AIA files
# local_root - files from remote location are originally copied here, and have their permissions changes here
# ingest_root - the directory where the files with the correct permissions end up

def GetAIAWave(nickname,yyyy,mm,dd,wave,remote_root,local_root,ingest_root,monitorLoc,timeStamp,minJP2SizeInBytes):
        #jprint('Remote root: '+remote_root)
	jprint('Remote root: as defined in options file')
        jprint('Local root: '+local_root)
	#change2hv(local_root)
        jprint('Ingest root: '+ingest_root)

        # Where the data will be stored
        jp2_dir = local_root + 'jp2/'
        hvCreateSubdir(jp2_dir)

        local_storage = jp2_dir + nickname + '/'
        hvCreateSubdir(local_storage)

	# Quarantine
	quarantine = local_root + 'quarantine/'
        hvCreateSubdir(quarantine)

        # Where the data will be ingested in Helioviewer from
        ingest_dir = ingest_root + 'jp2/'
        hvCreateSubdir(ingest_dir)

        ingest_storage = ingest_dir + nickname + '/'
        hvCreateSubdir(ingest_storage)

        # The location of where the databases are stored
        dbloc = local_root + 'db/' + nickname + '/'
        hvCreateSubdir(dbloc)

        # The location of where the logfiles are stored
        logloc = local_root + 'log/'+ nickname +'/'
        hvCreateSubdir(logloc)

        # Today as a directory and as name
        todayDir = yyyy + '/' + mm + '/' + dd
        todayName = yyyy + '_' + mm + '_' + dd

        # get the JP2s for this wavelength
        # create the local JP2 subdirectory required
        local_keep = local_storage + todayDir + '/' + wave + '/'
        try:
                os.makedirs(local_keep)
                change2hv(local_storage)
                change2hv(local_storage + yyyy)
                change2hv(local_storage + yyyy + '/' + mm)
                change2hv(local_storage + yyyy + '/' + mm + '/' + dd)
                change2hv(local_storage + yyyy + '/' + mm + '/' + dd + '/' + wave)
		jprint('Created '+ local_keep)
        except:
                jprint('Directory already exists: '+ local_keep)


        # create the logfile subdirectory for this wavelength
        logSubdir = logloc + todayDir + '/' + wave + '/'
        try:
                os.makedirs(logSubdir)
		jprint('Created log directory: ' + logSubdir)
        except:
                jprint('Directory already exists: '+ logSubdir)

        # Create the logfile filename
	jprint('Time stamp for this iteration = ' + timeStamp)
        logFileName = timeStamp + '.' + yyyy + '_' + mm + '_' + dd + '__'+nickname+'__' + wave + '.wget.log'    

        # create the database subdirectory for this wavelength
        dbSubdir = dbloc + wave + '/' + todayDir
        try:
                os.makedirs(dbSubdir)
		jprint('Created log directory: ' + dbSubdir)
        except:
                jprint('Directory already exists: '+ dbSubdir)

        # create the database filename
        dbFileName = yyyy + '_' + mm + '_' + dd + '__'+nickname+'__' + wave + '__db.csv'    

        # read in the database file for this wavelength and today.
        try:
		# Get a list of images in the subdirectory and update the database with it
		dirList = os.listdir(local_keep)
		f = open(dbSubdir + '/' + dbFileName,'w')
		f.write('This file created '+time.ctime()+'\n\n')
		count = 0
		for testfile in dirList:
			if testfile.endswith('.jp2'):
				stat = os.stat(local_keep + testfile)
				if stat.st_size > minJP2SizeInBytes:
					count = count + 1
					f.write(testfile+'\n')
				else:
					os.rename(local_keep + testfile,quarantine + testfile)
					jprint('Quarantined '+ local_keep + testfile)

		jprint('Updated database file '+ dbSubdir + '/' + dbFileName + '; number of files found = '+str(count))
                #file = open(dbSubdir + '/' + dbFileName,'r')
                #jp2list = file.readlines()
                #jprint('Read database file '+ dbSubdir + '/' + dbFileName)
                #jprint('Number of existing entries in database = ' + str(len(jp2list)))
                # Get a list of the images in the subdirectory
                #dirList = os.listdir(local_keep)
                ## Update the jp2list with any new images which may be present
                #count = 0
                #for testfile in dirList:
                #        if testfile.endswith('.jp2'):
		#		stat = os.stat(local_keep + testfile)
		#		if stat.st_size > minJP2SizeInBytes:
		#			if not testfile + '\n' in jp2list:
		#				jp2list.extend(testfile + '\n')
		#				count = count + 1
		#		# If file is not big enough, quarantine it
		#		else:
		#			os.rename(local_keep + testfile,quarantine + testfile)
		#			jprint('Quarantined '+ local_keep + testfile)
		#			
                #if count > 0:
                #        jprint('Number of local files found not in database: ' + str(count))

        except:
                f = open(dbSubdir + '/' + dbFileName,'w')
                jp2list = ['This file first created '+time.ctime()+'\n\n']
                f.write(jp2list[0])
                jprint('Created new database file '+ dbSubdir + '/' + dbFileName)
        finally:
                f.close()

	# Read the db file
	f = open(dbSubdir + '/' + dbFileName,'r')
	jp2list = f.readlines()
	f.close()

        # put the last image in some web space
        webFileJP2 = jp2list[-1][:-1]
        if webFileJP2.endswith('.jp2'):
                webFile = monitorLoc + 'most_recently_downloaded_aia_' + wave + '.jp2'
		shutil.copy(local_keep + webFileJP2, webFile)
                jprint('Updated latest JP2 file to a webpage: '+ webFile)
        else:
                jprint('No latest JP2 file found.')

        # Calculate the remote directory
        remote_location = remote_root + '/' + todayDir + '/' + wave + '/'

        # Open the soho location and get the file list
	try:
        	#usock = urllib.urlopen(remote_location)
        	#parser = URLLister()
        	#parser.feed(usock.read())
        	#usock.close()
        	#parser.close()
		files_found = os.listdir(remote_location)

	        # Check which files are new at the remote location
	        newlist = ['']
	        newFiles = False
	        newFilesCount = 0
	        for url in files_found:
	                if url.endswith('.jp2'):
	                        if not url + '\n' in jp2list:
	                                newFiles = True
	                                newlist.extend(url + '\n')
	                                newFilesCount = newFilesCount + 1
	        if newFilesCount > 0:
	                jprint('Number of new files found at remote location = ' + str(newFilesCount))
	        else:
	                jprint('No new files found at remote location.')

	        # Write the new filenames to a file
	        if newFiles:
	                newFileListName = timeStamp + '.' + todayName + '__'+nickname+'__'+ wave + '.newfiles.txt'
			newFileListFullPath = logSubdir + '/' + newFileListName
	                jprint('Writing new file list to ' + newFileListFullPath)
	                f = open(newFileListFullPath,'w')
	                f.writelines(newlist)
	                f.close()
	                # Download only the new files
	                jprint('Downloading new files.')
	                localLog = ' -a ' + logSubdir + '/' + logFileName + ' '
	                localInputFile = ' -i ' + logSubdir + '/' + newFileListName + ' '
	                localDir = ' -P'+local_keep + ' '
	                remoteBaseURL = '-B ' + remote_location + ' '
	                command = 'wget -r -l1 -nd --no-parent -A.jp2 ' + localLog + localInputFile + localDir + remoteBaseURL
	
	                os.system(command)

	                # Copy the new files to the ingestion directory
	                #jprint('Downloading new files.')
	                #localLog = ' -a ' + logSubdir + '/' + logFileName + ' '
	                #localInputFile = ' -i ' + logSubdir + '/' + newFileListName + ' '
	                #localDir = ' -P'+local_keep + ' '
	                #remoteBaseURL = '-B ' + remote_location + ' '
	                #command = 'wget -r -l1 -nd --no-parent -A.jp2 ' + localLog + localInputFile + localDir + remoteBaseURL
	
	                #os.system(command)
			for url in files_found:
				if url.endswith('.jp2'):
					if not url + '\n' in jp2list:
						shutil.copy2(remote_location + url,local_keep + url)

	                # Write the new updated database file
	                jprint('Writing updated ' + dbSubdir + '/' + dbFileName)
	                f = open(dbSubdir + '/' + dbFileName,'w')
	                f.writelines(jp2list)
	                f.writelines(newlist)
	                f.close()
	                # Absolutely ensure the correct permissions on all the files
	                change2hv(local_keep)
	
			#
			# Moving the files from the download directory to the ingestion directory
			#
			# Create the moveTo directory
			moveTo = ingest_storage + yyyy + '/' + mm + '/' + dd + '/' + wave + '/'
	                try:
				hvCreateSubdir(ingest_storage + yyyy)
				hvCreateSubdir(ingest_storage + yyyy + '/' + mm)
				hvCreateSubdir(ingest_storage + yyyy + '/' + mm + '/' + dd)
				hvCreateSubdir(ingest_storage + yyyy + '/' + mm + '/' + dd + '/' + wave)
	                except:
	                        jprint('Ingest directory already exists: '+moveTo)
	
			# Read in the new filenames again
	                f = open(logSubdir + '/' + newFileListName,'r')
	                newlist = f.readlines()
	                f.close()
			jprint('New files ingested are as follows:')
			for entry in newlist:
				jprint(entry)
	                # Copy the new files to the ingest directory, and then delete it
	                for name in newlist:
	                        newFile = name[:-1]
	                        if newFile.endswith('.jp2'):
	                                shutil.copy2(local_keep + newFile,moveTo + newFile)
					change2hv(moveTo + newFile)
					#if os.path.exists(os.path.expanduser(local_keep + newFile)):
					#	os.remove(local_keep + newFile)
		else:
                	jprint('No new files found at ' + remote_location)
	except:
		jprint('Problem opening connection to '+remote_location+'.  Continuing with loop.')
	        newFilesCount = -1
	return newFilesCount

# Get the JP2s
def GetJP2(nickname,yyyy,mm,dd,wave,remote_root,local_root,ingest_root,monitorLoc,minJP2SizeInBytes,count = 0, redirect = False, daysBack = 0):
	t1 = time.time()
	timeStamp = createTimeStamp()
	# Standard output + error log file names
	stdoutFileName = timeStamp + '.' + yyyy + '_' + mm + '_' + dd + '__'+nickname+'__' + wave + '.stdout.log'
	stderrFileName = timeStamp + '.' + yyyy + '_' + mm + '_' + dd + '__'+nickname+'__' + wave + '.stderr.log'
	stdoutLatestFileName = 'latest.' + str(daysBack) + '__'+nickname+'__' + wave + '.stdout.log'
	stderrLatestFileName = 'latest.' + str(daysBack) + '__'+nickname+'__' + wave + '.stderr.log'

	# log subdirectory
	logSubdir = hvCreateLogSubdir(local_root,nickname,wave,yyyy,mm,dd)

	# Write a current file to web-space so you know what the script is trying to do right now.
	currentFile = open(monitorLoc + 'current.log','w')
	currentFile.write('Wavelength = ' + wave +'.\n')
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
	jprint('Wavelength = ' + wave)
	jprint('Beginning remote location query number ' + str(count))
	jprint("Looking for files on this date = " + yyyy + mm + dd)
	jprint('Using options file '+ options_file)
	nfc = GetAIAWave(nickname,yyyy,mm,dd,wave,remote_root,local_root,ingest_root,monitorLoc,timeStamp,minJP2SizeInBytes)
	t2 = time.time()
	jprint('Time taken in seconds =' + str(t2 - t1))
	if nfc > 0 :
		jprint('Average time taken in seconds = ' + str( (t2-t1)/nfc ) )
		
	# Put the stdout back
	if redirect:
		sys.stdout = saveout
		fsock.close()
		sys.stderr = saveerr
		ferr.close()

	# Copy the most recent stdout file to some webspace.
		shutil.copy(logSubdir + stdoutFileName, monitorLoc + stdoutLatestFileName)

	return nfc

#Local root - presumed to be created
#local_root = '/home/ireland/JP2Gen_from_LMSAL/v0.8/'

# root of where the data is
#remote_root = "http://sdowww.lmsal.com/sdomedia/hv_jp2kwrite/v0.8/jp2/AIA"

# SOHO instruments
instruments = ['EIT','MDI','LASCO-C2','LASCO-C3']

measurements = {'EIT':['171','195','304','284'],'MDI':['continuum','magnetogram'],'LASCO-C2':['white-light'],'LASCO-C3':['white-light']}


#
# Script must be called using an options file that defines the root of the
# remote directory and the root of the local directory
#
if len(sys.argv) <= 1:
        jprint('No options file given.  Ending.')
else:
        options_file = sys.argv[1]
        try:
                f = open(options_file,'r')
                options = f.readlines()
        finally:
                f.close()

        # Parse the options
        # [0] = remote http location
        # [1] = local subdirectory where the files are first saved to (staging)
	# [2] = local subdirectory where the JP2 files with the correct permissions are put for ingestion
	# [3] = specific year
	# [4] = specific month
	# [5] = specific day
	# [6] = specific wavelength
	# [7] = instrument nickname
	# [8] = webspace
	# [9] = minimum acceptable file size in bytes.  Files smaller than this are considered corrupted
	# [10] = redirect output to file (True)
	# [11] = number of seconds to pause the data download for if no daya was downloaded the last time
	# [12] = minimum number of days back from the present date to consider
	# [13] = maximum number of days back from the present date to consider (note that the range command used to implement this requires a minimum value of n to go back n-1 days)
        remote_root = options[0][:-1]
        local_root = options[1][:-1]
        ingest_root = options[2][:-1]
	startDate = (options[3][:-1]).split('/')
	endDate = (options[4][:-1]).split('/')
	waveI = options[5][:-1]
	nickname = options[6][:-1]
	monitorLoc = options[7][:-1]
	minJP2SizeInBytes = int(options[8][:-1])
	redirectTF = options[9][:-1]
	sleep = int(options[10][:-1])
	daysBackMin = int(options[11][:-1])
	daysBackMax = int(options[12][:-1])

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

				# Go through each instrument and measurement
				for nickname in instruments:
					wavelength = measurements[nickname]
					for wave in wavelength:
						nfc = GetJP2(nickname,yyyy,mm,dd,wave,remote_root+nickname+'/',local_root,ingest_root,monitorLoc,minJP2SizeInBytes,count = count,redirect = redirect,daysBack = daysBack)
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
			if waveI == '-1':
				# Go through each instrument and measurement
				for nickname in instruments:
					wavelength = measurements[nickname]
					for wave in wavelength:
						nfc = GetJP2(nickname,yyyy,mm,dd,wave,remote_root+nickname+'/',local_root,ingest_root,monitorLoc,minJP2SizeInBytes,count = 0,redirect = redirect)
			else:
				nfc = GetJP2(nickname,yyyy,mm,dd,waveI,remote_root,local_root,ingest_root,monitorLoc,minJP2SizeInBytes,count = 0,redirect = redirect)
			getThisDay = getThisDay + 24*60*60
