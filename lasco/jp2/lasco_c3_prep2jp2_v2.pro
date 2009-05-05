;
; 7 April 09
;
; lasco_c3_prep2jp2_v2.pro
;
; Take a list of LASCO C3 files and
; (1) prep the data
; (2) write out jp2 files
;
;
; USER - use the LASCO software program (in Solarsoft) to determine
;        the time range you are interested in.  The program will then
;        create JP2 files in the correct directory structure for use
;        with the Helioviewer project.
;
;restore,'~/hv/hvs/lasco_c3_prep2jp2_v2_Tue_May__5_13.48.16_2009.sav'
LASCO_LISTER,list

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
progname = 'lasco_c3_prep2jp2_v2'
;
; Write style
;
write    = 'direct2jp2'
;
; Call details of storage locations
;
storage = JI_HV_STORAGE()
;
; A file containing the absolute locations of the
; LASCO fits files to be processed
;
filename = progname + '_' + ji_txtrep(ji_systime(),':','_') + '.sav'
save,filename = storage.hvs_location + filename, list
;
; Create the location of the listname
;
listname = storage.hvs_location + filename + '.prepped.txt'

;
; ===================================================================================================
;
;
; Write direct to JP2 from FITS
;
if (write eq 'direct2jp2') then begin
   prepped = JI_LAS_WRITE_HVS(storage.hvs_location,filename,storage.jp2_location,/c3,write = write,/standard_process)
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
      prepped = JI_LAS_WRITE_HVS(storage.hvs_location,filename,storage.hvs_location,/c3,write = write,/standard_process)
      save,filename = listname
      JI_WRITE_LIST_JP2, prepped, storage.jp2_location
   endelse
endif

;
;
end

