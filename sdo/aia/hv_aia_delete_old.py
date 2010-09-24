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

# Forward compatibility with Python 3
def jprint(z):
        print z

# Element has the correct permissions and ownership
def change2hv(z):
        os.system('chmod -R 775 ' + z)
        os.system('chown -R ireland:helioviewer ' + z)

# Create a HV - compliant subdirectory
def hvCreateSubdir(x):
        try:
                os.makedirs(x)
                change2hv(x)
        except:
                jprint('Directory already exists: ' + x)

# yyyy - four digit year
# mm - two digit month
# dd - two digit day
# remote_root - remote location of the AIA files
# local_root - files from remote location are originally copied here, and have their permissions changes here
# ingest_root - the directory where the files with the correct permissions end up

def GetAIAWave(nickname,yyyy,mm,dd,wave,remote_root,local_root,ingest_root):
        jprint('Remote root: '+remote_root)
        jprint('Local root: '+local_root)
	change2hv(local_root)
        jprint('Ingest root: '+ingest_root)

        # Create a time-stamp to be used by all log files
        TSyyyy = time.strftime('%Y',time.localtime())
        TSmm = time.strftime('%m',time.localtime())
        TSdd = time.strftime('%d',time.localtime())
        TShh = time.strftime('%H',time.localtime())
        TSmmm = time.strftime('%M',time.localtime())
        TSss =  time.strftime('%S',time.localtime())
        timeStamp = TSyyyy + TSmm + TSdd + '_' + TShh + TSmmm + TSss

        # Where the data will be stored
        jp2_dir = local_root + 'jp2/'
        hvCreateSubdir(jp2_dir)

        local_storage = jp2_dir + nickname + '/'
        hvCreateSubdir(local_storage)

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
        local_keep = local_storage + wave + '/' + todayDir + '/'
        try:
                os.makedirs(local_keep)
                change2hv(local_storage)
                change2hv(local_storage + wave)
                change2hv(local_storage + wave + '/' + yyyy)
                change2hv(local_storage + wave + '/' + yyyy + '/' + mm)
                change2hv(local_storage + wave + '/' + yyyy + '/' + mm + '/' + dd)
		jprint('Created '+ local_keep)
        except:
                jprint('Directory already exists: '+ local_keep)


        # create the logfile subdirectory for this wavelength
        logSubdir = logloc + wave + '/' + todayDir
        try:
                os.makedirs(logSubdir)
		jprint('Created log directory: ' + logSubdir)
        except:
                jprint('Directory already exists: '+ logSubdir)

        # Create the logfile filename
        logFileName = timeStamp + '.' + yyyy + '_' + mm + '_' + dd + '__'+nickname+'__' + wave + '.log'    

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
                file = open(dbSubdir + '/' + dbFileName,'r')
                jp2list = file.readlines()
                jprint('Read database file '+ dbSubdir + '/' + dbFileName)
                jprint('Number of existing entries in database = ' + str(len(jp2list)))
                # Get a list of the images in the subdirectory
                dirList = os.listdir(local_keep)
                # Update the jp2list with any new images which may be present
                count = 0
                for testfile in dirList:
                        if testfile.endswith('.jp2'):
                                if not testfile + '\n' in jp2list:
                                        jp2list.extend(testfile + '\n')
                                        count = count + 1
                if count > 0:
                        jprint('Number of local files found not in database: ' + str(count))
        except:
                file = open(dbSubdir + '/' + dbFileName,'w')
                jp2list = ['This file first created '+time.ctime()+'\n\n']
                file.write(jp2list[0])
                jprint('Created new database file '+ dbSubdir + '/' + dbFileName)
        finally:
                file.close()

        # put the last image in some web space
        webFileJP2 = jp2list[-1][:-1]
        if webFileJP2.endswith('.jp2'):
                webFile = '/service/www/sdo/aia/latest_jp2/latest_aia_' + wave + '.jp2'
        #       shutil.copy(local_keep + webFileJP2, webFile)
                jprint('Updated latest JP2 file to a webpage: '+ webFile)
        else:
                jprint('No latest JP2 file found.')

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
                jprint('Number of new files found at remote location = ' + str(newFilesCount))
        else:
                jprint('No new files found at remote location.')

        # Write the new filenames to a file
        if newFiles:
                newFileListName = timeStamp + '.' + todayName + '__'+nickname+'__'+ wave + '.newfiles.txt'
                jprint('Writing new file list to ' + logSubdir + '/' + newFileListName)
                file = open(logSubdir + '/' + newFileListName,'w')
                file.writelines(newlist)
                file.close()
                # Download only the new files
                jprint('Downloading new files.')
                localLog = ' -a ' + logSubdir + '/' + logFileName + ' '
                localInputFile = ' -i ' + logSubdir + '/' + newFileListName + ' '
                localDir = ' -P'+local_keep + ' '
                remoteBaseURL = '-B ' + remote_location + ' '
                command = 'wget -r -l1 -nd --no-parent -A.jp2 ' + localLog + localInputFile + localDir + remoteBaseURL

                os.system(command)

                # Write the new updated database file
                jprint('Writing updated ' + dbSubdir + '/' + dbFileName)
                file = open(dbSubdir + '/' + dbFileName,'w')
                file.writelines(jp2list)
                file.writelines(newlist)
                file.close()
                # Absolutely ensure the correct permissions on all the files
                change2hv(local_keep)

		#
		# Moving the files from the download directory to the ingestion directory
		#
		# Create the moveTo directory
		moveTo = ingest_storage + wave + '/' + yyyy + '/' + mm + '/' + dd + '/'
                try:
			hvCreateSubdir(ingest_storage)
			hvCreateSubdir(ingest_storage + wave)
			hvCreateSubdir(ingest_storage + wave + '/' + yyyy)
			hvCreateSubdir(ingest_storage + wave + '/' + yyyy + '/' + mm)
			hvCreateSubdir(ingest_storage + wave + '/' + yyyy + '/' + mm + '/' + dd)
                except:
                        jprint('Ingest directory already exists: '+moveTo)

		# Read in the new filenames again
                file = open(logSubdir + '/' + newFileListName,'r')
                newlist = file.readlines()
                file.close()
                # Move the new files to the ingest directory
                for name in newlist:
                        newFile = name[:-1]
                        if newFile.endswith('.jp2'):
                                shutil.copy2(local_keep + newFile,moveTo + newFile)
				change2hv(moveTo + newFile)
        else:
                jprint('No new files found at ' + remote_location)

def hvDir(root,version,extension,y,m,d,measuremement):
	r = strarr(7)
	r[0] = root
	r[1] = r[0] + 'v' + str(version) + '/'
	r[2] = r[1] + extension + '/'
	r[3] = r[2] + measurement + '/'
	r[4] = r[3] + y + '/'
	r[5] = r[4] + m + '/'
	r[6] = r[5] + d + '/'
	return r

# Local root - presumed to be created
#local_root = '/home/ireland/JP2Gen_from_LMSAL/v0.8/'

# root of where the data is
#remote_root = "http://sdowww.lmsal.com/sdomedia/hv_jp2kwrite/v0.8/jp2/AIA"

#
# Script must be called using an options file that defines the root of the
# remote directory and the root of the local directory
#
if len(sys.argv) <= 1:
        jprint('No options file given.  Ending.')
else:
        options_file = sys.argv[1]
        try:
                file = open(options_file,'r')
                options = file.readlines()
        finally:
                file.close()

        # Parse the options
        # first entry must be the remote http location
        # second entry must be the local subdirectory where the files are saved to
	# [2] = local sub-directory where the JP2 files with the correct permissions are put for transfer
	# [3] = specific year
	# [4] = specific month
	# [5] = specific day
	# [6] = specific wavelength
        remote_root = options[0][:-1]
        local_root = options[1][:-1]
        ingest_root = options[2][:-1]
	yyyyI = options[3][:-1]
	mmI = options[4][:-1]
	ddI = options[5][:-1]
	waveI = options[6][:-1]
	nickname = options[7][:-1]
        # wavelength array - constant
        wavelength = ['94','131','171','193','211','304','335','1600','1700','4500']

	dayInSeconds = 24*60*60

	delay = 14*dayInSeconds
	Y = calendar.timegm(time.gmtime()) - delay
	yyyy = time.strftime('%Y',time.gmtime(Y))
	mm = time.strftime('%m',time.gmtime(Y))
	dd = time.strftime('%d',time.gmtime(Y))

	# get the next wavelength
	for wave in wavelength:
		r = hvDir(local_root,0.8,'jp2',yyyy,mm,dd,wave)
		# get all the files in the directory
		fList = os.listdir(r[6])
		# get the last modification time for this file
		for this in fList:
			mTime = (os.stat(this)).st_mtime
			# if the file is older than the delay, delete
			if now-mTime > delay :
				os.remove(r[6] + this)
		# remove all the branches we can
		os.removedirs(r[2])
			
