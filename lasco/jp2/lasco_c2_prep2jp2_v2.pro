;
; 7 April 09
;
; lasco_c2_prep2jp2_v2.pro
;
; Take a list of LASCO C2 files and
; (1) prep the data
; (2) write out jp2 files

;
; Call details of storage locations
;
storage = JI_HV_STORAGE()
;
; A file containing the absolute locations of the
; LASCO fits files to be processed
;
filename = '2003_10_01t31_c2_fits_list.txt'
write    = 'direct2jp2'
;
; the directory that contains the above file
;
dir = '/Users/ireland/hv/txt/las/'
;
; Create the location of the listname
;
listname = storage.hvs_location + filename + '.prepped.txt'
;
; Write direct to JP2 from FITS
;
if (write eq 'direct2jp2') then begin
   prepped = JI_LAS_WRITE_HVS(dir,filename,storage.jp2_location,/c2,write = write)
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
      prepped = JI_LAS_WRITE_HVS(dir,filename,storage.hvs_location,/c2,write = write)
      save,filename = listname
      JI_WRITE_LIST_JP2, prepped, storage.jp2_location
   endelse
endif




;
;
end
