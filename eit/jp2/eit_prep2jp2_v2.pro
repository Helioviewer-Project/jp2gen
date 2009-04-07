;
; Prep a set of EIT images between a given time range
;
; Steps taken: Load FITS data, prep + calibrate image, write JP2
; file.  No intermediate data written
;
; sudo /sbin/mount 129.165.40.191:/Volumes/eit /Users/ireland/SOHO/EIT
; from a X11 term
;
; Call details of storage locations
;
storage = JI_HV_STORAGE()

;
; Range of data to look at
;
date_start = '2003/01/23'
date_end   = '2003/12/31'
write      = 'direct2jp2'

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
