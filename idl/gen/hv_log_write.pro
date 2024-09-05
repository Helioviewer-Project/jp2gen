;
;+
; Do the log file
;
; The input to this function is an hvsi structure ONLY.
; 2020/11/03 - Kim Tolbert. Changed log_filename. Previously looked 
;             like: filenamewhatever.Tue Nov 03 14:23:45 2020.log
;             now: filenamewhatever_20201103_1423.log
;             Spaces, colons, and two periods in previous form were problematic.
;
;-
PRO HV_LOG_WRITE,hvsi, log_comment, log_filename = log_filename,$
                 transfer = transfer, write_this=write_this
  if is_struct(hvsi) then begin
     storage = HV_STORAGE(hvsi.write_this, nickname=hvsi.details.nickname)
     filename = HV_FILENAME_CONVENTION(hvsi,/create)
     log = HV_WRITE_LIST_JP2_MKDIR(hvsi, storage.log_location)
     ;Kim changed file name to have _yyyymmdd_hhmm instead of date with spaces, colons, and
     ;two periods in name (!)
     ;log_filename = log + filename + '.' + systime(0) + '.log'
     log_filename = log + filename + '_'+time2file(!stime) + '.log'
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
