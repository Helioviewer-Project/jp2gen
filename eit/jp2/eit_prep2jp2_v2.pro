;
; Prep a set of EIT images between a given time range
;
; Steps taken: Load FITS data, prep + calibrate image, write JP2
; file.  No intermediate data written
;
; sudo /sbin/mount 129.165.40.191:/Volumes/eit /Users/ireland/SOHO/EIT
; from a X11 term
;
; USER - set the start date and end date of the range of EIT data you
;        are interested in.  The program will then create JP2 files in
;        the correct directory structure for use with the Helioviewer
;        project.
;
date_start = '2003/01/01'
date_end   = '2003/12/31'

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
progname = 'eit_prep2jp2_v2'
;
; Write style
;
write      = 'direct2jp2'
;
; Call details of storage locations
;
storage = JI_HV_STORAGE()

;
; The filename for a file which will contain the locations of the
; hvs EIT files.
;
filename = ji_txtrep(date_start,'/','_') + '-' + ji_txtrep(date_end,'/','_') + '.txt'

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
   prepped = JI_EIT_WRITE_HVS(date_start,$
                              date_end,  $
                              storage.jp2_location,$
                              write = write)
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
      prepped = JI_EIT_WRITE_HVS(date_start,$
                                 date_end,  $
                                 storage.hvs_location,$
                                 write = write)
      save,filename = listname
      JI_WRITE_LIST_JP2, prepped, storage.jp2_location
   endelse
endif



end
