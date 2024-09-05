;
;+
; Write a simple database
; 
; 2010/03/04 - first attempt.  Liable to be superseded by a more
;              sophisticated approach using Dominic Zarro's/ Ron
;              Yurow's database system as developed for EIS 
; 2020/11/01 - Kim Tolbert. Removed /append from first call to HV_WRT_ASCII because crashes
;              if file doesn't exist    
; 2024/03/08 - Kim Tolbert. If hvsi.multi_image_fitsfile exists, and is 1, then if check_fitsname_only is set,
;              check jp2 file name instead of fits file name. For cases where more than one jp2 file
;              is created from a single FITS file.                     
;-
PRO HV_DB,hvsi,check_fitsname_only = check_fitsname_only,$
          already_written = already_written,$
          update = update
;
  progname = 'HV_DB'
;
; delimiter
;
  delim = ','
;
; Get the location and the filename for the database for the
; given YYYY/MM/DD __ nickname __ measurement
;
  storage = HV_STORAGE(hvsi.write_this, nickname = hvsi.details.nickname)
  dbloc = HV_WRITE_LIST_JP2_MKDIR(hvsi,storage.db_location)
  dbname = HV_DBNAME_CONVENTION(hvsi,/create)
;
; Check if the FITS name is already in the data base
;
  IF KEYWORD_SET(check_fitsname_only) then begin
     dbfile = dbloc + dbname
     if file_exist(dbfile) then begin
        db = rd_tfile(dbloc + dbname,4,1,delim = delim)
        multi_image_fitsfile = tag_exist(hvsi.details, 'multi_image_fitsfile') ? hvsi.details.multi_image_fitsfile : 0
        if multi_image_fitsfile then begin
          jp2name = HV_FILENAME_CONVENTION(hvsi,/create)
          in_db_index = where( db[3,*] eq jp2name, indb )
          check_name = jp2name
          check_type = 'JP2'
        endif else begin
          in_db_index = where( db[1,*] eq hvsi.fitsname, indb )
          check_name = hvsi.fitsname
          check_type = 'FITS'
        endelse
        IF indb gt 0 then begin
           already_written = 1 
        endif else begin 
           already_written = 0
        endelse
        print,progname + ': checked ' + check_type + ' filename only; '+ check_name +' in db; '+ dbloc + dbname + '.'
        print,progname + ': already_written = '+ trim(already_written)
     endif else begin
        already_written = 0
        print,progname + ': Database file does not exist: ' + dbfile + ', already_written = 0'
     endelse    
     
  ENDIF ELSE BEGIN
     jp2loc = HV_WRITE_LIST_JP2_MKDIR(hvsi,storage.jp2_location,/return_path_only)
     jp2name = HV_FILENAME_CONVENTION(hvsi,/create)
;
; Create the comma separated entry
;
     dbtext = hvsi.dir + delim + $
              hvsi.fitsname + delim + $
              jp2loc + delim + $
              jp2name + delim + $
              systime(0) + delim
;
; Add in other information, if required.
;
     if tag_exist(hvsi.details,'called_by') then begin
        dbtext = dbtext + hvsi.details.called_by + delim
     endif
;
; Message if a new database entry is being created
;
     if not(file_exist(dbloc + dbname)) then begin
        already_written = 0
        print,'Starting new database file at '+ dbloc + dbname
        ; KIM Removed /append from next line because crashed when file didn't exist
        HV_WRT_ASCII,'This file first created ' + systime(0),dbloc + dbname
        HV_WRT_ASCII,'fitsdir,fitsname,jp2dir,jp2name,time_of_writing,calling_program[optional],',dbloc + dbname,/append
     endif else begin
        HV_DB,hvsi,/check_fitsname_only,already_written = already_written
     endelse
;
; Update the database and the latest file
;
     IF KEYWORD_SET(update) then begin
        HV_WRT_ASCII,dbtext,dbloc + dbname,/append
     endif
  ENDELSE

  return
END
