import sqlite3,datetime,time
import numpy as np
import matplotlib.pylab as plt
import matplotlib.patches as patches
import matplotlib.path as path



def uniq(inlist):
    # order preserving
    uniques = []
    for item in inlist:
        if item not in uniques:
            uniques.append(item)
    return uniques


def hvDBUniqueNicknames(dbloc, dbName, timeStart, timeEnd):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd)
    cur.execute("SELECT nickname FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<?", (ttt))
    results = cur.fetchall()
    cur.close()
    return uniq(results)

def hvDBUniqueMeasurements(dbloc, dbName, timeStart, timeEnd):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<?", (ttt))
    results = cur.fetchall()
    cur.close()
    return uniq(results)

def hvDBNumberFilesAll(dbloc, dbName, timeStart, timeEnd):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<?", (ttt))
    result = len(cur.fetchall())
    cur.close()
    return result

def hvDBNumberFilesByNickname(dbloc, dbName, timeStart, timeEnd, nickname):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd, nickname)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND nickname=?", (ttt))
    result = len(cur.fetchall())
    cur.close()
    return result

def hvDBNumberFilesByMeasurement(dbloc, dbName, timeStart, timeEnd, measurement):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd, measurement)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND measurement=?", (ttt))
    result = len(cur.fetchall())
    cur.close()
    return result

def hvDBNumberFilesByNicknameAndMeasurement(dbloc, dbName, timeStart, timeEnd, nickname, measurement):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd, nickname, measurement)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND nickname=? AND measurement=?", (ttt))
    result = len(cur.fetchall())
    cur.close()
    return result

def hvDBGetMeasurementsPerNickname(dbloc, dbName, timeStart, timeEnd, nickname):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd, nickname)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND nickname=?", (ttt))
    results = cur.fetchall()
    cur.close()
    return uniq(results)


def hvDBHourTimes(date,hr):
    if hr <= 9:
        hrLo = '0' + str(hr)
    else:
        hrLo = str(hr)
    timeStart = date + ' ' + hrLo + ':00:00.000'
    timeEnd   = date + ' ' + hrLo + ':59:59.999'
    return timeStart,timeEnd

def hvDBPlotHistogram(p,title,fname):
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
    patch = patches.PathPatch(barpath, facecolor='blue', edgecolor='gray', alpha=0.8)
    ax.add_patch(patch)

    # update the view limits
    ax.set_xlim(left[0], right[-1])
    ax.set_ylim(bottom.min(), pmax)

    plt.xlabel('hours after 00:00.00 UT')
    plt.ylabel('number of files')
    plt.text(1,0.025*pmax,'created ' + str(datetime.datetime.utcnow()),fontsize = 8)
    plt.text(1,0.90*pmax,'total = ' + str(p.sum(dtype=np.int32)))
    plt.title(title)
    plt.savefig(fname,format = 'png')
    plt.clf() 

###### Main program


if len(sys.argv) <= 1:
        jprint('No options file given.  Ending.')
else:
	# Get the time that the script was set running
	#beginTimeStamp = createTimeStamp()
	# Read the options file
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
	dbName = options[14][:-1]


dbloc = '/home/ireland/JP2Gen_downloadtest/staging/v0.8/db/'
dbName = 'dbTest2.sqlite'

date = str(datetime.datetime.utcnow().date())
date = '2011-02-08'
dayStart = date + ' 00:00:00.000'
dayEnd   = date + ' 23:59:59.999'
dayNicknames = hvDBUniqueNicknames(dbloc,dbName,dayStart, dayEnd)
n = len(dayNicknames)
data = np.zeros((n,24))

#
# Do the summary plots broken down by all files, nickname, then nickname/measurement
#
#
# All Files
#




data = np.zeros((24))
for hr in range(0,24):
    timeStart, timeEnd = hvDBHourTimes(date,hr)
    data[hr] = hvDBNumberFilesAll(dbloc, dbName, timeStart, timeEnd)

title = 'All files '+dayStart + ' - ' + dayEnd + ' UT'
fname = 'all_files.'+dayStart + '_' + dayEnd + '.png'

hvDBPlotHistogram(data[:],title,fname)




for j in range(0,n):
    nickname = dayNicknames[j][0]

    #
    # Summary plot per nickname
    #
    data = np.zeros((24))
    for hr in range(0,24):
        timeStart, timeEnd = hvDBHourTimes(date,hr)
        data[hr] = hvDBNumberFilesByNickname(dbloc, dbName, timeStart, timeEnd, nickname)

    title = nickname + ' '+dayStart + ' - ' + dayEnd + ' UT'
    fname = nickname + '.'+dayStart + '_' + dayEnd + '.png'

    hvDBPlotHistogram(data[:],title,fname)
   

    #
    # Summary plot per nickname and measurement
    #
    measurements = hvDBGetMeasurementsPerNickname(dbloc, dbName, dayStart, dayEnd, nickname)
    nm = len(measurements)
    data = np.zeros((nm,24))

    for k in range(0,nm):
        measurement = measurements[k][0]
        for hr in range(0,24):
            timeStart, timeEnd = hvDBHourTimes(date,hr)
            data[k,hr] = hvDBNumberFilesByNicknameAndMeasurement(dbloc, dbName, timeStart, timeEnd, nickname, measurement)

        title = nickname + ' '+measurement + ' '+dayStart + ' - ' + dayEnd + ' UT'
        fname = nickname + '.'+measurement + '.'+dayStart + '_' + dayEnd + '.png'

        hvDBPlotHistogram(data[k,:],title,fname)



