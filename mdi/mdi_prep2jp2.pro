;
; Take a list of MDI images, prep them, and turn them
; into a set of jp2 files with XML headers corresponding to
; the original FITS header
;
; -
; The original files are read in, prepped, and saved to an
; intermediate format .hvs.sav .  This is an IDL structure
; that contains the data itself, a colortable, and information on the
; nature of the observation.  This intermediate format is read back in
; and dumped as a JP2 file
;
;
institute = 'NASA-GSFC'
contact = 'ADNET Systems/ESA Helioviewer Group (webmaster@helioviewer.org)'
;
; A file containing the absolute locations of the
; MDI fits files to be processed
;
filename = '2003_10_mdi_int.txt'
;
; the directory that contains the above file
;
dir = '/Users/ireland/hv/txt/mdi/'
;
; the directory where the .hvs.sav files are
; to be stored
;
rootdir = '/Users/ireland/hv/hvs2/2003/10/mdi/'

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
   prepped = JI_MDI_WRITE_HVS(dir,filename,rootdir,/int)
   save,filename = rootdir + filename + '.prepped.txt',prepped
ENDELSE

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2_lossy/',institute,contact


;
; a file containing the absolute locations of the
; MDI fits files to be processed
;
filename = '2003_10_mdi_mag.txt'
;
; the directory that contains the above file
;
dir = '/Users/ireland/hv/txt/mdi/'
;
; the directory where the .hvs.sav files are
; to be stored
;
rootdir = '/Users/ireland/hv/hvs2/2003/10/mdi/'


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
   prepped = JI_MDI_WRITE_HVS(dir,filename,rootdir,/mag)
   save,filename = rootdir + filename + '.prepped.txt',prepped
ENDELSE

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2_lossy/',institute,contact

;
;
;
end
