import sqlite3

con = sqlite3.connect("/home/ireland/JP2Gen_downloadtest/staging/v0.8/db/dbTest1.sqlite")

cur = con.cursor()

query = ('magnetogram',8,1,)
cur.execute('select * from TableTest where measurement=? and dd=? and isFileGood=?',query)
jp2list_good = cur.fetchall()

print len(jp2list_good)

sss = '2010_12_01__00_22_11_605__SDO_HMI_HMI_magnetogram.jp2'

print (sss,) in jp2list_good

sss = '2010_12_01__00_19_56_605__SDO_HMI_HMI_magnetogram.jp2'

print (sss,) in jp2list_good
