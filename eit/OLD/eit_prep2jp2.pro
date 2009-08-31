;
;
; Prep a set of EIT images between a given time range
;
; sudo /sbin/mount 129.165.40.191:/Volumes/eit /Users/ireland/SOHO/EIT
; from a X11 term
;
institute = 'NASA-GSFC'
contact = 'ADNET Systems/ESA Helioviewer Group (webmaster@helioviewer.org)'

date_start = '2003/01/01'
date_end   = '2003/12/31'

;
; the directory where the .hvs.sav files are
; to be stored
;
rootdir = '/Users/ireland/hv/hvs/2003/10/'

;
; The filename for a file which will contain the locations of the
; hvs EIT files.
;
filename = ji_txtrep(date_start,'/','_') + '-' + ji_txtrep(date_end,'/','_') + '.txt'

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
   prepped = JI_EIT_WRITE_HVS(date_start,date_end,rootdir)
   save,filename = rootdir + filename + '.prepped.txt',prepped
ENDELSE

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2_lossy/',institute, contact


end
