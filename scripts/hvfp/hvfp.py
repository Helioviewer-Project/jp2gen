import os,time

class JP2info:

    def __init__(self,yyyy=0,mm=0,dd=0,hh=0,mmm=0,ss=0,milli=0,observatory='',instrument='',detector='',measurement='',nickname=''):
        self.yyyy = yyyy
        self.mm = mm
        self.dd = dd
        self.hh = hh
        self.mmm = mmm
        self.ss = ss
        self.milli = milli
        self.observatory = observatory
        self.instrument = instrument
        self.detector = detector
        self.measurement = measurement
        self.nickname = nickname



# directoryConvention
def directoryConvention(measurement,yyyy,mm,dd):
	"""Return the directory structure for helioviewer JPEG2000 files."""
	return [yyyy+os.sep, yyyy+os.sep+mm+os.sep, yyyy+os.sep+mm+os.sep+dd+os.sep, yyyy+os.sep+mm+os.sep+dd+os.sep + measurement + os.sep]

# filenameConvention
def filenameConvention(yyyy,mm,dd,nickname,measurement, inter='__', intra = '_'):
	"""Creates a filename from the date, nickname and measurement"""
	return yyyy + mm + dd + inter + nickname + inter + measurement


# createTimeStamp
def createTimeStamp():
	""" Creates a time-stamp to be used by all log files. """
	timeStamp = time.strftime('%Y%m%d_%H%M%S', time.localtime())
	return timeStamp

# change2hv
def change2hv(z, localUser=''):
	""" Changes the file permissions, and ownership from a local user to the helioviewer identity """
        os.system('chmod -R 775 ' + z)
	if localUser != '':
		os.system('chown -R '+localUser+':helioviewer ' + z)
