import sqlite3

con = sqlite3.connect("/Users/ireland/JP2Gen_downloadtest/staging/v0.8/db/dbTest1.sqlite")

cur = con.cursor()

query = ('HMI',2010,12,1,'magnetogram')
cur.execute('select filename from TableTest where nickname=? and yyyy=? and mm=? and dd=? and measurement=?',query)
jp2list_good = cur.fetchall()

sss = '2010_12_01__00_22_11_605__SDO_HMI_HMI_magnetogram.jp2'

print (sss,) in jp2list_good

sss = '2010_12_01__00_19_56_605__SDO_HMI_HMI_magnetogram.jp2'

print (sss,) in jp2list_good
