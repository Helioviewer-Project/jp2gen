;
;+
; Do the log file
;
;-
PRO HV_WRITE_LOG,hvs, log_comment, log_filename = log_filename
  if is_struct(hvs) then begin
     storage = HV_STORAGE(nickname = hvs.details.nickname)
     filename = HV_FILENAME_CONVENTION(hvs,/create)
     log = HV_WRITE_LIST_JP2_MKDIR(hvs,storage.log_location)
     log_filename = log + filename + '.' + systime(0) + '.log'
     HV_WRT_ASCII,log_comment,log_filename
  endif else begin
     print,'Input hvs file is not a structure.  Stopping.'
     stop
  ENDELSE
END
