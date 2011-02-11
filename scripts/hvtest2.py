import sqlite3,datetime,time

con = sqlite3.connect(":memory:", detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
cur = con.cursor()
cur.execute("create table test(d date, ts timestamp)")

for i in range(0,11):
    today = datetime.date.today()
    now = datetime.datetime.now()
    time.sleep(1)
    print i

    cur.execute("insert into test(d, ts) values (?, ?)", (today, now))
    cur.execute("select d, ts from test")
    row = cur.fetchone()


print today, "=>", row[0], type(row[0])
print now, "=>", row[1], type(row[1])

cur.execute('SELECT * FROM test WHERE ts > "2011-02-08 16:32:24.000"')
row = cur.fetchall()
print len(row)
print "current_date", row[0], type(row[0])
print "current_timestamp", row[1], type(row[1])
s = row[3]
print type(s)
