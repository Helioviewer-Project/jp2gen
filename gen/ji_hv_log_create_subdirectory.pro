;
; 4 Nov
;
PRO JI_HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date,subdir = subdir
  log_location = (JI_HV_STORAGE()).log_location
  if not(is_dir(log_location + nickname)) then begin
     subdir = log_location + nickname
     spawn,'mkdir ' + subdir
     if keyword_set(date) then begin
        answer = JI_HV_LOG_FILENAME_CONVENTION(nickname,date,date,/components)
        subdir = log_location + nickname + '/' + answer.date1
        if not(is_dir(subdir)) then begin
           spawn,'mkdir ' + subdir
        endif
     endif
  endif else begin
     if keyword_set(date) then begin
        answer = JI_HV_LOG_FILENAME_CONVENTION(nickname,date,date,/components)
        subdir = log_location + nickname + '/' + answer.date1
        if not(is_dir(subdir)) then begin
           spawn,'mkdir ' + subdir
        endif
     endif
  endelse
  subdir = subdir + '/'
return
end
