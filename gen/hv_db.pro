;
;+
; Write a simple database
; 
; 2010/03/04 - first attempt.  Liable to be superseded by a more
;              sophisticated approach using Dominic Zarro's/ Ron
;              Yurow's database system as developed for EIS 
;-
PRO HV_DB,hvs,check_fitsname_only = check_fitsname_only,$
          already_written = already_written,$
          update = update
;
; delimiter
;
  delim = ','
;
; Get the location and the filename for the database for the
; given YYYY/MM/DD __ nickname __ measurement
;
  storage = HV_STORAGE(nickname = hvs.details.nickname)
  dbloc = HV_WRITE_LIST_JP2_MKDIR(hvs,storage.db_location)
  dbname = HV_DBNAME_CONVENTION(hvs,/create)
  jp2name = HV_FILENAME_CONVENTION(hvs,/create)
;
; Create the comma separated entry
;
  dbtext = hvs.dir + delim + hvs.fitsname + delim + jp2name + delim + systime(0) + delim
;
; Message if a new database entry is being created
;
  if not(file_exist(dbloc + dbname)) then begin
     print,'Starting new database file at '+ dbloc + dbname
     HV_WRT_ASCII,'First created ' + systime(0),dbloc + dbname,/append
     HV_WRT_ASCII,'dir,fitsname,jp2_filename_root,time_of_writing',dbloc + dbname,/append
  endif
;
; Update the database and the latest file
;
  IF KEYWORD_SET(update) then begin
     HV_WRT_ASCII,dbtext,dbloc + dbname,/append
  endif
;
; Check if the FITS name is already in the data base
;
  IF KEYWORD_SET(check_fitsname_only) then begin
     db = rd_tfile(dbloc + dbname,3,1,delim = delim)
     in_db_index = where( db[1,*] eq hvs.fitsname, indb )
     IF indb gt 0 then begin
        already_written = 1 
     endif else begin 
        already_written = 0
     endelse
  ENDIF

  return
END
