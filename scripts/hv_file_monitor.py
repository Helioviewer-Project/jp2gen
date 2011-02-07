#
#
# Script to query the database for files downloaded
# 
# For a given combination of instrument and measurement, and
# a download start and end time, we want to know how many good files
# were downloaded, and how many bad files where downloaded.
#
# Some typical queries might be....
#
# How many good files in total did we download on 31st January?
#
# instrument = *
# measurement = *
# downloadStart = 2011-01-31 00:00
# downloadEnd = 2011-01-31 23:59
# isFileGood = 1
#
# Total number of files attempted to be downloaded in the last six hours
#
# instrument = *
# measurement = *
# downloadStart = now - 6 hour
# downloadEnd = now
# isFileGood = *
# 
# How many bad AIA 94 files on December 25?
#
# instrument = AIA
# measurement = 94
# downloadStart = 2010-12-25 00:00
# downloadEnd = 2010-12-25 23:59
# isFileGood = 0
# 
# 
#
#
# nickname : instrument we are interested in
# measurement : measurement we want
# downloadStart :
# downloadEnd : 
# isFileGood :
# 
#
#

# Database: Connect to the database
try:
	if not os.path.isfile(dbloc + dbName):
		print 'Database not present ' + dbloc + dbName
	else:
		jprint('Connecting to database = ' + dbloc + dbName)
		conn = sqlite3.connect(dbloc + dbName)
		c = conn.cursor()
except Exception,error:
	jprint('Exception caught attempting to communicate with database file; error: '+str(error))

