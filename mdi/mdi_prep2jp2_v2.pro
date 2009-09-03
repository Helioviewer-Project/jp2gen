;
; 10 April 2009
;
; 2009/04/10 - JI, first version with direct FITS to JP2 conversion
;
; Take a list of MDI images, prep them, and turn them
; into a set of jp2 files with XML headers corresponding to
; the original FITS header
;
; -
; The original files are read in, prepped,
; and dumped as a JP2 file
;
;
; USER - set the variable "mdidir" to the root directory of where the
;        MDI FITS data is.  The program will then create JP2 files in
;        the correct directory structure for use with the Helioviewer
;        project.
;
mdidir = '/Users/ireland/hv/dat/mdi/2003/'

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
progname = 'mdi_prep2jp2_v2'
;
; Write style
;
write    = 'direct2jp2'
;
; Call details of storage locations
;
storage = JI_HV_STORAGE()
;
; Start timing
;
s0 = systime(1)

;
; ===================================================================================================
;
; MDI Intensity
;
;
; A file containing the absolute locations of the
; MDI intensity fits files to be processed

list = file_search(mdidir,'*Ic*.00*.fits')
filename = progname + '_' + ji_txtrep(ji_systime(),':','_') + 'int.sav'
save,filename = storage.hvs_location + filename, list

;
; Create the location of the listname
;
listname = storage.hvs_location + filename + '.int.prepped.txt'
;
; Write direct to JP2 from FITS
;
if (write eq 'direct2jp2') then begin
   prepped = JI_MDI_WRITE_HVS(storage.hvs_location,filename,storage.jp2_location,/int,write = write)
   save,filename = listname,prepped
endif

n1 = n_elements(list)

;
; ======================================================================================================
;
; MDI Magnetogram
;
;
; A file containing the absolute locations of the
; MDI magnetic fits files to be processed
;
list = file_search(mdidir,'*M*.00*.fits')
filename = progname + '_' + ji_txtrep(ji_systime(),':','_') + '.mag.sav'
save,filename = storage.hvs_location + filename, list

;
; Create the location of the listname
;
listname = storage.hvs_location + filename + '.mag.prepped.txt'
;
; Write direct to JP2 from FITS
;
if (write eq 'direct2jp2') then begin
   prepped = JI_MDI_WRITE_HVS(storage.hvs_location,filename,storage.jp2_location,/mag,write = write)
   save,filename = listname,prepped
endif

;
; Write an intermediate HVS file.  Can be useful in testing.
;
if (write eq 'via_hvs') then begin
;
; Does the prep file already exist? If so, restore it and write jp2
; files.  If not, prep the data first and then
;
   if (file_exist(listname)) then begin
      restore,listname
      JI_WRITE_LIST_JP2, prepped, storage.jp2_location
   endif else begin
      prepped = JI_MDI_WRITE_HVS(storage.hvs_location,filename,storage.hvs_location,/mag,write = write)
      save,filename = listname
      JI_WRITE_LIST_JP2, prepped, storage.jp2_location
   endelse
endif
n2 = n_elements(list)
s1 = systime(1)
print,'Total number of files ',n1+n2
print,'Total time taken ',s1-s0
print,'Average time taken ',(s1-s0)/float(n1+n2)

;
;
;
end
