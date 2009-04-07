#!/usr/bin/python

import commands
import glob

wstrs=["171","195","284","304"]
for wstr in wstrs:
	files = glob.glob("*eit"+wstr+"_1024.jp2")
	out_str = ''	
	for file in files:
		out_str +=file+','
        out_str=out_str[0:-1]
        cmd = "kdu_merge -i %s -o EIT"% (out_str)
        cmd += wstr+"_anim.jp2"
	retval = commands.getstatusoutput(cmd)[0]

		

