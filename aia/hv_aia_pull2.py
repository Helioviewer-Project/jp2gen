#
#
# Script cobbled together from
# 
# http://stackoverflow.com/questions/862173/how-to-download-a-file-using-python-in-a-smarter-way
#
# and
#
# Dive Into Python 5.4
#
# Scrapes all the JP2 files from LMSAL webspace and writes them to local subdirectories
#
# TODO: check for files already downloaded so we don't download them twice.
# Solution: check for a text db file, if JP2 file is not in the list, download it, and update list.  should be simple
#
#

from os.path import basename
from urlparse import urlsplit
import shutil
import urllib2
import urllib
from sgmllib import SGMLParser
import os, time
import calendar

class URLLister(SGMLParser):
	def reset(self):
		SGMLParser.reset(self)
		self.urls = []

	def start_a(self, attrs):
		href = [v for k, v in attrs if k=='href']
		if href:
			self.urls.extend(href)

def change2hv(z):
	os.system('chmod -R 775 ' + z)
	os.system('chown -R ireland:helioviewer ' + z)

def download(url, fileName=None, storage=None):
    def getFileName(url,openUrl):
        if 'Content-Disposition' in openUrl.info():
            # If the response has Content-Disposition, try to get filename from it
            cd = dict(map(
                lambda x: x.strip().split('=') if '=' in x else (x.strip(),''),
                openUrl.info().split(';')))
            if 'filename' in cd:
                filename = cd['filename'].strip("\"'")
                if filename: return filename
        # if no filename was found above, parse it out of the final URL.
        return basename(urlsplit(openUrl.url)[2])

    TryAgain = True
    while TryAgain:
	    try:
		    r = urllib2.urlopen(urllib2.Request(url))
		    TryAgain = False
	    except (urllib2.URLError),value:
		    if value == 110:
			    print 'Connection time out: Trying again'
			    TryAgain = True

 
    try:
        fileName = fileName or getFileName(url,r)
        fileName = storage + fileName
        with open(fileName, 'wb') as f:
            shutil.copyfileobj(r,f)
    finally:
        r.close()
    change2hv(fileName)

def hvCreateSubdir(x):
	try:
		os.makedirs(x)
		change2hv(x)
	except:
		print 'Directory already exists ' + x



def GetAIAWave(yyyy,mm,dd,wave):

	# Get a time-stamp to be used by all log files
	timeStamp = str(int(time.time()))

	# Local root - presumed to be created
	local_root = '/home/ireland/JP2Gen_from_LMSAL/v0.8/'

	# Where the data will be stored
	jp2_dir = local_root + 'jp2/'
	hvCreateSubdir(jp2_dir)

	local_storage = jp2_dir + 'AIA/'
	hvCreateSubdir(local_storage)

	# The location of where the databases are stored
	dbloc = local_root + 'db/AIA/'
	hvCreateSubdir(dbloc)

	# The location of where the logfiles are stored
	logloc = local_root + 'log/AIA/'
	hvCreateSubdir(logloc)

	# root of where the data is
	remote_root = "http://sdowww.lmsal.com/sdomedia/hv_jp2kwrite/v0.8/jp2/AIA"

	# Today as a directory and as name
	todayDir = yyyy + '/' + mm + '/' + dd
	todayName = yyyy + '_' + mm + '_' + dd

        # get the JP2s for this wavelength
	# create the local JP2 subdirectory required
	local_keep = local_storage + wave + '/' + todayDir + '/'
	try:
		os.makedirs(local_keep)
		change2hv(local_storage)
		change2hv(local_storage + wave)
		change2hv(local_storage + wave + '/' + yyyy)
		change2hv(local_storage + wave + '/' + yyyy + '/' + mm)
		change2hv(local_storage + wave + '/' + yyyy + '/' + mm + '/' + dd)
	except:
		print 'Directory already exists: '+ local_keep


	# create the logfile subdirectory for this wavelength
	logSubdir = logloc + wave + '/' + todayDir
	try:
		os.makedirs(logSubdir)
	except:
		print 'Directory already exists: '+ logSubdir

	# Create the logfile filename
        logFileName = timeStamp + '.' + yyyy + '_' + mm + '_' + dd + '__AIA__' + wave + '.log'    

	# create the database subdirectory for this wavelength
	dbSubdir = dbloc + wave + '/' + todayDir
	try:
		os.makedirs(dbSubdir)
	except:
		print 'Directory already exists: '+ dbSubdir

	# create the database filename
        dbFileName = yyyy + '_' + mm + '_' + dd + '__AIA__' + wave + '__db.csv'    

	# read in the database file for this wavelength and today.
	try:
		file = open(dbSubdir + '/' + dbFileName,'r')
		jp2list = file.readlines()
		print 'Read database file '+ dbSubdir + '/' + dbFileName
		print 'Number of existing entries in database = ' + str(len(jp2list))
		# Get a list of the images in the subdirectory
		dirList = os.listdir(local_keep)
		# Update the jp2list with any new images which may be present
		count = 0
		for testfile in dirList:
			if not testfile + '\n' in jp2list:
				jp2list.extend(testfile + '\n')
				#print 'Added local file not in database: ' + testfile
				count = count + 1
		if count > 0:
			print 'Number of local files found not in database: ' + str(count)
	except:
		file = open(dbSubdir + '/' + dbFileName,'w')
		jp2list = ['This file first created '+time.ctime()+'\n\n']
		file.write(jp2list[0])
		print 'Created database file '+ dbSubdir + '/' + dbFileName
	finally:
		file.close()

	# put the last image in some web space
	webFile = '/service/www/sdo/aia/latest_jp2/latest_' + wave + '.jp2'
	print 'Wrote '+ webFile
	shutil.copy(local_keep + jp2list[-1][:-1], webFile)

	# Calculate the remote directory
	remote_location = remote_root + '/' + wave + '/' + todayDir + '/'

	# Open the remote location and get the file list
	usock = urllib.urlopen(remote_location)
	parser = URLLister()
	parser.feed(usock.read())
	usock.close()
	parser.close()

	# Check which files are new at the remote location
	newlist = ['']
	newFiles = False
	newFilesCount = 0
	for url in parser.urls:
		if url.endswith('.jp2'):
			if not url + '\n' in jp2list:
				newFiles = True
				#print 'found new file at ' + remote_location + url
				newlist.extend(url + '\n')
				newFilesCount = newFilesCount + 1
	if newFilesCount > 0:
		print 'Number of new files found at remote location = ' + str(newFilesCount)
	else:
		print 'No new files found at remote location.'

	# Write the new filenames to a file
	if newFiles:
		newFileListName = timeStamp + '.' + todayName + '__'+ wave + '.newfiles.txt'
		print 'Writing new file list to ' + logSubdir + '/' + newFileListName
		file = open(logSubdir + '/' + newFileListName,'w')
		file.writelines(newlist)
		file.close()
		# Download only the new files
		print 'Downloading new files.'
		localLog = ' -a ' + logSubdir + '/' + logFileName + ' '
		localInputFile = ' -i ' + logSubdir + '/' + newFileListName + ' '
		localDir = ' -P'+local_keep + ' '
		remoteBaseURL = '-B ' + remote_location + ' '
		command = 'wget -r -l1 -nd --no-parent -A.jp2' + localLog + localInputFile + localDir + remoteBaseURL

		os.system(command)

		# Write the new updated database file
		print 'Writing updated ' + dbSubdir + '/' + dbFileName
		file = open(dbSubdir + '/' + dbFileName,'w')
		file.writelines(jp2list)
		file.writelines(newlist)
		file.close()
		# Absolutely ensure the correct permissions on the new file
		#for this in newlist:
		#	change2hv(local_keep + this[:-1])
	else:
		print 'No new files found at ' + remote_location



# wavelength array - constant
wavelength = ['94','131','171','193','211','304','335','1600','1700','4500']


# repeat starts here
count = 0
while 1:
	count = count + 1
	# get today's date in UT

	yyyy = time.strftime('%Y',time.gmtime())
	mm = time.strftime('%m',time.gmtime())
	dd = time.strftime('%d',time.gmtime())

	# get yesterday's date in UT
	#yesterday = calendar.timegm(time.gmtime()) - 24*60*60
	#yesterday_yyyy = time.strftime('%Y',time.gmtime(yesterday))
	#yesterday_mm = time.strftime('%m',time.gmtime(yesterday))
	#yesterday_dd = time.strftime('%d',time.gmtime(yesterday))

	# Make sure we have all of yesterday's data
	#GetAIA(yesterday_yyyy,yesterday_mm,yesterday_dd)

	# Get Today's data
	for wave in wavelength:
		t1 = time.time()
		print ' '
		print ' '
		print 'Wavelength = ' + wave
		print 'Beginning remote location query number ' + str(count)
		GetAIAWave(yyyy,mm,dd,wave)
		print 'Time taken in seconds =' + str(time.time() - t1)
