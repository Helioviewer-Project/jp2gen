import os

def doJPIPencoding(filename,encodingOption):
	tmp = filename + '.tmp.jp2'
	command ='/usr/local/bin/kdu_transcode -i '+ filename + ' -o '+ tmp
	if encodingOption == 'SOHO':
		options =' Corder=RPCL ORGgen_plt=yes'
	else:
		options =' Corder=RPCL ORGgen_plt=yes Cprecincts=\{128,128\}'
	silent_output = ' > /dev/null'
	os.system(command + options + silent_output)
	os.remove(filename)
	os.rename(tmp,filename)
