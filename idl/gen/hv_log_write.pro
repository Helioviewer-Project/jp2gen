;
;+
; Do the log file
;
;-
PRO HV_LOG_WRITE,hvs, log_comment, log_filename = log_filename,$
                 transfer = transfer, write_this=write_this
  if is_struct(hvs) then begin
     storage = HV_STORAGE(hvs.hvsi.write_this, nickname=hvs.hvsi.details.nickname)
     filename = HV_FILENAME_CONVENTION(hvs.hvsi,/create)
     log = HV_WRITE_LIST_JP2_MKDIR(hvs.hvsi, storage.log_location)
     log_filename = log + filename + '.' + systime(0) + '.log'
     HV_WRT_ASCII,log_comment,log_filename
  endif else begin
;
; write a transfer_log
;
     if keyword_set(transfer) then begin
;
; Get the storage
;
        storage = HV_STORAGE(write_this, nickname = 'HV_TRANSFER_LOGS',/no_db,/no_jp2)
;
; Get today's date
;
        caldat,systime(/julian),m,d,y
        if m lt 10 then mm = '0' + trim(m) else mm = trim(m)
        if d lt 10 then dd = '0' + trim(d) else dd = trim(d)
        yy = trim(y)
;
; Write the logfile
;
        log = HV_WRITE_LIST_JP2_MKDIR({yy:yy,mm:mm,dd:dd,measurement:''},storage.log_location)
        log_filename = log + 'transfer.' + transfer + ji_systime() + '.log'
        HV_WRT_ASCII,log_comment,log_filename
        
     endif else begin
        print,'Unrecognized data passed to HV_LOG_WRITE.  Stopping'
        stop
     endelse
  ENDELSE
END
