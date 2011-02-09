import sqlite3,datetime,time
import numpy as np
import pylab as plt


def uniq(inlist):
    # order preserving
    uniques = []
    for item in inlist:
        if item not in uniques:
            uniques.append(item)
    return uniques


def hvUniqueNicknames(dbloc, dbName, timeStart, timeEnd):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd)
    cur.execute("SELECT nickname FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<?", (ttt))
    results = cur.fetchall()
    cur.close()
    return uniq(results)

def hvUniqueMeasurements(dbloc, dbName, timeStart, timeEnd):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<?", (ttt))
    results = cur.fetchall()
    cur.close()
    return uniq(results)

def hvNumberFilesByNickname(dbloc, dbName, timeStart, timeEnd, nickname):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd, nickname)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND nickname=?", (ttt))
    result = len(cur.fetchall())
    cur.close()
    return result

def hvNumberFilesByMeasurement(dbloc, dbName, timeStart, timeEnd, measurement):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd, measurement)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND measurement=?", (ttt))
    result = len(cur.fetchall())
    cur.close()
    return result

def hvNumberFilesByNicknameAndMeasurement(dbloc, dbName, timeStart, timeEnd, nickname, measurement):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd, nickname, measurement)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND nickname=? AND measurement=?", (ttt))
    result = len(cur.fetchall())
    cur.close()
    return result

def hvGetMeasurementsPerNickname(dbloc, dbName, timeStart, timeEnd, nickname):
    con = sqlite3.connect(dbloc + dbName, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cur = con.cursor()
    ttt = (timeStart, timeEnd, nickname)
    cur.execute("SELECT measurement FROM TableTest WHERE observationTimeStamp>? AND observationTimeStamp<? AND nickname=?", (ttt))
    results = cur.fetchall()
    cur.close()
    return uniq(results)




dbloc = '/home/ireland/JP2Gen_downloadtest/staging/v0.8/db/'
dbName = 'dbTest2.sqlite'

date = str(datetime.datetime.utcnow().date())
dayStart = date + ' 00:00:00.000'
dayEnd   = date + ' 23:59:59.999'
dayNicknames = hvUniqueNicknames(dbloc,dbName,dayStart, dayEnd)
n = len(dayNicknames)
data = np.zeros((n,24))



for hr in range(0,22):
    if hr <= 9:
        hrLo = '0' + str(hr)
    else:
        hrLo = str(hr)

    hi = hr+1
    if hi <= 9:
        hrHi = '0' + str(hi)
    else:
        hrHi = str(hi)

    timeStart = date + ' ' + hrLo + ':00:00.000'
    timeEnd   = date + ' ' + hrLo + ':59:59.999'

    nicknameList = hvUniqueNicknames(dbloc,dbName,timeStart, timeEnd)
    measurementList = hvUniqueMeasurements(dbloc,dbName,timeStart, timeEnd)

    i = -1
    for entry in nicknameList:
        nickname = entry[0]
        i = i + 1
        # number of files per nickname per hour
        data[i,hr] = hvNumberFilesByNickname(dbloc, dbName, timeStart, timeEnd, nickname)



for i in range(0,n):
    plt.figure()
    plt.plot(data[i,:])
    plt.xlabel('hours after 00:00.00 UT')
    plt.ylabel('number of files')
    plt.title(dayNicknames[i][0] + ' ' + dayStart + ' - ' + dayEnd)
    fname = dayNicknames[i][0] + '_' + dayStart + '_' + dayEnd + '.png'
    plt.savefig(fname,format = 'png')


        #measurementList = hvGetMeasurementsPerNickname(dbloc, dbName, timeStart, timeEnd, nickname)
        #for m in measurementList:
        #    measurement = m[0]
        #    
        #    print ' '
        #    print timeStart + ' -- ' + timeEnd
        #    print nickname + ' ' + measurement + ' : number of files '+str(hvNumberFilesByNicknameAndMeasurement(dbloc, dbName, timeStart, timeEnd, nickname, measurement))



