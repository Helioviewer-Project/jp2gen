import os

def isFileGood(path,filename,minimumFileSize,endsWith=''):
	""" Tests to see if a file meets the minimum requirements to be ingested into the database.
	An entry of -1 means that the test was not performed, 0 means failure, 1 means pass.
	"""
	tests = {"fileExists":-1,"minimumFileSize":-1,"endsWith":-1}
	isFileGoodDB = 1
	fileProblem = 0

        thisFile = path + filename

	# Does the file exist?
	if os.path.isfile( thisFile ):
		tests["fileExists"] = 1
		# test for file size
		s = os.stat( thisFile )
		if s.st_size > minimumFileSize:
			tests["minimumFileSize"] = 1
		else:
			fileProblem = fileProblem + 2
			tests["minimumFileSize"] = 0
		
		# test that the file has the right extension
		if endsWith != '':
			if thisFile.endswith(endsWith):
				tests["endsWith"] = 1
			else:
				fileProblem = fileProblem + 4
				tests["endsWith"] = 0
	else:
		fileProblem = fileProblem + 1
		tests["fileExists"] = 0

	# Has the file passed all the tests?
	isFileGoodDB = 1
	for i in tests.itervalues():
		if i == 0:
			isFileGoodDB = 0

	return isFileGoodDB, fileProblem
