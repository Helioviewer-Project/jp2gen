;
; Take a list of LASCO files
; write it out to the intermediate .hvs.sav format
;
institute = 'NASA-GSFC'
contact = 'ADNET Systems/ESA Helioviewer Group (webmaster@helioviewer.org)'

; a file containing the absolute locations of the
; LASCO fits files to be processed
filename = '2003_10_01t31_c2_fits_list.txt'
;
; the directory that contains the above file
;
dir = '/Users/ireland/hv/txt/las/'

; the directory where the .hvs.sav files are
; to be stored
rootdir = '/Users/ireland/hv/hvs/2003/10/'

;
; Prep the list of files if need be.  Otherwise, get the list of
; prepped data
prepped = 'done'
IF (prepped eq 'done') then begin
   restore,rootdir + filename + '.prepped.txt'
endif else begin
   prepped = JI_LAS_WRITE_HVS(dir,filename,rootdir,/c2)
   save,filename = rootdir + filename + '.prepped.txt',prepped
ENDELSE

; Take a list of .hvs.sav files and write them out as
; JP2 images
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2_lossy/',institute, contact

;
; a file containing the absolute locations of the
; MDI fits files to be processed
;
filename = '2003_10_01t31_c3_fits_list.txt'
;
; the directory that contains the above file
;
dir = '/Users/ireland/hv/txt/las/'
;
; the directory where the .hvs.sav files are
; to be stored
;
rootdir = '/Users/ireland/hv/hvs/2003/10/'

;
; Prep the list of files
;
prepped = JI_LAS_WRITE_HVS(dir,filename,rootdir,/c3)

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2_lossy/',institute, contact

;
;
;
end
