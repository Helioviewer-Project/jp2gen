# hvSubdir
def directoryConvention(measurement,yyyy,mm,dd):
	"""Return the directory structure for helioviewer JPEG2000 files."""
	return [yyyy+os.sep, yyyy+os.sep+mm+os.sep, yyyy+os.sep+mm+os.sep+dd+os.sep, yyyy+os.sep+mm+os.sep+dd+os.sep + measurement + os.sep]
