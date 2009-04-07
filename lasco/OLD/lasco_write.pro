;
; Take a list of LASCO files
; write it out to the intermediate .hvs.sav format
;
; a file containing the absolute locations of the
; LASCO fits files to be processed
;
filename = '2003_10_lasco_c2.txt'
;
; the directory that contains the above file
;
dir = '/Users/ireland/hv/txt/lasco/'
;
; the directory where the .hvs.sav files are
; to be stored
;
rootdir = '/Users/ireland/hv/hvs/2003/10/'

;
; Prep the list of files
;
prepped = JI_LAS_WRITE_LIST_HVS(dir,filename,rootdir,/c2)

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2/'



;
; a file containing the absolute locations of the
; MDI fits files to be processed
;
filename = '2003_10_lasco_c3.txt'
;
; the directory that contains the above file
;
dir = '/Users/ireland/hv/txt/lasco/'
;
; the directory where the .hvs.sav files are
; to be stored
;
rootdir = '/Users/ireland/hv/hvs/2003/10/'

;
; Prep the list of files
;
prepped = JI_LAS_WRITE_LIST_HVS(dir,filename,rootdir,/c3)

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2/'

;
;
;
end
