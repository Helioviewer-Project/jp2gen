import sqlite3,datetime,time, sys, os, shutil, functools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pylab as plt
import matplotlib.patches as patches
import matplotlib.path as path

# Use Agg as is this a non-interactive application


import functools
def try_x_times(x, exceptions_to_catch, exception_to_raise, fn):
    @functools.wraps(fn) #keeps name and docstring of old function
    def new_fn(*args, **kwargs):
        for i in xrange(x):
            try:
                return fn(*args, **kwargs)
            except exceptions_to_catch:
                 pass
        raise exception_to_raise
    return new_fn

def uniq(inlist):
    # order preserving
    uniques = []
    for item in inlist:
        if item not in uniques:
            uniques.append(item)
    return uniques

def hvDBUniqueNicknames(dbloc, dbName, timeStart, timeEnd):
    try:
        con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
        cur = con.cursor()
        ttt = (timeStart, timeEnd)
        cur.execute("SELECT nickname FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<?", (ttt))
        results = cur.fetchall()
        cur.close()
    except Exception,error:
        print 'Error reading database for unique nicknames: error = '+error
        results = []
    return uniq(results)

def hvDBUniqueMeasurements(dbloc, dbName, timeStart, goodbad, timeEnd):
    try:
        con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
        cur = con.cursor()
        ttt = (timeStart, timeEnd, goodbad)
        cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND isFileGood=?", (ttt))
        results = cur.fetchall()
        cur.close()
    except Exception,error:
        print 'Error reading database for unique nicknames: error = '+error
        results = []
    return uniq(results)

def hvDBNumberFilesAll(dbloc, dbName, timeStart, timeEnd, goodbad):
    try:
        con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
        cur = con.cursor()
        ttt = (timeStart, timeEnd, goodbad)
        cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND isFileGood=?", (ttt))
        result = len(cur.fetchall())
        cur.close()
    except Exception,error:
        print 'Error reading database for unique nicknames: error = '+error
        result = []
    return result

def hvDBNumberFilesByNickname(dbloc, dbName, timeStart, timeEnd, goodbad, nickname):
    try:
        con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
        cur = con.cursor()
        ttt = (timeStart, timeEnd, goodbad, nickname)
        cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND isFileGood=? AND nickname=?", (ttt))
        result = len(cur.fetchall())
        cur.close()
    except Exception,error:
        print 'Error reading database for unique nicknames: error = '+error
        result = []
    return result

def hvDBNumberFilesByMeasurement(dbloc, dbName, timeStart, timeEnd, goodbad, measurement):
    try:
        con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
        cur = con.cursor()
        ttt = (timeStart, timeEnd, goodbad, measurement)
        cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND measurement=?", (ttt))
        result = len(cur.fetchall())
        cur.close()
    except Exception,error:
        print 'Error reading database for unique nicknames: error = '+error
        result = []
    return result

def hvDBNumberFilesByNicknameAndMeasurement(dbloc, dbName, timeStart, timeEnd, goodbad, nickname, measurement):
    try:
        con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
        cur = con.cursor()
        ttt = (timeStart, timeEnd, goodbad, nickname, measurement)
        cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND isFileGood=? AND nickname=? AND measurement=?", (ttt))
        result = len(cur.fetchall())
        cur.close()
    except Exception,error:
        print 'Error reading database for unique nicknames: error = '+error
        result = []
    return result

def hvDBMostRecentJP2(dbloc, dbName, timeEnd, daysBackMax, goodbad, nickname, measurement):
    try:
        con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
        cur = con.cursor()
        ttt = (timeStart, timeEnd, goodbad, nickname, measurement)
        cur.execute("SELECT filename FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND isFileGood=? AND nickname=? AND measurement=?", (ttt))
        result = len(cur.fetchall())
        cur.close()
    except Exception,error:
        print 'Error reading database for most recent JP2: error = '+error
        result = []
    return result

def hvDBGetMeasurementsPerNickname(dbloc, dbName, timeStart, timeEnd, goodbad, nickname):
    if goodbad == -1:
        try:
            con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
            cur = con.cursor()
            ttt = (timeStart, timeEnd, nickname)
            cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND nickname=?", (ttt))
            results = cur.fetchall()
            cur.close()
        except Exception,error:
            print 'Error reading database for unique nicknames: error = '+error
            result = []
    else:
        try:
            con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
            cur = con.cursor()
            ttt = (timeStart, timeEnd, goodbad, nickname)
            cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND isFileGood=? AND nickname=?", (ttt))
            results = cur.fetchall()
            cur.close()
        except Exception,error:
            print 'Error reading database for unique nicknames: error = '+error
            result = []
    return uniq(results)

def hvDateDaysBackFromNow(DT, daysBack, relativeLink = '', html = ''):
    datePrevious = str( DT - datetime.timedelta(days=daysBack) )
    linkPrevious = relativeLink + datePrevious.replace('-','/') + '/' + html
    return datePrevious, linkPrevious

def hvReadOptionsFile(optionsFile):
    if len(optionsFile) <= 1:
        print 'No options file given.  Ending.'
    else:
        f = open(optionsFile[1],'r')
        options = f.readlines()
        f.close()

        return {"remoteRoot":options[0][:-1], "stagingRoot":options[1][:-1], "ingestRoot":options[2][:-1], "startDate":(options[3][:-1]).split('/'), "endDate":(options[4][:-1]).split('/'), "measurements":options[5][:-1].split(','), "nickname":options[6][:-1], "monitorLoc":options[7][:-1], "minJP2SizeInBytes": int(options[8][:-1]), "redirectTF": options[9][:-1], "sleep": int(options[10][:-1]), "daysBackMin": int(options[11][:-1]), "daysBackMax": int(options[12][:-1]), "localUser": options[13][:-1], "dbName": options[14][:-1]}


def hvHourTimesForDate(date,hr):
    if hr <= 9:
        hrLo = '0' + str(hr)
    else:
        hrLo = str(hr)
    timeStart = date + ' ' + hrLo + ':00:00.000'
    timeEnd   = date + ' ' + hrLo + ':59:59.999'
    return timeStart,timeEnd

def hvPlotHistogram(p,title,fname,color = 'blue'):
    fig = plt.figure()
    ax = fig.add_subplot(111)
    left = np.arange(0,24)
    right = np.arange(1,25)
    bottom = np.zeros(len(left))

    if p.max() == 0:
        pmax = 100
    else:
        pmax = 1.05*(p.max())

    top = bottom + p

    # we need a (numrects x numsides x 2) numpy array for the path helper
    # function to build a compound path
    XY = np.array([[left,left,right,right], [bottom,top,top,bottom]]).T

    # get the Path object
    barpath = path.Path.make_compound_path_from_polys(XY)

    # make a patch out of it
    patch = patches.PathPatch(barpath, facecolor=color, edgecolor='gray', alpha=0.8)
    ax.add_patch(patch)

    # update the view limits
    ax.set_xlim(left[0], right[-1])
    ax.set_ylim(bottom.min(), pmax)

    plt.xlabel('hours after 00:00.00 UT')
    plt.ylabel('number of files')
    plt.text(1,0.025*pmax,'created ' + str(datetime.datetime.utcnow())+ ' UT',fontsize = 8)
    plt.text(1,0.90*pmax,'total = ' + str(p.sum(dtype=np.int32)))
    plt.title(title)
    plt.savefig(fname,format = 'png')
    plt.clf()

###### Main program

options = hvReadOptionsFile(sys.argv)
dbloc = options["stagingRoot"] + 'db/'
dbName = options["dbName"] #'dbTest2.sqlite'
daysBackMin = options["daysBackMin"]
daysBackMax = options["daysBackMax"]
sleep = options["sleep"]
monitorLoc = options["monitorLoc"]

#
# Where we keep the report from today
#
locationToday = 'yyyy/mm/dd/'
#
# Expresses the depth at which all the summary reports are stored
#
relativeLink = '../../../'
#
# Main file name
#
htmlFileName = 'download_stats.html'
#
#
#
imgWidth = '600px'
#
# Location on the local system where the most recent summary reports are stored
#
mostRecentDir = monitorLoc + locationToday
if not os.path.isdir(mostRecentDir):
    os.makedirs(mostRecentDir)
#
# Link to get back to the most recent summary reports.
#
linkToday = relativeLink + locationToday + htmlFileName

#
# Maximum number of days back that the download graphs are updated in normal operations.
#
dateBackMax = str( (datetime.datetime.utcnow() + datetime.timedelta(days=daysBackMax-1)).date() )

#
# Do the summary plots broken down by all files, nickname, then nickname/measurement
#

while True:
    for daysBack in range(daysBackMin, daysBackMax):
        DT = (datetime.datetime.utcnow() - datetime.timedelta(days=daysBack)).date()
        DT = datetime.date(2010,12,1)
        date = str( DT )
        dayStart = date + ' 00:00:00.000'
        dayEnd   = date + ' 23:59:59.999'
        dayNicknames = hvDBUniqueNicknames(dbloc,dbName,dayStart,dayEnd)
        n = len(dayNicknames)

        datePrevious, linkPrevious = hvDateDaysBackFromNow(DT,1,relativeLink = relativeLink, html = htmlFileName)
        dateOneWeekEarlier, linkOneWeekEarlier = hvDateDaysBackFromNow(DT,7,relativeLink = relativeLink, html = htmlFileName)
        dateFourWeeksEarlier, linkFourWeeksEarlier = hvDateDaysBackFromNow(DT,28,relativeLink = relativeLink, html = htmlFileName)
 
        dateNext, linkNext = hvDateDaysBackFromNow(DT,-1,relativeLink = relativeLink, html = htmlFileName)
        dateOneWeekLater, linkOneWeekLater = hvDateDaysBackFromNow(DT,-7,relativeLink = relativeLink, html = htmlFileName)
        dateFourWeeksLater, linkFourWeeksLater = hvDateDaysBackFromNow(DT,-28,relativeLink = relativeLink, html = htmlFileName)
        
        #
        # Make the Storage directory
        #
        summaryDir = monitorLoc + date.replace('-','/') + '/'
        if not os.path.isdir(summaryDir):
            try:
                os.makedirs(summaryDir)
            except Exception, error:
                print('Error creating directory; error: '+str(error))
        #
        # Open the download summary file
        #
        currentFile = open(summaryDir + htmlFileName,'w')
        currentFile.write('<html>\n')
        currentFile.write('<head>\n')
        currentFile.write('<title>Daily JP2 download summary for '+dayStart+' to '+dayEnd +'</title>\n')
        currentFile.write('</head>\n')
        currentFile.write('<body>\n')
        currentFile.write('<H1>Daily JP2 download summary for '+dayStart+' to '+dayEnd +'.</H1>\n')
        currentFile.write('<P><H3><CENTER>Updated approximately every '+str(sleep)+' seconds until the end of '+dateBackMax+'.</CENTER></H3></P>\n')
        currentFile.write('<P><CENTER><A HREF='+linkToday+'>Today (now)</A>.</CENTER></P>\n')
        currentFile.write('<CENTER>\n')
        currentFile.write('<TABLE width = 1000px>\n')
        currentFile.write('<TR><TH align=center><<< Four weeks</TH><TH align=center><< One week</TH><TH align=center>< One day</TH><TH>-</TH><TH align=center>One day ></TH><TH align=center>One week >></TH><TH align=center>Four weeks >>></TH></TR>\n')
        currentFile.write('<TR><TD align=center><A HREF='+linkFourWeeksEarlier+'><i>'+dateFourWeeksEarlier+'</i></A></TD>\n')
        currentFile.write('<TD align=center><A HREF='+linkOneWeekEarlier+'><i>'+dateOneWeekEarlier+'</i></A></TD>\n')
        currentFile.write('<TD align=center><A HREF='+linkPrevious+'><i>'+datePrevious+'</i></A></TD>\n')
        currentFile.write('<TD align=center>'+date+'</A></TD>\n')
        currentFile.write('<TD align=center><A HREF='+linkNext+'><i>'+dateNext+'</i></A></TD>\n')
        currentFile.write('<TD align=center><A HREF='+linkOneWeekLater+'><i>'+dateOneWeekLater+'</i></A></TD>\n')
        currentFile.write('<TD align=center><A HREF='+linkFourWeeksLater+'><i>'+dateFourWeeksLater+'</i></A></TD></TR>\n')
        currentFile.write('</TABLE>\n')
        currentFile.write('</CENTER>\n')
        currentFile.write('<BR><BR>\n')

        
        currentFile.write('<P><TABLE>\n')
        currentFile.write('<TR><TH align=center width='+imgWidth+'>Good Files</TH><TH align=center width ='+imgWidth+'>Bad Files</TH></TR>\n')
        
        fnameTime = ['_bad_' +dayStart+ '_' +dayEnd+'.png','_good_' +dayStart+ '_' +dayEnd+'.png']
        titleTime = ['(bad) '+dayStart+' - '+dayEnd+' UT','(good) '+dayStart+' - '+dayEnd+' UT']

        #
        # Generate information on both the good and bad files
        #
        for goodbad in range(1,-1,-1):
            if goodbad == 0:
                color = 'red'
            else:
                color = 'b'
            #
            # All Files
            #
            data = np.zeros((24))
            for hr in range(0,24):
                timeStart, timeEnd = hvHourTimesForDate(date,hr)
                data[hr] = hvDBNumberFilesAll(dbloc, dbName, timeStart, timeEnd, goodbad)

            title = ['All files '+titleTime[0],'All files '+titleTime[1]]
            fname = ['all_files' +fnameTime[0],'all_files' +fnameTime[1]]
            hvPlotHistogram(data[:],title[goodbad],summaryDir + fname[goodbad], color = color)
            if goodbad:
                #currentFile.write("<P><IMG src='"+fname[1]+"' width="+imgWidth+"><IMG src='"+fname[0]+"' width="+imgWidth+"></P>\n")
                currentFile.write("<TR><TD><H2>All</H2></TD><TD> </TD></TR>\n")
                currentFile.write("<TR><TD><IMG src='"+fname[1]+"' width="+imgWidth+"></TD>\n")
                currentFile.write("<TD><IMG src='"+fname[0]+"' width="+imgWidth+"></TD></TR>\n")
            #
            # Summary plot per nickname
            #
            for j in range(0,n):
                nickname = dayNicknames[j][0]

                data = np.zeros((24))
                for hr in range(0,24):
                    timeStart, timeEnd = hvHourTimesForDate(date,hr)
                    data[hr] = hvDBNumberFilesByNickname(dbloc, dbName, timeStart, timeEnd, goodbad, nickname)

                title = [nickname + ' (all) '+titleTime[0],nickname + ' (all) '+titleTime[1]]
                fname = [nickname + '_all'   +fnameTime[0],nickname + '_all'   +fnameTime[1]]
                hvPlotHistogram(data[:],title[goodbad],summaryDir + fname[goodbad], color = color)

                if goodbad:
                    #currentFile.write("<P><IMG src='"+fname[1]+"' width="+imgWidth+"><IMG src='"+fname[0]+"' width="+imgWidth+"></P>\n")
                    currentFile.write("<TR><TD><H2>"+nickname+"</H2></TD><TD> </TD></TR>\n")
                    currentFile.write("<TR><TD><IMG src='"+fname[1]+"' width="+imgWidth+"></TD>\n")
                    currentFile.write("<TD><IMG src='"+fname[0]+"' width="+imgWidth+"></TD></TR>\n")
                #
                # Summary plot per nickname and measurement
                #
                measurements = hvDBGetMeasurementsPerNickname(dbloc, dbName, dayStart, dayEnd, -1, nickname)
                nm = len(measurements)
                data = np.zeros((nm,24))

                for k in range(0,nm):
                    measurement = measurements[k][0]
                    for hr in range(0,24):
                        timeStart, timeEnd = hvHourTimesForDate(date,hr)
                        data[k,hr] = hvDBNumberFilesByNicknameAndMeasurement(dbloc, dbName, timeStart, timeEnd, goodbad, nickname, measurement)

                    title = [nickname + ' '+measurement + titleTime[0],nickname + ' '+measurement + titleTime[1]]
                    fname = [nickname + '.'+measurement + fnameTime[0],nickname + '.'+measurement + fnameTime[1]]
                    hvPlotHistogram(data[k,:],title[goodbad],summaryDir + fname[goodbad], color = color)
                    if goodbad:
                        #currentFile.write("<P><IMG src='"+fname[1]+"' width="+imgWidth+"><IMG src='"+fname[0]+"' width="+imgWidth+"></P>\n")
                        currentFile.write("<TR><TD><IMG src='"+fname[1]+"' width="+imgWidth+"></TD>\n")
                        currentFile.write("<TD><IMG src='"+fname[0]+"' width="+imgWidth+"></TD></TR>\n")

        currentFile.write('</TABLE>')
        currentFile.write('<P><I>Last updated '+str(datetime.datetime.utcnow())+' UT.</I></P>')
        currentFile.write('</body>\n')
        currentFile.write('</html>\n')
        currentFile.close()
        #
        # Copy the contents of the current directory to the most recent
        #
        if daysBack == 0:
            # empty the most recent directory
            contents = os.listdir(mostRecentDir)
            for f in contents:
                os.remove(mostRecentDir + f)
            # fill the directory with the contents of the summary directory when daysBack == 0
            contents = os.listdir(summaryDir)
            for f in contents:
                shutil.copy2(summaryDir + f, mostRecentDir + f)
    #
    # Sleep
    #
    #print 'Sleeping for '+str(sleep)+ ' seconds.'
    time.sleep(sleep)

