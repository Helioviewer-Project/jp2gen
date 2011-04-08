#
# Create a simple html file that links to all the log
# files in a particular directory
#
#
import os,time,sys,datetime

#
# Script must be called using an options file that defines the root of the
# remote directory and the root of the local directory
#
if len(sys.argv) <= 1:
        print 'No options file given.  Ending.'
else:
        options_file = sys.argv[1]
        try:
                file = open(options_file,'r')
                options = file.readlines()
        finally:
                file.close()

        # get the web location
	monitorLoc = options[7][:-1]
        # sleep time
        sleep = int(options[10][:-1])

        while 1:
            flag = False
            dirList = os.listdir('/home/ireland/www')
	    dirList.sort()
            file = open('/home/ireland/www/monitor.html','w')
            file.write('<H1>Simple JP2 Acquisition Monitor</H1><BR><BR>\n\n')
            file.write('<H2>This page provides information on the current status of the JP2 acquisition processes.</H2>')
            file.write('<H2>This file updated every '+str(sleep)+' seconds.\n\n')
            file.write('<H2>Local time when this file was written: '+time.ctime()+'.</H2>\n\n')
            file.write('<H2>UT when this file was written: '+str(datetime.datetime.utcnow()) + ' UT.\n\n</H2>')
	    file.write('<P><BR><BR>')
	    file.write('<H2>Current active acquisition processes.</H2></BR>')
	    for testfile in dirList:
		    if 'current' in testfile:
			    file.write('<a href = '+testfile+'>' + testfile +'</a><BR>\n\n')
	    file.write('</P>')
	    file.write('<P>')
	    file.write("<H2>Stdout logs from the most recent attempt to look for and download JP2 files observed on today's UT date.</H2></BR>")
	    for testfile in dirList:
		    if '.0__' in testfile:
			    file.write('<a href = '+testfile+'>' + testfile +'</a><BR>\n\n')
	    file.write('</P>')
	    file.write('<P>')
	    file.write("<H2>Stdout logs from the most recent attempt to look for and download JP2 files observed on yesterday's UT date.</H2></BR>")
	    for testfile in dirList:
		    if '.1__' in testfile:
			    file.write('<a href = '+testfile+'>' + testfile +'</a><BR>\n\n')

	    file.write('<P>')
	    file.write('<H2>Most recently downloaded JPEG2000 files.</H2></BR>')
            file.write("<H3>Note: the most recently downloaded JP2 file may have been observed at yesterday's UT date.</H3>")
            for testfile in dirList:
			if testfile.endswith('.jp2'):
                            file.write('<a href = '+testfile+'>' + testfile +'</a><BR>\n\n')
                            flag = True
	    file.write('</P>')

	    file.write('<P>')
            if not flag:
                file.write('No files found.\n\n')
	    file.write('</P>')

            file.close()
            time.sleep(sleep)
