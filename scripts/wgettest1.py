import time,os


testRoot = '/home/ireland/JP2Gen_downloadtest/wgettest1/'

logSubdir = testRoot + 'log/wget/'
stagingSubdir = testRoot + 'staging/'
remote_location = 'http://sdowww.lmsal.com/sdomedia/hv_jp2kwrite/v0.8/jp2/AIA/2011/05/16/171/'

logFileName = time.strftime('%Y%m%d_%H%M%S', time.localtime()) + '.wget.log'

localLog = ' -a ' + logSubdir + logFileName + ' '
localDir = ' -P '+stagingSubdir + ' '
remoteBaseURL = remote_location + ' '
command = 'wget -r -l1 -nd --timestamping --no-parent -A.jp2 ' + localLog + localDir + remoteBaseURL
print command

#try:
#    while True:
os.system(command)
#except Exception,error:
#    print 'Exception caught executing wget command'
