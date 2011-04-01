;
; 4 Nov
;
PRO HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date,subdir = subdir
  log_location = (HV_STORAGE(nickname = nickname)).log_location
  if not(is_dir(log_location)) then begin
     subdir = log_location + nickname
;     subdir = log_location
     spawn,'mkdir ' + subdir
     if keyword_set(date) then begin
        answer = HV_LOG_FILENAME_CONVENTION(nickname,date,date,/components)
        subdir = log_location  + answer.date1
        if not(is_dir(subdir)) then begin
           spawn,'mkdir ' + subdir
        endif
     endif
     subdir = subdir + path_sep()
  endif else begin
     if keyword_set(date) then begin
        answer = HV_LOG_FILENAME_CONVENTION(nickname,date,date,/components)
        subdir = log_location + path_sep() + answer.date1
        if not(is_dir(subdir)) then begin
           spawn,'mkdir ' + subdir
        endif
        subdir = subdir + path_sep()
     endif
  endelse
return
end
