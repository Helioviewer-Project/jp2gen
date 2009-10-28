;
; a file containing the absolute locations of the
; MDI fits files to be processed
;
filename = '2003_10_01t31_c3_fits_list.txt'
institute = 'NASA-GSFC'
contact = 'ADNET Systems/ESA Helioviewer Group (webmaster@helioviewer.org)'

;
; the directory that contains the above file
;
dir = '/Users/ireland/hv/txt/las/'
;
; the directory where the .hvs.sav files are
; to be stored
;
rootdir = '/Users/ireland/hv/hvs2/2003/10/las/'

;
; Prep the list of files
;
prepped = JI_LAS_WRITE_HVS(dir,filename,rootdir,/c3)

;
; a short cut having prepped some files
;
;prepped = JI_READ_TXT_LIST('/Users/ireland/hv/txt/shortcut_0C3.txt')

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2_lossy/',institute,contact

end
