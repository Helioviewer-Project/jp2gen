#
# Create a simple html file that links to all the log
# files in a particular directory
#
#
import os,time,sys

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
            dirList = os.listdir(monitorLoc)
	    dirList.sort()
            file = open(monitorLoc + 'monitor.html','w')
            file.write('<H1>Simple monitor file</H1><BR><BR>\n\n')
            file.write('<H2>This file created '+time.ctime()+'.</H2><BR><BR>\n\n')
            file.write('<H2>This file updated every '+str(sleep)+' seconds.</H2><BR><BR>\n\n')
	    file.write('<P>')
	    file.write('<H2>Log files</H2></BR>')
	    file.write('<H2>Current active acquisition processes.</H2></BR>')
	    for testfile in dirList:
		    if 'current' in testfile:
			    file.write('<a href = '+testfile+'>' + testfile +'</a><BR>\n\n')
			    dirList.remove(testfile)
	    file.write('</P>')
	    file.write('<P>')
	    file.write("<H2>Stdout logs from acquisition process for JP2 files observed on today's UT date.</H2></BR>")
	    for testfile in dirList:
		    if '0__' in testfile:
			    file.write('<a href = '+testfile+'>' + testfile +'</a><BR>\n\n')
			    dirList.remove(testfile)
	    file.write('</P>')
	    file.write('<P>')
	    file.write("<H2>Stdout logs from acquisition process for JP2 files observed on yesterday's UT date.</H2></BR>")
	    for testfile in dirList:
		    if '1__' in testfile:
			    file.write('<a href = '+testfile+'>' + testfile +'</a><BR>\n\n')
			    dirList.remove(testfile)

	    file.write('<P>')
	    file.write('<H2>Most recently downloaded JPEG2000 files.</H2></BR>')
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
