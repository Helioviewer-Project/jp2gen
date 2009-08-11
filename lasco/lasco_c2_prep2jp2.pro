;
; 27 March 2009
;
; lasco_c3_prep2jp2.pro
;
; Take a list of LASCO C3 files and
; (1) prep the data
; (2) write the data in the hvs format
; (3) Read the hvs file and write out jp2 files

;
; Institute and contact information MUST be supplied
;
institute = 'NASA-GSFC'
contact = 'ADNET Systems/ESA Helioviewer Group (webmaster@helioviewer.org)'

;
; A file containing the absolute locations of the
; LASCO fits files to be processed
;
filename = '2003_10_01t31_c2_fits_list.txt'

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
; Prep the list of files if need be.  Otherwise, get the list of
; prepped data
;
prepped = 'not-done'

;
;
;
IF (prepped eq 'done') then begin
   restore,rootdir + filename + '.prepped.txt'
endif else begin
   prepped = JI_LAS_WRITE_HVS(dir,filename,rootdir,/c2)
   save,filename = rootdir + filename + '.prepped.txt',prepped
ENDELSE

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2_lossy/',institute, contact

;
;
;
end
