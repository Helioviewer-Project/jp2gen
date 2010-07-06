#
#
# Script cobbled together from
# 
# http://stackoverflow.com/questions/862173/how-to-download-a-file-using-python-in-a-smarter-way
#
# and
#
# Dive Into Python 5.4
#
# Scrapes all the JP2 files from LMSAL webspace and writes them to local subdirectories
#
# TODO: check for files already downloaded
#
#

from os.path import basename
from urlparse import urlsplit
import shutil
import urllib2
import urllib
from sgmllib import SGMLParser
import os, time

class URLLister(SGMLParser):
	def reset(self):
		SGMLParser.reset(self)
		self.urls = []

	def start_a(self, attrs):
		href = [v for k, v in attrs if k=='href']
		if href:
			self.urls.extend(href)


def download(url, fileName=None, storage=None):
    def getFileName(url,openUrl):
        if 'Content-Disposition' in openUrl.info():
            # If the response has Content-Disposition, try to get filename from it
            cd = dict(map(
                lambda x: x.strip().split('=') if '=' in x else (x.strip(),''),
                openUrl.info().split(';')))
            if 'filename' in cd:
                filename = cd['filename'].strip("\"'")
                if filename: return filename
        # if no filename was found above, parse it out of the final URL.
        return basename(urlsplit(openUrl.url)[2])

    r = urllib2.urlopen(urllib2.Request(url))
    try:
        fileName = fileName or getFileName(url,r)
        fileName = storage + fileName
        with open(fileName, 'wb') as f:
            shutil.copyfileobj(r,f)
    finally:
        r.close()

#download('http://sdowww.lmsal.com/sdomedia/hv_jp2kwrite/v0.8/jp2/AIA/94/2010/06/18/2010_06_18__00_00_20_135__SDO_AIA_AIA_94.jp2')

# The location of where the data will be stored
storage = '/home/ireland/JP2Gen_from_LMSAL/v0.8/jp2/AIA'

# root of where the data is
root = "http://sdowww.lmsal.com/sdomedia/hv_jp2kwrite/v0.8/jp2/AIA"

# wavelength array - constant
wavelength = ['94','131','171','193','211','304','335','1600','1700','4500']

# get today's date in UT

yyyy = time.strftime('%Y',time.gmtime())
mm = time.strftime('%m',time.gmtime())
dd = time.strftime('%d',time.gmtime())

yyyy = '2010'
mm = '06'
dd = '18'

Today = yyyy + '/' + mm + '/' + dd




# go through each wavelength
for wave in wavelength:
    # create the local subdirectory required
    keep = storage + '/' + wave + '/' + Today + '/'
    os.makedirs(keep)

    # calculate the directory
    location = root + '/' + wave + '/' + Today + '/'

    # read in the database file for this wavelength and today.

    # open the location and get the file list
    usock = urllib.urlopen(location)
    parser = URLLister()
    parser.feed(usock.read())
    usock.close()
    parser.close()
    for url in parser.urls:
        if url.endswith('.jp2'):
            print 'reading ' + location + url
            download(location + url, storage = keep)

