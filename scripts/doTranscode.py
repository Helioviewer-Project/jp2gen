import doJPIPencoding
import os,datetime

def doTranscode(d,nickname):
	print 'Testing ' + d
	if os.path.isdir(d):
		list = os.listdir(d)
		if len(list) > 0:
			for name in list:
				if name.endswith('.jp2'):
					print d+name
					if os.path.isfile(d+name):
						doJPIPencoding.doJPIPencoding(d+name,nickname)

dateEnd = datetime.date(2011,03,13)
dateStart = datetime.date(2011,04,20)

#measurement = ('continuum','magnetogram')
#nickname = 'HMI'

measurement = ('304','335','1600','1700','4500')
nickname = 'AIA'

#measurement = ('white-light','')
#nickname = 'LASCO-C2'
#nickname = 'LASCO-C3'

#measurement = ('171','195','304','284')
#nickname = 'EIT'

prefix = '/home/ireland/incoming/staging/v0.8/jp2/'+nickname+'/'
for m in measurement:
	dateNow = dateStart
	while dateNow >= dateEnd:
		d = dateNow.strftime("%Y/%m/%d") + '/'
		if nickname == 'EIT' or nickname == 'LASCO-C2' or nickname == 'LASCO-C3':
			lookhere = prefix + d + m + '/'
		if nickname == 'HMI' or nickname =='AIA':
			lookhere = prefix + m + '/' + d

		doTranscode(lookhere,nickname)
		dateNow = dateNow + datetime.timedelta(-1)

